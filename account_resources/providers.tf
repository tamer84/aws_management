provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform = "true"
      OU        = var.parent_ou_id
    }
  }
}

provider "aws" {
  region = var.region
  alias  = "workload"
  assume_role {
    # The role ARN for CICD
    role_arn = coalesce("arn:aws:iam::${data.external.get_account_id.result.Id}:role/service-role/cicd_role", null)
  }
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
