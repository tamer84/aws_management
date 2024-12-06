# Can only be run by a management account admin
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "Management"
    }
  }
}