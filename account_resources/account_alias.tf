resource "aws_iam_account_alias" "alias" {
  provider      = aws.workload
  account_alias = "${local.ou_name}-${terraform.workspace}-${data.aws_caller_identity.current.account_id}"
}
