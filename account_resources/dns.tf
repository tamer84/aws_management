resource "aws_route53_zone" "zone_workspace" {

  count = var.domain == "" ? 0 : 1

  provider = aws.workload
  name     = "${var.environment}.${local.ou_name}.${var.domain}."
  tags = {
    Terraform   = "true"
    nuke_ignore = "true"
  }
}

resource "aws_route53_record" "test_entry" {

  count = var.domain == "" ? 0 : 1

  provider = aws.workload
  zone_id  = aws_route53_zone.zone_workspace[0].id
  name     = "test-dns.${var.environment}.${local.ou_name}.${var.domain}."
  type     = "TXT"
  ttl      = 60
  records  = ["Environment: ${var.environment}, OU: ${local.ou_name}"]
}

data "aws_route53_zone" "zone_apex" {

  count = var.domain == "" ? 0 : 1

  name = var.domain
}

resource "aws_route53_record" "ns_entries" {

  count = var.domain == "" ? 0 : 1

  zone_id = data.aws_route53_zone.zone_apex[0].id
  name    = "${var.environment}.${local.ou_name}.${var.domain}."
  type    = "NS"
  ttl     = 60
  records = aws_route53_zone.zone_workspace[0].name_servers
}
