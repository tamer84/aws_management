variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "eu-central-1"
}

variable "ou_name" {
  type        = string
  description = "New OU name"
}

variable "github_owner" {
  type        = string
  description = "Github owner for OIDC"
}