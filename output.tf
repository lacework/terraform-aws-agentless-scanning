output "agentless_scan_ecs_task_role_arn" {
  value       = local.agentless_scan_ecs_task_role_arn
  description = "Output ecs task role arn"
}

output "agentless_scan_ecs_execution_role_arn" {
  value       = local.agentless_scan_ecs_execution_role_arn
  description = "Output ecs executuin role arn"
}

output "agentless_scan_ecs_event_role_arn" {
  value       = local.agentless_scan_ecs_event_role_arn
  description = "Output ecs event role arn"
}
