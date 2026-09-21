# Use Existing IAM Roles Example

### versions.tf
```hcl
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    lacework = {
      source  = "lacework/lacework"
      version = "~> 2.0"
    }
  }
}
```

### main.tf
```hcl

provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

module "lacework_aws_agentless_scanning_singleregion" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5.0"

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

  suffix = "abc123"
}
```
In this example the **global** and **regional** resources are added in a single region.
Global resources include the single per-account resources like S3 bucket.
Regional resources include VPC, ECS cluster.
Roles for both global and regional resources are supplied. This assumes that the roles were created manually (outside Terraform) with the correct policies attached.
A suffix is applied to predict what resource ARNs will be, so that the manually created IAM policies created ahead of time will point to the correct resources when Terraform builds the resources.

Refer to the *use-existing-iam-roles-multi-region* example for adding scanning to multiple regions.
