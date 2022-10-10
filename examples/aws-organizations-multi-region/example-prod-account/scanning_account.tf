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
  source = "../.."

  providers = {
    aws = aws.scanning-account-usw1
  }

  global = true
  org    = true

  // This list may contain account IDs, OUs, or the organization root.
  monitored_account_list    = ["1234567890", "ou-abcd"] 
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
