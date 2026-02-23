# modules/loadbalancer/main.tf

resource "aws_elb" "main" {
  name               = "${var.project_name}-clb"
  subnets            = var.public_subnets
  security_groups    = var.security_groups

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 3
    target              = "HTTP:80/health" # Ensure your app responds to /health
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.project_name}-clb"
  }
}