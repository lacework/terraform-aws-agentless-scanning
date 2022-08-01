variable "image_url" {
  type        = string
  default     = "public.ecr.aws/p5r4i7k7/sidekick:latest"
  description = "Container Image"
}
variable "resource_name_prefix" {
  type        = string
  description = ""
}
variable "resource_name_suffix" {
  type        = string
  description = ""
}

variable "cloud_integration_name" {
  type        = string
  description = ""
}

variable "scan_frequency" {
  type        = number
  description = ""
}

variable "query_text" {
  type        = string
  description = ""
  default     = ""
}

variable "scan_containers" {
  type        = bool
  description = ""
}
variable "scan_host_vulnerabilities" {
  type        = string
  description = ""
}

variable "lacework_aws_account_id" {
  type        = string
  default     = "434813966438"
  description = "The Lacework AWS account that the IAM role will grant access"
}
