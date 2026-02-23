# IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# SSM Policy for Debugging
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ecr_policy" {
  name = "${var.project_name}-ecr-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [var.web_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              set -x

              # 0. INJECT SSH KEY
              mkdir -p /home/ec2-user/.ssh
              echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCMDFz9FiIiRaCir11jY5wQk8ehSjohNd+Yjg1OnNwDgXCqACRv1Ta6P5ArCEISQ42zKMJD4/E2SnNDXUT5RR3VbpgpV3G0cIM/5rMBmEFehsYVUBYC4qDo2tLLlVOwMgDW/sZ4YBniLSnH3aLfiO7hAcZrdLqlDIgIzar7tZOoVK/wTRJ0SeBnYvLd3U5a1Y8MaTpf6NEt25slh1nRZ4aPzrLGhTe5BEWrfTOihNH/sEAA0gmOOr2zVtgMcdNinskCHLxcy6GOjaFWm0YUCpmCELr7fhnQgkG3RwooQvUOWt9httaTTGvJaKsVkoqM3Vj/xXkD9gQBJVDaLBkxMFYMh8eXN2UgyAu6YMqLfsBUoeaBSLlK27IXJI7atFrB7Lya7DE0AQ7U//n+D8Z40rHQGJBoxZXL7cINOFS2WkpNQGtCrwPNVH4X21epzmdfj1Au4x/Mq6SpwdffMxIoTkGt8KDcC1mbr8gqjg62LMZSm7xHfY3NEqk9zqYMpAxfJG2LIE7wJIl39p2zcK4ZSi3odd/qdNqHi0smPMRQKScpRxgjG3PXFtjGrU85Vj3PvfCFgelbLG9wzJMAhw//d04WsiWSbKDH7w9Gm2MQ3LnMtkkmVzziySfyte1KaTFJq/5Okz0Zl24jNsnJtBQIUvhVfFhUoN8HmTR7/aMjCs7SUQ== jayps@MICH3AL" >> /home/ec2-user/.ssh/authorized_keys
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              chmod 700 /home/ec2-user/.ssh
              chmod 600 /home/ec2-user/.ssh/authorized_keys

              # 1. IMMEDIATE HEALTH CHECK: Use Python (built-in)
              mkdir -p /var/www/html
              echo "OK" > /var/www/html/health
              echo "<h1>Afrimart Infrastructure Initialized</h1><p>Waiting for Ansible/Docker...</p>" > /var/www/html/index.html
              
              # Nginx will handle port 80 once Ansible runs.
              # We avoid starting any temporary server on port 80 here.
              EOF
  )
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = var.private_subnets # Instances live in private subnets

  # Connect to the Launch Template
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Connect to the Classic Load Balancer
  load_balancers = [var.elb_id]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }
}