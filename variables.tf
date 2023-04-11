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
  
  validation {
    condition = ( 
      var.scan_frequency_hours == 24 || 
      var.scan_frequency_hours == 12 || 
      var.scan_frequency_hours == 6
    )
    error_message = "The scan frequency must be 6, 12, or 24 hours."
  }
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

variable "bucket_encryption_enabled" {
  type        = bool
  default     = true
  description = "Set this to `false` to disable setting S3 SSE."
}

variable "bucket_sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The encryption algorithm to use for S3 bucket server-side encryption."
}

variable "bucket_sse_key_arn" {
  type        = string
  default     = ""
  description = "The ARN of the KMS encryption key to be used for S3 (required when `bucket_sse_algorithm` is `aws:kms`)."
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

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The ID of an existing AWS VPC to use for deploying regional scan resources.  Must have an Internet Gateway attached."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.10.32.0/24"
  description = "VPC CIDR block used to isolate scanning VPC and single subnet."

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.vpc_cidr_block))
    error_message = "The VPC CIDR block must match the regex \"([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))\"."
  }
}

variable "use_existing_vpc" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing VPC.  The VPC must have a Internet Gateway attached, and `vpc_cidr_block` will be used to create new subnet to isolate scanning resources."
}

variable "use_existing_security_group" {
  type        = bool
  default     = false
  description = "Set this to `true` to use an existing security group for scanning compute resources."
}

variable "security_group_id" {
  type        = string
  default     = ""
  description = "The ID of the security group to use for scanning compute resources.  Must also set `use_existing_security_group` to `true`."
}

variable "use_existing_subnet" {
  type        = bool
  default     = false
  description = "Set this to `true` to use an existing subnet for scanning compute resources."
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "The ID of the subnet to use for scanning compute resources.  Must also set `use_existing_subnet` to `true`."
}

// The following inputs are use for organization (or multi-account) scanning.

variable "org_account_mappings" {
  type = object({
    defaultLaceworkAccountAws = string
    integration_mappings = object({
      lacework_account = string
      aws_accounts     = list(string)
    })
  })
  default     = {}
  description = "Mapping of AWS accounts to Lacework accounts within a Lacework organization"
}

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
    condition = length(var.organization.management_account) > 0 ? (
      alltrue([
        length(var.organization.monitored_accounts) > 0,
        alltrue([
          for account in var.organization.monitored_accounts : can(regex("^ou-[0-9a-z]{4,32}-[a-z0-9]{8,32}$|^[0-9]{8,32}$|^r-[0-9a-z]{4,32}$", account))
        ]),
        can(regex("^[0-9]{8,32}$", var.organization.management_account))
      ])
    ) : length(var.organization.monitored_accounts) == 0
    error_message = "Both management_account and monitored_accounts must be set if either is set; monitored_accounts can only contain AWS Account IDs, OUs, or the Root ID; and the management_account must be an AWS Account ID."
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

variable "use_existing_cross_account_role" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing IAM cross account role"
}

variable "use_existing_task_role" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing IAM task role"
}

variable "use_existing_execution_role" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing IAM execution role"
}

variable "use_existing_event_role" {
  type        = bool
  default     = false
  description = "Set this to true to use an existing IAM event role"
}

variable "cross_account_role_arn" {
  type        = string
  default     = ""
  description = "The IAM cross account role ARN is required when setting use_existing_cross_account_role to true"
}

variable "cross_account_role_name" {
  type        = string
  default     = ""
  description = "The IAM cross account role name. Required to match with cross_account_role_arn if use_existing_cross_account_role is set to true"
}

variable "external_id" {
  type        = string
  default     = ""
  description = "The external ID configured inside the IAM role used for cross account access"
}

variable "additional_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Optional list of additional environment variables passed to the ECS task."
}