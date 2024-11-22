# comment me back in to generate catalog files for Backstage

# resource "local_file" "backstage_catalog" {
#
#   depends_on = [data.external.get_account_id]
#
#   filename = "../.backstage/accounts/${var.parent_ou_id}-${var.environment}.yaml"
#   content = templatefile("${path.module}/catalog-entry.template", {
#     ou_name     = local.ou_name
#     environment = var.environment
#     region      = var.region
#     account_id  = data.external.get_account_id.result.Id
#     owner       = var.sso_email
#   })
# }