provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

// Create global resources, includes lacework cloud integration.
// This will also create regional resources too.
// If scanning should occur on multiple regions then refer to the 'default' example.
module "lacework_aws_agentless_scanning_singleregion" {
  source = "../.."

  global                    = true
  regional                  = true
  lacework_integration_name = "sidekick_from_terraform"
}
