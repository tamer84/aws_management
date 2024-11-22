data "aws_iam_openid_connect_provider" "openid_github" {
  url = "https://token.actions.githubusercontent.com"
}

#################
# CICD ROLE
#################
data "aws_iam_policy_document" "cicd_role_assume" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.openid_github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:tamer84/aws_management:*"]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values   = ["https://token.actions.githubusercontent.com"]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/cicd_role"]
    }
  }
}

data "aws_iam_policy_document" "cicd_role_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = ["access-analyzer:*",
      "acm:*",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DeleteTags",
      "autoscaling:DeleteScheduledAction",
      "autoscaling:DescribeScheduledActions",
      "autoscaling:DescribeTags",
      "autoscaling:PutScheduledUpdateGroupAction",
      "cloudformation:*",
      "cloudtrail:Describe*",
      "cloudtrail:Get*",
      "cloudtrail:List*",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:Update*",
      "cloudwatch:*",
      "dynamodb:*",
      "ec2:AcceptVpcPeeringConnection",
      "ec2:AllocateAddress",
      "ec2:AllocateIpamPoolCidr",
      "ec2:AssociateRouteTable",
      "ec2:AssociateVpcCidrBlock",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Create*",
      "ec2:Delete*",
      "ec2:Describe*",
      "ec2:Detach*",
      "ec2:Disassociate*",
      "ec2:GetEbsEncryptionByDefault",
      "ec2:GetIpamPoolAllocations",
      "ec2:Modify*",
      "ec2:ReleaseAddress*",
      "ec2:ReplaceIamInstanceProfileAssociation*",
      "ec2:Revoke*",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:*",
      "eks:*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "elasticfilesystem:TagResource",
      "elasticfilesystem:CreateFileSystem",
      "elasticfilesystem:CreateMountTarget",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeLifecycleConfiguration",
      "elasticfilesystem:DeleteFileSystem",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeMountTargetSecurityGroups",
      "elasticfilesystem:DeleteMountTarget",
      "elasticfilesystem:ModifyMountTargetSecurityGroups",
      "es:*",
      "events:*",
      "grafana:*",
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:AttachUserPolicy",
      "iam:Create*",
      "iam:Delete*",
      "iam:DetachRolePolicy",
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:PutUserPolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:TagOpenIDConnectProvider",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:TagUser",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "kms:*",
      "lambda:*",
      "logs:*",
      "mq:*",
      "osis:*",
      "ram:*",
      "rds:AddTagsToResource",
      "rds:Create*",
      "rds:DeleteDBCluster",
      "rds:DeleteDBInstance",
      "rds:DeleteDBSubnetGroup",
      "rds:Describe*",
      "rds:List*",
      "rds:Modify*",
      "resource-groups:*",
      "route53:*",
      "route53:AssociateVPCWithHostedZone",
      "route53resolver:*",
      "s3:CreateAccessPoint",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "scheduler:*",
      "secretsmanager:*",
      "secretsmanager:GetSecretValue",
      "servicediscovery:CreateService",
      "servicediscovery:DeleteNamespace",
      "servicediscovery:DeleteService",
      "servicediscovery:Get*",
      "servicediscovery:List*",
      "servicediscovery:UpdateService",
      "ses:*",
      "sns:*",
      "ssm:*",
      "sso:CreateManagedApplicationInstance",
      "sso:DeleteManagedApplicationInstance",
      "sso:DescribeRegisteredRegions",
      "sts:GetServiceBearerToken",
      "tag:Get*"
    ]
  }
}


resource "aws_cloudformation_stack_set" "cicd_roles" {
  name = "cicd-roles-${var.ou_name}"
  parameters = {
    CICDAccountId = data.aws_caller_identity.current.account_id
  }
  capabilities     = ["CAPABILITY_NAMED_IAM"]
  permission_model = "SERVICE_MANAGED"
  auto_deployment {
    enabled = true
  }
  template_body = jsonencode({
    Parameters = {
      CICDAccountId = {
        Type        = "String"
        Description = "Enter Account ID of the CICD account for the MU."
      }
    }
    Resources = {
      CICDRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName                 = "cicd_role"
          Path                     = "/service-role/"
          MaxSessionDuration       = 14400
          AssumeRolePolicyDocument = data.aws_iam_policy_document.cicd_role_assume.json
        }
      },
      CICDRolePolicy = {
        Type = "AWS::IAM::Policy"
        Properties = {
          PolicyName : "cicd_role_policy"
          Roles : [
            {
              Ref : "CICDRole"
            }
          ]
          PolicyDocument = data.aws_iam_policy_document.cicd_role_policy.json
        }
      }
    }
  })
  lifecycle {
    ignore_changes = [
      administration_role_arn
    ]
  }
}

resource "aws_cloudformation_stack_set_instance" "cicd_roles" {
  deployment_targets {
    organizational_unit_ids = [aws_organizations_organizational_unit.ou.id]
  }
  region         = "eu-central-1"
  stack_set_name = aws_cloudformation_stack_set.cicd_roles.name
}
