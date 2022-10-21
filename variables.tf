variable "lacework_integration_name" {
  type        = string
  description = "The name of the Lacework cloud account integration."
  default     = "aws-agentless-scanning"
}

variable "global" {
  type        = bool
  default     = false
  description = "Whether or not to create global resources. Defaults to `false`."
}

variable "regional" {
  type        = bool
  default     = false
  description = "Whether or not to create regional resources. Defaults to `false`."
}

variable "snapshot_role" {
  type        = bool
  default     = false
  description = "Whether or not to create an AWS Organization snapshot role. Defaults to `false`."
}

variable "global_module_reference" {
  type = object({
    agentless_scan_ecs_task_role_arn      = string
    agentless_scan_ecs_execution_role_arn = string
    agentless_scan_ecs_event_role_arn     = string
    agentless_scan_secret_arn             = string
    lacework_account                      = string
    lacework_domain                       = string
    external_id                           = string
    prefix                                = string
    suffix                                = string
  })
  default = {
    agentless_scan_ecs_task_role_arn      = ""
    agentless_scan_ecs_execution_role_arn = ""
    agentless_scan_ecs_event_role_arn     = ""
    agentless_scan_secret_arn             = ""
    lacework_account                      = ""
    lacework_domain                       = ""
    external_id                           = ""
    prefix                                = ""
    suffix                                = ""
  }
  description = "A reference to the global lacework_aws_agentless_scanning module for this account."
}

// The following variables are optional and considered advanced configuration.
// Changing values like prefix and suffix might have adverse impact.

variable "image_url" {
  type        = string
  default     = "public.ecr.aws/p5r4i7k7/sidekick:latest"
  description = "The container image url for Lacework sidekick."
}

variable "scan_frequency_hours" {
  type        = number
  description = "How often in hours the scan will run in hours. Defaults to `24`."
  default     = 24
}

variable "filter_query_text" {
  type        = string
  description = "The LQL query text."
  default     = ""
}

variable "scan_containers" {
  type        = bool
  description = "Whether to includes scanning for containers.  Defaults to `true`."
  default     = true
}

variable "scan_host_vulnerabilities" {
  type        = bool
  description = "Whether to includes scanning for host vulnerabilities.  Defaults to `true`."
  default     = true
}

variable "bucket_force_destroy" {
  type        = bool
  default     = true
  description = "Force destroy bucket. (Required when bucket not empty)"
}

variable "lacework_account" {
  type        = string
  description = "The name of the Lacework account with which to integrate."
  default     = ""
}

variable "lacework_domain" {
  type        = string
  description = "The domain of the Lacework account with with to integrate."
  default     = "lacework.net"
}

variable "lacework_aws_account_id" {
  type        = string
  default     = "434813966438"
  description = "The Lacework AWS account that the IAM role will grant access."
}

variable "iam_service_linked_role" {
  type        = bool
  default     = false
  description = "Whether or not to create aws_iam_service_linked_role. Defaults to `false`."
}

variable "secretsmanager_kms_key_id" {
  type        = string
  default     = null
  description = "ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.10.32.0/24"
  description = "VPC CIDR block used by isolate scanning VPC and single subnet."

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.vpc_cidr_block))
    error_message = "The VPC CIDR block must match the regex \"([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))\"."
  }
}

// The following inputs are use for organization (or multi-account) scanning.

variable "organization" {
  type = object({
    management_account = string
    monitored_accounts = list(string)
  })
  default = {
    management_account = ""
    monitored_accounts = []
  }
  description = "Used for multi-account scanning. Set management_account to the AWS Organizations management account. Set the monitored_accounts list to a list of AWS account IDs or OUs."
  validation {
    condition     = (
      length(var.organization.management_account) > 0
        ? length(var.organization.monitored_accounts) > 0 ? true : false
        : length(var.organization.monitored_accounts) == 0
    )
    error_message = "Both management_account and monitored_accounts must be set if either is set."
  }
}

// The following inputs are considered deprecated.
// Instead of providing these directly, the `global_module_reference` should supply them.

variable "agentless_scan_ecs_task_role_arn" {
  type        = string
  default     = ""
  description = "ECS task role ARN. Required input for regional resources. (Deprecated: use global_module_reference)"
}

variable "agentless_scan_ecs_execution_role_arn" {
  type        = string
  default     = ""
  description = "ECS execution role ARN. Required input for regional resources. (Deprecated: use global_module_reference)"
}

variable "agentless_scan_ecs_event_role_arn" {
  type        = string
  default     = ""
  description = "ECS event role ARN. Required input for regional resources. (Deprecated: use global_module_reference)"
}

variable "agentless_scan_secret_arn" {
  type        = string
  default     = ""
  description = "AWS SecretsManager Secret ARN for Lacework Account/Token. *Required if Global is `false` and Regional is `true`*. (Deprecated: use global_module_reference)"
}

variable "prefix" {
  type        = string
  description = "A string to be prefixed to the name of all new resources."
  default     = "lacework-agentless-scanning"

  validation {
    condition     = length(regexall(".*lacework.*", var.prefix)) > 0
    error_message = "The prefix value must include the term 'lacework'."
  }
}

variable "suffix" {
  type        = string
  description = "A string to be appended to the end of the name of all new resources."
  default     = ""

  validation {
    condition     = length(var.suffix) == 0 || length(var.suffix) > 4
    error_message = "If the suffix value is set then it must be at least 4 characters long."
  }
}
