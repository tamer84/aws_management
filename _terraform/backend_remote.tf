resource "local_file" "terraform_backend" {

  filename = "./remote_backend.hcl"
  content = templatefile("backend.template", {
    bucket         = "terraform-${data.aws_caller_identity.current.account_id}"
    region         = var.region
    dynamodb_table = "terraform-lock-${data.aws_caller_identity.current.account_id}"
  })
}