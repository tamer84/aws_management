resource "aws_route53_zone" "zone_workspace" {
  provider = aws.workload
  name     = "${var.environment}.${local.ou_name}.${var.domain}."
  tags = {
    Terraform   = "true"
    nuke_ignore = "true"
  }
}

resource "aws_route53_record" "test_entry" {
  provider = aws.workload
  zone_id  = aws_route53_zone.zone_workspace.id
  name     = "test-dns.${var.environment}.${local.ou_name}.${var.domain}."
  type     = "TXT"
  ttl      = 60
  records  = ["Environment: ${var.environment}, OU: ${local.ou_name}"]
}

data "aws_route53_zone" "zone_apex" {
  name = var.domain
}

resource "aws_route53_record" "ns_entries" {
  zone_id = data.aws_route53_zone.zone_apex.id
  name    = "${var.environment}.${local.ou_name}.${var.domain}."
  type    = "NS"
  ttl     = 60
  records = aws_route53_zone.zone_workspace.name_servers
}
