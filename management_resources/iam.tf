data "aws_caller_identity" "current" {}

data "aws_iam_roles" "sso_role_admin" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "${var.github_owner}-management-${data.aws_caller_identity.current.account_id}"
}

resource "aws_iam_role" "cicd_role" {
  name = "cicd_role"
  path = "/service-role/"

  # 4 hours
  max_session_duration = 14400

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.this.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${var.github_owner}/*:*"
                },
                "ForAllValues:StringEquals": {
                    "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com",
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}

data "aws_iam_policy" "AWSServiceCatalogAdminFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSServiceCatalogAdminFullAccess"
}

resource "aws_iam_role_policy_attachment" "service-catalog-cicd-role-policy-attach" {
  role       = aws_iam_role.cicd_role.name
  policy_arn = data.aws_iam_policy.AWSServiceCatalogAdminFullAccess.arn
}


resource "aws_iam_role_policy" "cicd_assume_role_policy" {
  name = "cicd_assume_role_policy"
  role = aws_iam_role.cicd_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "assumeCICD",
          "Effect" : "Allow",
          "Action" : "sts:*",
          "Resource" : "arn:aws:iam::*:role/service-role/cicd_role"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "cicd_role_policy" {
  name = "cicd_role_policy"
  role = aws_iam_role.cicd_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : "*",
          "Action" : [
            "cloudformation:*",
            "cloudfront:*",
            "cloudtrail:Describe*",
            "cloudtrail:Get*",
            "cloudtrail:List*",
            "cloudtrail:PutEventSelectors",
            "cloudtrail:Update*",
            "cloudwatch:*",
            "dynamodb:*",
            "events:*",
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
            "resource-groups:*",
            "route53:*",
            "s3:CreateAccessPoint",
            "s3:CreateBucket",
            "s3:DeleteBucket",
            "s3:Get*",
            "s3:List*",
            "s3:Put*",
            "scheduler:*",
            "secretsmanager:*",
            "secretsmanager:GetSecretValue",
            "ssm:*",
            "sso:CreateManagedApplicationInstance",
            "sso:DeleteManagedApplicationInstance",
            "sso:DescribeRegisteredRegions",
            "identitystore:GetUserId",
            "identitystore:DescribeUser",
            "sts:GetServiceBearerToken",
            "tag:Get*",
            "Organizations:*",
            "controltower:*",
            "servicecatalog:*",
            "sso:*",
            "*" #without this, account enrolling always fails
          ]
        }
      ]
    }
  )
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetAdministrationRole"
}
