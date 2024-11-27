<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.75.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.75.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.cicd_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.cicd_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_organizations_organizational_unit.ou](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [local_file.backstage_catalog](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.enable_control](https://registry.terraform.io/providers/hashicorp/null/3.2.2/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_openid_connect_provider.openid_github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.cicd_role_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cicd_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nuke_role_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nuke_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ou_name"></a> [ou\_name](#input\_ou\_name) | New OU name | `string` | n/a | yes |
| <a name="input_parent_ou_id"></a> [parent\_ou\_id](#input\_parent\_ou\_id) | Parent OU ID to create solution under | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy resources in | `string` | `"eu-central-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ou_catalog_entry"></a> [ou\_catalog\_entry](#output\_ou\_catalog\_entry) | n/a |
| <a name="output_ou_org_id"></a> [ou\_org\_id](#output\_ou\_org\_id) | n/a |
<!-- END_TF_DOCS -->