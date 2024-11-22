terraform {
  backend "s3" {
    key = "management_resources/tfstate.tf"
  }
}
