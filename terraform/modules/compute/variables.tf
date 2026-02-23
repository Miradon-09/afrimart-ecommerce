variable "project_name" {
  type = string
}

variable "web_sg_id" {
  type        = string
  description = "Security group ID for the EC2 instances"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the Launch Template"
}

variable "instance_type" {
  type        = string
  description = "Instance type (e.g., t3.medium)"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for the ASG"
}

variable "elb_id" {
  type        = string
  description = "The ID of the Classic Load Balancer to attach"
}

variable "key_name" {
  type        = string
  description = "The EC2 Key Pair name for SSH access"
}

variable "backend_repo_url" {
  type        = string
  description = "ECR Repository URL for Backend"
}

variable "frontend_repo_url" {
  type        = string
  description = "ECR Repository URL for Frontend"
}
variable "jenkins_sg_id" {
  type        = string
  description = "Security group ID for the Jenkins instance"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for Jenkins"
}
