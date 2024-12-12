output "agentless_scan_ecs_task_role_arn" {
  value       = local.agentless_scan_ecs_task_role_arn
  description = "Output ECS task role ARN."
}

output "agentless_scan_ecs_execution_role_arn" {
  value       = local.agentless_scan_ecs_execution_role_arn
  description = "Output ECS execution role ARN."
}

output "agentless_scan_ecs_event_role_arn" {
  value       = local.agentless_scan_ecs_event_role_arn
  description = "Output ECS event role ARN."
}

output "agentless_scan_ecs_cluster_arn" {
  value       = var.regional ? aws_ecs_cluster.agentless_scan_ecs_cluster[0].arn : null
  description = "Output ECS cluster ARN. Useful for managing ECS tasks via AWS CLI/SDK."
}

output "agentless_scan_secret_arn" {
  value       = local.agentless_scan_secret_arn
  description = "AWS SecretsManager Secret ARN for Lacework Account and Token."
}

output "prefix" {
  value       = var.prefix
  description = "Prefix used to add uniqueness to resource names."
}

output "suffix" {
  value       = local.suffix
  description = "Suffix used to add uniqueness to resource names."
}

output "lacework_account" {
  value       = var.lacework_account
  description = "Lacework Account Name for Integration."
}

output "lacework_domain" {
  value       = var.lacework_domain
  description = "Lacework Domain Name for Integration."
}

output "external_id" {
  value       = local.external_id
  description = "External ID used for assuming snapshot creation and cross-account roles."
}

output "lacework_integration_guid" {
  description = "The GUID for the created Lacework integration. This GUID is useful for interacting with this integration from the CLI or API."
  value = (local.is_org_integration ?
    (length(lacework_integration_aws_org_agentless_scanning.lacework_cloud_account) > 0 ?
    lacework_integration_aws_org_agentless_scanning.lacework_cloud_account[0].intg_guid : null) :
    (length(lacework_integration_aws_agentless_scanning.lacework_cloud_account) > 0 ?
  lacework_integration_aws_agentless_scanning.lacework_cloud_account[0].intg_guid : null))
}
