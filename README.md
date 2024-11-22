# Automated Control Tower managed OU and account provisioning
This repo provides an example lightweight alternative to AFT, enabling the provisioning of Control Tower-integrated AWS OUs and accounts via GitHub Actions. 

## Getting started
With Terraform and the aws-cli included in the [ubuntu-2204](https://github.com/actions/runner-images/blob/releases/ubuntu24/20241117/images/ubuntu/Ubuntu2204-Readme.md) GitHub image, only an AWS account is required to proceed.
Clone/Fork this repo and follow the steps below to use it in your own AWS management account.
All you need outside of this repo is an AWS account and an IAMUser/IAMRole with the [AdministratorAccess managed policy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html) attached.

### AWS setup
The repo is designed to work in a Control Tower managed AWS setup.  
The first step would be to [enable Control Tower in your management account](https://docs.aws.amazon.com/controltower/latest/userguide/setting-up.html).

The solution uses CloudFormation StackSets to inject the IAM roles necessary for further automation.  
The second step therefore, is to [enable Cloud Formation trusted access for AWS Organizations](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-activate-trusted-access.html).

Optionally, a Route53 Hosted Zone can be used to allow DNS Delegation to be performed into the newly created accounts.  
For this the account would need a Route53 Hosted Zone configured.  

### Terraform setup
Directory [_terraform](_terraform) contains a simple declaration to provision an S3 bucket and DynamodDB lock table for Terraform.  
The [S3 Bucket](_terraform/main.tf#10) it creates is shared between the Terraform projects, [management_resources](management_resources), [ou_resources](ou_resources) and [account_resources](account_resources).  
A [partial backend](https://developer.hashicorp.com/terraform/language/backend#partial-configuration) file is also [generated](_terraform/backend_remote.tf), and used in the three above mentioned repos, with independent keys.  

This should be applied once by an account user with permissions to assume the AWSAdministratorAccess role.  
The default workspace can be used.  

### Management resources setup
Contains the resources to enable the automation within the **central management account**.
GitHub is [configured as an OpenID Connect (OIDC) Provider](management_resources/oidc.tf), to avoid storage of AWS credentials.
The IAMRole [cicd_role](management_resources/iam.tf#13) grants permissions for Control Tower, Service Catalog, and other automation needs.
Finally, the IAMRole [cicd_role] is added as a principal to the [service catalog Control Tower portfolio](management_resources/servicecatalog.tf#10).

This should be applied once by an account user with permissions to assume the AWSAdministratorAccess role.  
The default workspace can be used.

## Usage
Interacting with the example is via [GitHub Actions](https://github.com/features/actions).  
The two workflows (OU and account) are defined in the [.github/workflows](.github/workflows) directory.  

Each workflow requires [input variables](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs), which are in turn passed to terraform as variables for the provisioning.  
Before Terraform can be executed, the Runner needs to assume the [cicd_role defined in management_resources](management_resources/iam.tf#13).  
For this the GitHub action [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) is used as follows:  

````
    - name: configure aws credentials
    uses: aws-actions/configure-aws-credentials@v4.0.2
    with:
        role-to-assume: arn:aws:iam::${{ env.ACCOUNT }}:role/service-role/cicd_role
        role-session-name: GitHub_to_AWS_via_FederatedOIDC
        aws-region: ${{ env.AWS_REGION }}
````

The role is confirmed using AWS STS:  

````
    - name: Sts GetCallerIdentity
    run: |
      aws sts get-caller-identity
````

Once the IAMRole is assumed terraform can be executed, for example the [account](.github/workflows/account.yml#59):  

````
    - name: Create new Account via Terraform
    run: |
      cd account_resources
      terraform init -backend-config=../_terraform/remote_backend.hcl
      terraform workspace select -or-create $OU-$ENVIRONMENT
      terraform apply --auto-approve -var parent_ou_id=$OU -var domain=$DOMAIN -var environment=$ENVIRONMENT -var sso_email=$OWNER
````

## Control Tower OU and account Terraform projects
The logic in these two directories is based on the AWS YouTube video [Programmatically Create an AWS Account with AWS Control Tower | Amazon Web Services
](https://www.youtube.com/watch?v=LxxQTPdSFgw).  

### ou_resources
This is the project responsible for creating new Control Tower managed OUs.

#### ou.tf
An OU is provisioned using the Terraform resource [aws_organizations_organizational_unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit).  
The provisioned OU is not by default under Control Tower management, it needs to be explicitly brought under management.  
For this, a Terraform [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) resource is declared, to allow usage of [aws-cli](https://aws.amazon.com/cli/).  

#### stackset.tf
The accounts vended later within this new OU will be automatically injected with an IAMRole/IAMRolePolicy to allow automated environment provisioning.  
This is achieved by creating a [CloudFormation StackSet](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html) and setting it to [auto deploy](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-manage-auto-deployment.html) to new accounts within the OU.  

### account_resources
This is the project responsible for creating new Control Tower managed accounts within managed OUs.  

#### account.tf
An account is provisioned using the Terraform [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) resource, to allow usage of [aws-cli servicecatalog commands](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/servicecatalog/provision-product.html).  
Details about the process can be seen in the YouTube video referenced above.  

#### dns.tf
Optionally, [dns.tf](account_resources/dns.tf) creates a dynamic DNS entry for the new account.
This is supported if there is a Route53 Hosted Zone in the management account.  
It should be commented out if your test AWS Management account does not include a DNS Hosted Zone.  

#### account_alias.tf
To demonstrate provisioning resources in the newly vended account using the IAMRole injected via the [OU StackSet](ou_resources/stackset.tf), the account-alias is set.  

````
resource "aws_iam_account_alias" "alias" {
  provider      = aws.workload
  account_alias = "${local.ou_name}-${terraform.workspace}-${data.aws_caller_identity.current.account_id}"
}
````

Notice the provider is specified as *aws.workload*.  

This is defined in the [providers.tf](account_resources/providers.tf) file as follows:

````
provider "aws" {
  region = var.region
  alias  = "workload"
  assume_role {
    # The role ARN for CICD
    role_arn = "arn:aws:iam::${data.external.get_account_id.result.Id}:role/service-role/cicd_role"
  }
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
````

The alias is created by assuming the IAMRole cicd_role within the newly provisioned account.  

### Backstage catalog entries
TBD