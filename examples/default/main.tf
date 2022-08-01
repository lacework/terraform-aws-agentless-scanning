provider "lacework" {}

module "lacework_aws_agentless_scanning" {
  source                    = "../.."
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  cloud_integration_name    = "sidekick_from_terraform"
  scan_frequency            = 10
  scan_containers           = true
  scan_host_vulnerabilities = true
}
