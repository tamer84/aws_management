variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "eu-central-1"
}

variable "parent_ou_id" {
  type        = string
  description = "Parent OU ID to create solution under"
}

variable "domain" {
  type        = string
  description = "DNS domain"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "sso_email" {
  type        = string
  description = "Email of account administrator"
}
