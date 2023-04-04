provider "aws" {
  // Set this profile to the AWS Organizations management account profile.
  // profile = "management-account"
  alias   = "management-account-usw1"
  region  = "us-west-1"
}

// Create the required role for the management account.
module "lacework_aws_agentless_management_scanning_role" {
  source = "../.."

  providers = {
    aws = aws.management-account-usw1
  }

  snapshot_role           = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
