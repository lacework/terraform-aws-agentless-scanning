provider "lacework" {}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias    = "usw2"
  region = "us-west-2"
}

// Create global and regional resources, includes lacework cloud integration
module "lacework_aws_agentless_scanning" {
  source                    = "../.."
  global                    = true
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  cloud_integration_name    = "sidekick_from_terraform"
  scan_frequency_hours      = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}

// By default only regional resources are created
module "lacework_aws_agentless_scanning" {
  source                    = "../.."
    providers = {
    aws = aws.usw2
  }
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
}