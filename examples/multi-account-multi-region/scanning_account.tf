provider "lacework" {}

provider "aws" {
  // Set this profile to the single AWS Account where the scanning infrastructure will be deployed.
  // profile = "scanning-account"
  alias   = "scanning-account-usw1"
  region  = "us-west-1"
}

provider "aws" {
  // Set this profile to the single AWS Account where the scanning infrastructure will be deployed.
  // profile = "scanning-account"
  alias   = "scanning-account-usw2"
  region  = "us-west-2"
}

// Create global resources, includes lacework cloud integration
module "lacework_aws_agentless_scanning_global" {
  source = "../.."

  providers = {
    aws = aws.scanning-account-usw1
  }

  global       = true
  organization = {
    // This list may contain account IDs, OUs, or the organization root.
    monitored_accounts = ["1234567890", "ou-abcd-12345678"]
    // This account ID must be the AWS organizations "management account".
    // This wil be used to enumerate the accounts and OUs in the list of monitored accounts.
    // This account must also have the snapshot_role installed.
    management_account = "0001234567890"
  }

  lacework_integration_name = "agentless_org_from_terraform"
}

// Create regional resources in our first region
module "lacework_aws_agentless_scanning_region_usw1" {
  source = "../.."

  providers = {
    aws = aws.scanning-account-usw1
  }
  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

// Create regional resources in our second region
module "lacework_aws_agentless_scanning_region_usw2" {
  source = "../.."

  providers = {
    aws = aws.scanning-account-usw2
  }

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
