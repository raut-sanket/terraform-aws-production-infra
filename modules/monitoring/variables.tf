variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "alert_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "rds_identifier" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
