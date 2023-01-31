provider "aws" {
  // Set this profile to the AWS Organizations management account profile.
  // profile = "management-account"
  alias  = "management-account-usw1"
  region = "us-west-1"
}

// Create the required role for the management account.
module "lacework_aws_agentless_management_scanning_role" {
  source = "../.."

  providers = {
    aws = aws.management-account-usw1
  }

  snapshot_role           = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

resource "aws_cloudformation_stack_set" "snapshot_role" {
  provider = aws.management-account-usw1

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  capabilities     = ["CAPABILITY_NAMED_IAM"]
  description      = "Lacework AWS Agentless Workload Scanning Organization Roles"
  name             = "lacework-agentless-scanning-stackset"
  permission_model = "SERVICE_MANAGED"

  parameters = {
    ExternalId         = module.lacework_aws_agentless_scanning_global.external_id
    ECSTaskRoleArn     = module.lacework_aws_agentless_scanning_global.agentless_scan_ecs_task_role_arn
    ResourceNamePrefix = module.lacework_aws_agentless_scanning_global.prefix
    ResourceNameSuffix = module.lacework_aws_agentless_scanning_global.suffix
  }

  template_url = "https://agentless-workload-scanner.s3.amazonaws.com/cloudformation-lacework/latest/snapshot-role.json"

  # Prevent update loop, as per https://github.com/hashicorp/terraform-provider-aws/issues/23464
  lifecycle {
    ignore_changes = [
      administration_role_arn
    ]
  }
}

resource "aws_cloudformation_stack_set_instance" "snapshot_role" {
  provider = aws.management-account-usw1

  deployment_targets {
    organizational_unit_ids = ["ou-abcd-12345678"]
  }
  region         = "us-east-1"
  stack_set_name = aws_cloudformation_stack_set.snapshot_role.name
}
