data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    key = "ou_resources/tfstate.tf"
  }
}
