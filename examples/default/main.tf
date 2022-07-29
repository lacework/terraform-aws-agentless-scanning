provider "lacework" {}

module "lacework_aws_agentless_scanning" {
  source = "../.."
}
