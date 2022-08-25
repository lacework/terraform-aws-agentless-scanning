# Default Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

module "lacework_aws_agentless_scanning_global" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  global                    = true
  lacework_integration_name = "sidekick_from_terraform"
}

// Create regional resources in our first region
module "lacework_aws_agentless_scanning_region" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  regional                              = true
  agentless_scan_ecs_task_role_arn      = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_task_role_arn
  agentless_scan_ecs_execution_role_arn = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_execution_role_arn
  agentless_scan_ecs_event_role_arn     = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_event_role_arn
  agentless_scan_secret_arn             = module.lacework_aws_agentless_scanning_global.agentless_scan_secret_arn
  lacework_account                      = module.lacework_aws_agentless_scanning_global.lacework_account
  prefix                                = module.lacework_aws_agentless_scanning_global.prefix
  suffix                                = module.lacework_aws_agentless_scanning_global.suffix
}

// Create regional resources in our second region
module "lacework_aws_agentless_scanning_region_usw2" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  providers = {
    aws = aws.usw2
  }

  regional                              = true
  agentless_scan_ecs_task_role_arn      = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_task_role_arn
  agentless_scan_ecs_execution_role_arn = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_execution_role_arn
  agentless_scan_ecs_event_role_arn     = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_event_role_arn
  agentless_scan_secret_arn             = module.lacework_aws_agentless_scanning_global.agentless_scan_secret_arn
  lacework_account                      = module.lacework_aws_agentless_scanning_global.lacework_account
  prefix                                = module.lacework_aws_agentless_scanning_global.prefix
  suffix                                = module.lacework_aws_agentless_scanning_global.suffix
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include a VPC, and ECS cluster.
A "one to many" relationship between **global** and **regional** exists so that
scanning and snapshot usage avoids cross-region data transfer.

In a situation where multiple regions are scanned, the **global** resources should
be added once, and the **regional** should be added to each region being scanned.
