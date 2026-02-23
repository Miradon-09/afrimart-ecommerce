variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_security_group_id" {
  type = string
}

variable "cache_subnet_group" {
  type = string
}

variable "cache_security_group" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}