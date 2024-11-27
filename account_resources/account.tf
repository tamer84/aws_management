data "external" "get_ou" {
  program = ["bash", "../scripts/getOu.sh", var.parent_ou_id]
}

data "external" "get_account_id" {
  depends_on = [time_sleep.wait_2_minutes]
  program    = ["bash", "../scripts/getAccountId.sh", "${local.email_parts[0]}+${local.ou_name}-${var.environment}@${local.email_parts[1]}"]
}

data "aws_ssoadmin_instances" "sso" {}

data "aws_identitystore_user" "sso_user" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.sso_email
    }
  }
}


locals {
  ou_name     = data.external.get_ou.result.Name
  email_parts = split("@", var.sso_email)
}

# Account file for service catalog provisioning
resource "local_file" "account_params" {

  filename = "./account_params/${local.ou_name}-${var.environment}.json"
  content = templatefile("${path.module}/account_params.template", {
    AccountEmail              = "${local.email_parts[0]}+${local.ou_name}-${var.environment}@${local.email_parts[1]}"
    AccountName               = "${local.ou_name}-${var.environment}"
    ManagedOrganizationalUnit = "${local.ou_name} (${var.parent_ou_id})"
    SSOUserEmail              = var.sso_email
    SSOUserFirstName          = data.aws_identitystore_user.sso_user.name[0].given_name
    SSOUserLastName           = data.aws_identitystore_user.sso_user.name[0].family_name
  })
}

# Enable Control Tower for the new account
resource "null_resource" "create_control_tower_managed_account" {

  depends_on = [local_file.account_params]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
    set -e

    RandomToken=$(echo $(( RANDOM * 999999999999 )) | cut -c 1-13)
    product_id=$(aws servicecatalog search-products-as-admin --filters "FullTextSearch=AWS Control Tower Account Factory" --query "ProductViewDetails[*].ProductViewSummary.ProductId" --output text)
    pa_id=$(aws servicecatalog describe-product-as-admin --id $product_id --region ${var.region} --query "ProvisioningArtifactSummaries[-1].Id" | tr -d '"')
    export CatalogName="CatalogFor-${local.ou_name}-${var.environment}"
    aws servicecatalog provision-product --product-id $product_id --provisioning-artifact-id $pa_id --provision-token $RandomToken --provisioned-product-name $CatalogName --provisioning-parameters file://account_params/${local.ou_name}-${var.environment}.json

    EOF
  }
}

# Wait a few minutes for the account to receive an ID
resource "time_sleep" "wait_2_minutes" {
  depends_on = [null_resource.create_control_tower_managed_account]

  create_duration = "2m"
}
