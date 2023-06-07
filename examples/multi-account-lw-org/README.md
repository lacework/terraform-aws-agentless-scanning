# AWS Organizations integration Example

## NOTE: This deployment type is currently in beta.

In this example we add Terraform modules to three AWS accounts.

- Scanning account, or Security account, where the scanning infrasturcture is installed.
- Monitored account where a role used to create snapshots, and access snapshot data, is installed.
- The AWS Organizations Management account so that accounts and OUs can be enumerated for each scan.

For the Scanning Account the same process is followed compared to the Single Account Multi-Region example.
However, this Scanning Account must know the AWS Organizations management account and set of OUs that will be scanned.

For all accounts that will be the target of scanning, the role installed must be known (by name)
to the Scanning Account. This example demonstrates how to do this properly.

## How does this differ from a regular multi-account deployment?

This type of deployment is specifically for environments that are a Lacework Organization and want to have specific aws account data flow into specific sub-lacework accounts. This requires the following:
- The person performing the install must be an OrgAdmin for the Lacework account
- Under provider "lacework" the parameter `organization = true` must be set
- An account mapping must be provided in exactly the same type of setup as shown below. Note: multiple aws_accounts can be specified in the list for each sub-account. However, each aws account can only be specified once.

## Sample Code

### scanning_account.tf

```hcl
provider "lacework" {
    organization = true
}

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
  version = "~> 0.5"

  providers = {
    aws = aws.scanning-account-usw1
  }

  global       = true
  organization = {
    // This list may contain account IDs, OUs, or the organization root.
    monitored_accounts = ["1234567890", "ou-abcd-12345678", "r-abcd"]
    // This account ID must be the AWS organizations "management account".
    // This wil be used to enumerate the accounts and OUs in the list of monitored accounts.
    // This account must also have the snapshot_role installed.
    management_account = "0001234567890"
  }
  org_account_mappings = [{
    default_lacework_account = "main-account"
    mapping = [
      {
        lacework_account = "sub-account-1"
        aws_accounts     = ["123456789011"]
      },
      {
        lacework_account = "sub-account-2"
        aws_accounts     = ["123456789012"]
      }
    ]
  }]

  lacework_integration_name = "agentless_org_from_terraform"
}

// Create regional resources in our first region
module "lacework_aws_agentless_scanning_region_usw1" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

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

### monitored_account.tf

```hcl
provider "aws" {
  profile = "monitored-account"
  alias   = "monitored-account-usw1"
  region  = "us-west-1"
}

// Create the required role for the monitored account.
module "lacework_aws_agentless_monitored_scanning_role" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

  providers = {
    aws = aws.monitored-account-usw1
  }

  snapshot_role           = true
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
```
