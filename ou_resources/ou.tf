data "aws_organizations_organization" "org" {}

resource "aws_organizations_organizational_unit" "ou" {
  name      = var.ou_name
  parent_id = data.aws_organizations_organization.org.roots[0].id

  tags = {
    Terraform = "true"
  }
}

# Enable Control Tower for the new OU
resource "null_resource" "enable_control" {

  depends_on = [aws_organizations_organizational_unit.ou]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
    set -e

    IdentityCenterBaseline=$(aws controltower list-baselines --query 'baselines[?name==`IdentityCenterBaseline`].[arn][0][0]' | tr -d '"')
    echo "IdentityCenterBaseline=$IdentityCenterBaseline"
    IdentityCenterBaselineArn=$(aws controltower list-enabled-baselines --query "enabledBaselines[?baselineIdentifier=='$IdentityCenterBaseline'].[arn][0][0]"  | tr -d '"')
    echo "IdentityCenterBaselineArn=$IdentityCenterBaselineArn"
    ControlTowerBaselineArn=$(aws controltower list-baselines --query 'baselines[?name==`AWSControlTowerBaseline`].[arn][0][0]' | tr -d '"')
    echo "ControlTowerBaselineArn=$ControlTowerBaselineArn"
    aws controltower enable-baseline --baseline-identifier "$ControlTowerBaselineArn" --baseline-version 4.0 --target-identifier ${aws_organizations_organizational_unit.ou.arn} --parameters "[{\"key\":\"IdentityCenterEnabledBaselineArn\",\"value\":\"$IdentityCenterBaselineArn\"}]"

    EOF
  }
}
