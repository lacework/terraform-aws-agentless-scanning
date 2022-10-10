resource "lacework_integration_aws_org_agentless_scanning" "lacework_cloud_account" {
  // If org == true then also add monitored accounts and scanning account as the caller
  count                     = var.global ? 1 : 0
  name                      = var.lacework_integration_name
  scan_frequency            = var.scan_frequency_hours
  query_text                = var.filter_query_text
  scan_containers           = var.scan_containers
  scan_host_vulnerabilities = var.scan_host_vulnerabilities
  account_id                = data.aws_caller_identity.current.account_id
  bucket_arn                = aws_s3_bucket.agentless_scan_bucket[0].arn
  credentials {
    role_arn    = aws_iam_role.agentless_scan_cross_account_role[0].arn
    external_id = random_string.external_id.result
  }
}