# Default Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias    = "usw2"
  region = "us-west-2"
}

module "lacework_agentless_global" {
  source                    = "lacework/agentless-scanning/aws"
  version                   = "~> 0.1"
  global                    = true
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  lacework_integration_name = "sidekick_from_terraform"
  scan_frequency_hours      = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}

module "lacework_aws_agentless_scanning_regional" {
  source                    = "../.."
    providers = {
    aws = aws.usw2
  }
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  agentless_scan_ecs_task_role_arn = module.lacework_agentless_global.agentless_scan_ecs_task_role_arn
  agentless_scan_ecs_execution_role_arn = module.lacework_agentless_global.agentless_scan_ecs_execution_role_arn
  agentless_scan_ecs_event_role_arn = module.lacework_agentless_global.agentless_scan_ecs_event_role_arn
}
```
