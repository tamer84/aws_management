variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "eu-central-1"
}

variable "parent_ou_id" {
  type        = string
  description = "Parent OU ID to create solution under"
}

variable "ou_name" {
  type        = string
  description = "New OU name"
}
