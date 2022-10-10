provider "aws" {
  // Set this profile to the AWS Account profile that will be scanned by the scanning account.
  // profile = "monitored-account"
  alias   = "monitored-account-usw1"
  region  = "us-west-1"
}

// Create the required role for the monitored account.
module "lacework_aws_agentless_monitored_scanning_role" {
  source = "../.."

  providers = {
    aws = aws.monitored-account-usw1
  }

  snapshot_role           = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
