provider "lacework" {}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "usw2"
  region = "eu-north-1"
}

// Create global and regional resources, includes lacework cloud integration
module "lacework_aws_agentless_scanning_global" {
  source = "../.."

  global                    = true
  lacework_integration_name = "sidekick_from_terraform"
}

// By default only regional resources are created
module "lacework_aws_agentless_scanning_region_us_west" {
  source = "../.."

  providers = {
    aws = aws.usw2
  }

  regional                              = true
  agentless_scan_ecs_task_role_arn      = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_task_role_arn
  agentless_scan_ecs_execution_role_arn = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_execution_role_arn
  agentless_scan_ecs_event_role_arn     = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_event_role_arn
  agentless_scan_secret_arn             = module.lacework_aws_agentless_scanning_global.agentless_scan_secret_arn
  lacework_account                      = module.lacework_aws_agentless_scanning_global.lacework_account
}
