variable "image_url" {
  type        = string
  default     = "public.ecr.aws/p5r4i7k7/sidekick:latest"
  description = "The container image url for Lacework sidekick."
}

variable "resource_name_prefix" {
  type        = string
  description = "A string to be prefixed to the name of all new resources."
  default     = "lacework-agentless-workload-scanning"
}

variable "resource_name_suffix" {
  type        = string
  description = "A string to be appended to the end of the name of all new resources."
  default     = ""
}

variable "lacework_integration_name" {
  type        = string
  description = "The name of the Lacework cloud account integration."
  default     = "aws-agentless-scan"
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

variable "lacework_account" {
  type        = string
  description = "The name of the Lacework account with which to integrate."
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

variable "global" {
  type        = bool
  default     = false
  description = "Whether or not to create global resources. Defaults to `false`."
}

variable "regional" {
  type        = bool
  default     = false
  description = "Whether or not to create regional resources. Defaults to `true`."
}

variable "iam_service_linked_role" {
  type        = bool
  default     = false
  description = "Whether or not to create aws_iam_service_linked_role. Defaults to `false`."
}

variable "agentless_scan_ecs_task_role_arn" {
  type        = string
  default     = ""
  description = "Ecs task role arn. Required input for regional resources"
}

variable "agentless_scan_ecs_execution_role_arn" {
  type        = string
  default     = ""
  description = "Ecs execution role arn. Required input for regional resources"
}

variable "agentless_scan_ecs_event_role_arn" {
  type        = string
  default     = ""
  description = "Ecs event role arn. Required input for regional resources"
}

variable "agentless_scan_secret_arn" {
  type        = string
  default     = ""
  description = "AWS SecretsManager Secret ARN for Lacework Account/Token. *Required if Global is `false` and Regional is `true`*"
}

variable "bucket_force_destroy" {
  type        = bool
  default     = true
  description = "Force destroy bucket (Required when bucket not empty)"
}
