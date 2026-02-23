
# Jenkins IAM Role
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.project_name}-jenkins-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                         = var.ami_id # Amazon Linux 2 (passed from main.tf)
  instance_type               = "t3.small" # 2 vCPU, 2GB RAM
  key_name                    = var.key_name
  subnet_id                   = var.public_subnets[0]
  associate_public_ip_address = true 
  # Wait, Jenkins needs internet access to install plugins and be accessed.
  # If in private subnet, it needs NAT Gateway (which we have).
  # BUT, to access the UI (8080), unless we have a Load Balancer or VPN, we can't access it from public internet if it's in private subnet.
  # OPTION 1: Put in Public Subnet.
  # OPTION 2: Put in Private Subnet and use ALB (but we have a Classic ELB for the app).
  # OPTION 3: Put in Private Subnet and use SSM Port Forwarding.
  # The easiest for "User Manual Verification" is Public Subnet with SG allowing 8080 from user IP (or 0.0.0.0/0 for demo).
  # However, var.private_subnets is passed. I don't have public_subnets passed to compute module!
  # I should check main.tf.
  
  # User Data for Installation
  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              set -x
              
              # 0. INJECT SSH KEY
              mkdir -p /home/ec2-user/.ssh
              echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCMDFz9FiIiRaCir11jY5wQk8ehSjohNd+Yjg1OnNwDgXCqACRv1Ta6P5ArCEISQ42zKMJD4/E2SnNDXUT5RR3VbpgpV3G0cIM/5rMBmEFehsYVUBYC4qDo2tLLlVOwMgDW/sZ4YBniLSnH3aLfiO7hAcZrdLqlDIgIzar7tZOoVK/wTRJ0SeBnYvLd3U5a1Y8MaTpf6NEt25slh1nRZ4aPzrLGhTe5BEWrfTOihNH/sEAA0gmOOr2zVtgMcdNinskCHLxcy6GOjaFWm0YUCpmCELr7fhnQgkG3RwooQvUOWt9httaTTGvJaKsVkoqM3Vj/xXkD9gQBJVDaLBkxMFYMh8eXN2UgyAu6YMqLfsBUoeaBSLlK27IXJI7atFrB7Lya7DE0AQ7U//n+D8Z40rHQGJBoxZXL7cINOFS2WkpNQGtCrwPNVH4X21epzmdfj1Au4x/Mq6SpwdffMxIoTkGt8KDcC1mbr8gqjg62LMZSm7xHfY3NEqk9zqYMpAxfJG2LIE7wJIl39p2zcK4ZSi3odd/qdNqHi0smPMRQKScpRxgjG3PXFtjGrU85Vj3PvfCFgelbLG9wzJMAhw//d04WsiWSbKDH7w9Gm2MQ3LnMtkkmVzziySfyte1KaTFJq/5Okz0Zl24jNsnJtBQIUvhVfFhUoN8HmTR7/aMjCs7SUQ== jayps@MICH3AL" >> /home/ec2-user/.ssh/authorized_keys
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              chmod 700 /home/ec2-user/.ssh
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              
              # Install Java 11 (required for Jenkins)
              amazon-linux-extras install java-openjdk11 -y
              
              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              yum upgrade -y
              yum install jenkins -y
              systemctl enable jenkins
              systemctl start jenkins
              
              # Install Docker
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              usermod -a -G docker jenkins
              systemctl enable docker
              
              # Install Git
              yum install git -y
              EOF

  vpc_security_group_ids = [var.jenkins_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
