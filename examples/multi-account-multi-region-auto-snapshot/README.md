# AWS Organizations integration Example w/ Automatic Snapshot Role Deployment

In this example we add Terraform modules to two AWS accounts.

- Scanning account, or Security account, where the scanning infrasturcture is installed.
- The AWS Organizations Management account so that accounts and OUs can be enumerated for each scan.

For the Scanning account, the same process is followed compared to the Single Account Multi-Region example.
However, this Scanning account must know the AWS Organizations management account and set of OUs that will be scanned.
This example also deploys a CloudFormation StackSet in the management account which will automatically deploy the
Snapshot Role to the root, or specified OUs, within the AWS Organization.

For all accounts that will be the target of scanning, the role installed must be known (by name)
to the Scanning account. This example demonstrates how to do this properly.

## Sample Code

### scanning_account.tf

```hcl
provider "lacework" {}

provider "aws" {
  profile = "scanning-account"
  alias   = "scanning-account-usw1"
  region  = "us-west-1"
}

provider "aws" {
  profile = "scanning-account"
  alias   = "scanning-account-usw2"
  region  = "us-west-2"
}

// Create global resources, includes lacework cloud integration
module "lacework_aws_agentless_scanning_global" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.6"

  providers = {
    aws = aws.scanning-account-usw1
  }

  global = true
  organization = {
    monitored_accounts = ["ou-abcd-12345678"]
    management_account = "0001234567890"
  }

  lacework_integration_name = "agentless_org_from_terraform"
}

// Create regional resources in our first region
module "lacework_aws_agentless_scanning_region_usw1" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.6"

  providers = {
    aws = aws.scanning-account-usw1
  }

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

// Create regional resources in our second region
module "lacework_aws_agentless_scanning_region_usw2" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

  providers = {
    aws = aws.scanning-account-usw2
  }

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
```

### management_account.tf

```hcl
provider "aws" {
  profile = "management-account"
  alias   = "management-account-usw1"
  region  = "us-west-1"
}

// Create the required role for the management account.
module "lacework_aws_agentless_management_scanning_role" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

  providers = {
    aws = aws.management-account-usw1
  }

  snapshot_role           = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

resource "aws_cloudformation_stack_set" "snapshot_role" {
  provider = aws.management-account-usw1

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  capabilities     = ["CAPABILITY_NAMED_IAM"]
  description      = "Lacework AWS Agentless Workload Scanning Organization Roles"
  name             = "lacework-agentless-scanning-stackset"
  permission_model = "SERVICE_MANAGED"

  parameters = {
    ExternalId         = module.lacework_aws_agentless_scanning_global.external_id
    ECSTaskRoleArn     = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_task_role_arn
    ResourceNamePrefix = module.lacework_aws_agentless_scanning_global.prefix
    ResourceNameSuffix = module.lacework_aws_agentless_scanning_global.suffix
  }

  template_url = "https://agentless-workload-scanner.s3.amazonaws.com/cloudformation-lacework/latest/snapshot-role.json"
}

resource "aws_cloudformation_stack_set_instance" "snapshot_role" {
  provider = aws.management-account-usw1

  deployment_targets {
    organizational_unit_ids = ["ou-abcd-12345678"]
  }
  region         = "us-east-1"
  stack_set_name = aws_cloudformation_stack_set.snapshot_role.name
}
```
