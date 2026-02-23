variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs for the ALB"
}