<a href="https://lacework.com"><img src="https://techally-content.s3-us-west-1.amazonaws.com/public-content/lacework_logo_full.png" width="600"></a>

# terraform-aws-agentless-scanning

[![GitHub release](https://img.shields.io/github/release/lacework/terraform-<PROVIDER>-<NAME>.svg)](https://github.com/lacework/terraform-<PROVIDER>-<NAME>/releases/)
[![Codefresh build status]( https://g.codefresh.io/api/badges/pipeline/lacework/terraform-modules%2Ftest-compatibility?type=cf-1&key=eyJhbGciOiJIUzI1NiJ9.NWVmNTAxOGU4Y2FjOGQzYTkxYjg3ZDEx.RJ3DEzWmBXrJX7m38iExJ_ntGv4_Ip8VTa-an8gBwBo)]( https://g.codefresh.io/pipelines/edit/new/builds?id=607e25e6728f5a6fba30431b&pipeline=test-compatibility&projects=terraform-modules&projectId=607db54b728f5a5f8930405d)

A Terraform Module to configure the Lacework Agentless Scanner.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_lacework"></a> [lacework](#requirement\_lacework) | ~> 0.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_lacework"></a> [lacework](#provider\_lacework) | ~> 0.23 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.agentless_scan_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.agentless_scan_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.agentless_scan_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.agentless_scan_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.agentless_scan_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_task_definition.agentless_scan_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.agentless_scan_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agentless_scan_cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.agentless_scan_ecs_event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.agentless_scan_ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.agentless_scan_ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_service_linked_role.agentless_scan_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_internet_gateway.agentless_scan_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.agentless_scan_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.agentless_scan_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.agentless_scan_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.agentless_scan_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.agentless_scan_bucket_lifecyle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.agentless_scan_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.versioning_example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.agentless_scan_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.agentless_scan_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.agentless_scan_vpc_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.agentless_scan_public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.agentless_scan_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [lacework_integration_aws_agentless_scanning.lacework_cloud_account](https://registry.terraform.io/providers/lacework/lacework/latest/docs/resources/integration_aws_agentless_scanning) | resource |
| [random_string.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.agentless_scan_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agentless_scan_cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agentless_scan_task_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_inline_policy_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_inline_policy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agentless_scan_ecs_event_role_arn"></a> [agentless\_scan\_ecs\_event\_role\_arn](#input\_agentless\_scan\_ecs\_event\_role\_arn) | Ecs event role arn. Required input for regional resources | `string` | `""` | no |
| <a name="input_agentless_scan_ecs_execution_role_arn"></a> [agentless\_scan\_ecs\_execution\_role\_arn](#input\_agentless\_scan\_ecs\_execution\_role\_arn) | Ecs execution role arn. Required input for regional resources | `string` | `""` | no |
| <a name="input_agentless_scan_ecs_task_role_arn"></a> [agentless\_scan\_ecs\_task\_role\_arn](#input\_agentless\_scan\_ecs\_task\_role\_arn) | Ecs task role arn. Required input for regional resources | `string` | `""` | no |
| <a name="input_filter_query_text"></a> [filter\_query\_text](#input\_filter\_query\_text) | The LQL query text. | `string` | `""` | no |
| <a name="input_global"></a> [global](#input\_global) | Whether or not to create global resources. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | The container image url for Lacework sidekick. | `string` | `"public.ecr.aws/p5r4i7k7/sidekick:latest"` | no |
| <a name="input_lacework_aws_account_id"></a> [lacework\_aws\_account\_id](#input\_lacework\_aws\_account\_id) | The Lacework AWS account that the IAM role will grant access. | `string` | `"434813966438"` | no |
| <a name="input_lacework_integration_name"></a> [lacework\_integration\_name](#input\_lacework\_integration\_name) | The name of the Lacework cloud account integration. | `string` | `"aws-agentless-scan"` | no |
| <a name="input_regional"></a> [regional](#input\_regional) | Whether or not to create regional resources. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | A string to be prefixed to the name of all new resources. | `string` | n/a | yes |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | A string to be appended to the end of the name of all new resources. | `string` | n/a | yes |
| <a name="input_scan_containers"></a> [scan\_containers](#input\_scan\_containers) | Whether to includes scanning for containers. | `bool` | `false` | no |
| <a name="input_scan_frequency_hours"></a> [scan\_frequency\_hours](#input\_scan\_frequency\_hours) | How often in hours the scan will run in hours. Defaults to `24`. | `number` | `24` | no |
| <a name="input_scan_host_vulnerabilities"></a> [scan\_host\_vulnerabilities](#input\_scan\_host\_vulnerabilities) | Whether to includes scanning for host vulnerabilities. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agentless_scan_ecs_event_role_arn"></a> [agentless\_scan\_ecs\_event\_role\_arn](#output\_agentless\_scan\_ecs\_event\_role\_arn) | Output ecs event role arn |
| <a name="output_agentless_scan_ecs_execution_role_arn"></a> [agentless\_scan\_ecs\_execution\_role\_arn](#output\_agentless\_scan\_ecs\_execution\_role\_arn) | Output ecs executuin role arn |
| <a name="output_agentless_scan_ecs_task_role_arn"></a> [agentless\_scan\_ecs\_task\_role\_arn](#output\_agentless\_scan\_ecs\_task\_role\_arn) | Output ecs task role arn |
