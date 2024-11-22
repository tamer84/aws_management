data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    key = "account_resources/tfstate.tf"
  }
}
