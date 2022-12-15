provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

// Create global resouces, includes lacework cloud integration
// Use existing cross account IAM role
module "lacework_aws_agentless_scanning_global" {
  source = "../.."

  global                    = true

  use_existing_cross_account_role = true
  use_existing_event_role         = true
  use_existing_execution_role     = true
  use_existing_task_role          = true

  cross_account_role_arn                = "arn:aws:iam::123456789012:role/my-lacework-ca-role"
  external_id                           = "AbC123dEf456"
  agentless_scan_ecs_task_role_arn      = "arn:aws:iam::123456789012:role/my-lacework-ecs-task-role"
  agentless_scan_ecs_execution_role_arn = "arn:aws:iam::123456789012:role/my-lacework-ecs-execution-role"
  agentless_scan_ecs_event_role_arn     = "arn:aws:iam::123456789012:role/my-lacework-ecs-event-role"

  // Suffix can be used to "predict" what resouce ARNs will be when manually creating IAM policies ahead of time
  suffix = "abc123"
}

// Create regional resouces in our first region
module "lacework_aws_agentless_scanning_regional_1" {
  source                    = "../.."

  regional                  = true
  global_module_reference   = module.lacework_aws_agentless_scanning_global
}

// Create regional resouces in our second region
module "lacework_aws_agentless_scanning_regional_2" {
  source                    = "../.."

  providers = {
    aws = aws.usw2
  }

  regional                  = true
  global_module_reference   = module.lacework_aws_agentless_scanning_global
}
