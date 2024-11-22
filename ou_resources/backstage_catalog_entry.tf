# comment me back in to generate catalog files for Backstage

# resource "local_file" "backstage_catalog" {
#   filename = "../.backstage/ou/${aws_organizations_organizational_unit.ou.id}.yaml"
#
#   content = templatefile("${path.module}/catalog-entry.template", {
#     ou = var.ou_name
#   })
# }