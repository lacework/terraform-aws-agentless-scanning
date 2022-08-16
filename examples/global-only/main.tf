provider "lacework" {}

provider "aws" {
  region = "us-east-1"
}

// Create only global resources, includes lacework cloud integration
module "lacework_aws_agentless_scanning_global" {
  source = "../.."

  global                    = true
  regional                  = false
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  lacework_integration_name = "sidekick_from_terraform"
  scan_frequency_hours      = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}
