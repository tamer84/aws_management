resource "local_file" "backstage_catalog" {
  filename = "../.backstage/ou/${aws_organizations_organizational_unit.ou.id}.yaml"

  content = templatefile("${path.module}/catalog-entry.template", {
    ou    = var.ou_name
    ou_id = aws_organizations_organizational_unit.ou.id
    owner = "guests"
  })
}