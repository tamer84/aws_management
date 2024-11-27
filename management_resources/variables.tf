variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "eu-central-1"
}

variable "organization" {
  type        = string
  description = "Organization name"
}

variable "repo_slug" {
  type        = string
  description = "GitHub repo slug"
}
