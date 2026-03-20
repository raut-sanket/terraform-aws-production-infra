variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for CI/CD role assumption"
  type        = string
  default     = ""
}

variable "oidc_provider_url" {
  description = "OIDC provider URL (without https://)"
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
