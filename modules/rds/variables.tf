variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID of application instances"
  type        = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "engine_version" {
  type    = string
  default = "16.1"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  description = "Max storage for autoscaling (GB)"
  type        = number
  default     = 100
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
