provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

// Create global resources and regional resouces in a single region, includes lacework cloud integration.
// Use pre-existing IAM roles for the cross-account, ecs event, ecs task execution, and ecs task roles
module "lacework_aws_agentless_scanning_singleregion" {
  source = "../.."

  global                    = true
  regional                  = true

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
