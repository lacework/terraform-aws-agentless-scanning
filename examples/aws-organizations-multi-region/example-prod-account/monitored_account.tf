provider "lacework" {}

provider "aws" {
  profile = "monitored-account"
  alias   = "monitored-account-usw1"
  region  = "us-west-1"
}

// Create the required role for the scanning account.
module "lacework_aws_agentless_scanning_role" {
  source = "../.."

  providers = {
    aws = aws.monitored-account-usw1
  }

  snapshot_role           = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
