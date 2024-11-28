variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "eu-central-1"
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner"
}
