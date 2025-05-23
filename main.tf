locals {
  suffix                                = length(var.global_module_reference.suffix) > 0 ? var.global_module_reference.suffix : (length(var.suffix) > 0 ? var.suffix : random_id.uniq.hex)
  prefix                                = length(var.global_module_reference.prefix) > 0 ? var.global_module_reference.prefix : var.prefix
  s3_bucket_arn                         = var.global ? (aws_s3_bucket.agentless_scan_bucket[0].arn) : (length(var.global_module_reference.s3_bucket_arn) > 0 ? var.global_module_reference.s3_bucket_arn : "")
  agentless_scan_ecs_task_role_arn      = var.global ? (var.use_existing_task_role ? var.agentless_scan_ecs_task_role_arn : aws_iam_role.agentless_scan_ecs_task_role[0].arn) : (length(var.global_module_reference.agentless_scan_ecs_task_role_arn) > 0 ? var.global_module_reference.agentless_scan_ecs_task_role_arn : var.agentless_scan_ecs_task_role_arn)
  agentless_scan_ecs_execution_role_arn = var.global ? (var.use_existing_execution_role ? var.agentless_scan_ecs_execution_role_arn : aws_iam_role.agentless_scan_ecs_execution_role[0].arn) : (length(var.global_module_reference.agentless_scan_ecs_execution_role_arn) > 0 ? var.global_module_reference.agentless_scan_ecs_execution_role_arn : var.agentless_scan_ecs_execution_role_arn)
  agentless_scan_ecs_event_role_arn     = var.global ? (var.use_existing_event_role ? var.agentless_scan_ecs_event_role_arn : aws_iam_role.agentless_scan_ecs_event_role[0].arn) : (length(var.global_module_reference.agentless_scan_ecs_event_role_arn) > 0 ? var.global_module_reference.agentless_scan_ecs_event_role_arn : var.agentless_scan_ecs_event_role_arn)
  agentless_scan_secret_arn             = var.global ? aws_secretsmanager_secret.agentless_scan_secret[0].id : (length(var.global_module_reference.agentless_scan_secret_arn) > 0 ? var.global_module_reference.agentless_scan_secret_arn : var.agentless_scan_secret_arn)
  lacework_domain                       = length(var.global_module_reference.lacework_domain) > 0 ? var.global_module_reference.lacework_domain : var.lacework_domain
  lacework_account                      = length(var.global_module_reference.lacework_account) > 0 ? var.global_module_reference.lacework_account : (length(var.lacework_account) > 0 ? var.lacework_account : trimsuffix(data.lacework_user_profile.current.url, ".${local.lacework_domain}"))
  external_id                           = length(var.global_module_reference.external_id) > 0 ? var.global_module_reference.external_id : (length(var.external_id) > 0 ? var.external_id : lacework_external_id.aws_iam_external_id[0].v2)
  is_org_integration                    = var.global && length(var.organization.monitored_accounts) > 0 ? true : false
  cross_account_role_arn                = var.use_existing_cross_account_role ? var.cross_account_role_arn : (var.global ? aws_iam_role.agentless_scan_cross_account_role[0].arn : "")
  cross_account_role_name               = length(var.cross_account_role_name) > 0 ? var.cross_account_role_name : "${local.prefix}-cross-account-role-${local.suffix}"

  // Existing VPC abstraction
  internet_gateway_id = var.regional && var.use_internet_gateway ? (var.use_existing_vpc ? data.aws_internet_gateway.selected[0].id : aws_internet_gateway.agentless_scan_gateway[0].id) : ""
  security_group_id   = var.regional ? (var.use_existing_security_group ? var.security_group_id : aws_security_group.agentless_scan_sec_group[0].id) : ""
  subnet_id           = var.regional ? (var.use_existing_subnet ? var.subnet_id : aws_subnet.agentless_scan_public_subnet[0].id) : ""
  vpc_id              = var.regional ? (var.use_existing_vpc ? data.aws_vpc.selected[0].id : aws_vpc.agentless_scan_vpc[0].id) : ""

  default_ecs_task_environment_variables = [
    {
      name  = "STARTUP_PROVIDER"
      value = "AWS"
    },
    {
      name  = "STARTUP_RUNMODE"
      value = "TASK"
    },
    {
      name  = "ECS_SUBNET_ID"
      value = local.subnet_id
    },
    {
      name  = "ECS_SECURITY_GROUP_ID"
      value = "${local.security_group_id}"
    },
    {
      name  = "S3_BUCKET"
      value = "${local.prefix}-bucket-${local.suffix}"
    },
    {
      name  = "LACEWORK_APISERVER"
      value = "${local.lacework_account}.${local.lacework_domain}"
    },
    {
      name  = "SECRET_ARN"
      value = local.agentless_scan_secret_arn
    },
    {
      name  = "LOCAL_STORAGE"
      value = "/tmp"
    },
    {
      name  = "STARTUP_SERVICE"
      value = "ORCHESTRATE"
    },
  ]
  
  version_file   = "${abspath(path.module)}/VERSION"
  module_name    = "terraform-aws-agentless-scanning"
  module_version = fileexists(local.version_file) ? file(local.version_file) : ""
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  count = var.regional && var.use_existing_vpc ? 1 : 0
  id    = var.vpc_id
}

data "aws_internet_gateway" "selected" {
  count = var.regional && var.use_existing_vpc && var.use_internet_gateway ? 1 : 0
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "lacework_user_profile" "current" {}

resource "random_id" "uniq" {
  byte_length = 4
}

// Global - The following are resources created once per Aws Account
// includes the lacework cloud account integration
// Only create global resources if global variable is set to true
// count = var.global ? 1 : 0

resource "lacework_external_id" "aws_iam_external_id" {
  count      = var.use_existing_cross_account_role ? 0 : 1
  csp        = "aws"
  account_id = data.aws_caller_identity.current.account_id
}

resource "lacework_integration_aws_agentless_scanning" "lacework_cloud_account" {
  count                     = var.global && !local.is_org_integration ? 1 : 0
  name                      = var.lacework_integration_name
  scan_frequency            = var.scan_frequency_hours
  query_text                = var.filter_query_text
  scan_containers           = var.scan_containers
  scan_host_vulnerabilities = var.scan_host_vulnerabilities
  scan_multi_volume         = var.scan_multi_volume
  scan_stopped_instances    = var.scan_stopped_instances
  account_id                = data.aws_caller_identity.current.account_id
  bucket_arn                = aws_s3_bucket.agentless_scan_bucket[0].arn
  credentials {
    role_arn    = local.cross_account_role_arn
    external_id = local.external_id
  }
}

resource "lacework_integration_aws_org_agentless_scanning" "lacework_cloud_account" {
  // If var.organization is used then also add monitored accounts and scanning account as the caller.
  count                     = var.global && local.is_org_integration ? 1 : 0
  name                      = var.lacework_integration_name
  scan_frequency            = var.scan_frequency_hours
  query_text                = var.filter_query_text
  scan_containers           = var.scan_containers
  scan_host_vulnerabilities = var.scan_host_vulnerabilities
  scan_stopped_instances    = var.scan_stopped_instances
  scan_multi_volume         = var.scan_multi_volume
  account_id                = data.aws_caller_identity.current.account_id
  bucket_arn                = aws_s3_bucket.agentless_scan_bucket[0].arn
  monitored_accounts        = var.organization.monitored_accounts
  management_account        = var.organization.management_account
  scanning_account          = data.aws_caller_identity.current.account_id
  dynamic "org_account_mappings" {
    for_each = var.org_account_mappings
    content {
      default_lacework_account = org_account_mappings.value["default_lacework_account"]

      dynamic "mapping" {
        for_each = org_account_mappings.value["mapping"]
        content {
          lacework_account = mapping.value["lacework_account"]
          aws_accounts     = mapping.value["aws_accounts"]
        }
      }
    }
  }
  credentials {
    role_arn    = local.cross_account_role_arn
    external_id = local.external_id
  }
}

resource "aws_secretsmanager_secret" "agentless_scan_secret" {
  count      = var.global ? 1 : 0
  name       = "${local.prefix}-secret-${local.suffix}"
  kms_key_id = var.secretsmanager_kms_key_id
  tags       = var.tags
}

resource "aws_secretsmanager_secret_version" "agentless_scan_secret_version" {
  count         = var.global ? 1 : 0
  secret_id     = aws_secretsmanager_secret.agentless_scan_secret[0].id
  secret_string = <<EOF
   {
    "account": "${local.lacework_account}",
    "token": "${local.is_org_integration ? lacework_integration_aws_org_agentless_scanning.lacework_cloud_account[0].server_token : lacework_integration_aws_agentless_scanning.lacework_cloud_account[0].server_token}"
   }
EOF
}

resource "aws_iam_service_linked_role" "agentless_scan_linked_role" {
  count            = var.global && var.iam_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"
  description      = "Role to enable Amazon ECS to manage your cluster."
  tags             = var.tags
}

data "aws_iam_policy_document" "agentless_scan_task_policy_document" {
  count = var.global ? 1 : 0
  statement {
    sid    = "AllowControlOfBucket"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.agentless_scan_bucket[0].arn}",
      "${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"
    ]
  }

  statement {
    sid    = "AllowTagECSCluster"
    effect = "Allow"
    actions = [
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:ListTagsForResource"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "ecs:ResourceTag/LWTAG_SIDEKICK"
      values   = ["*"]
    }
  }

  statement {
    sid    = "AllowListRules"
    effect = "Allow"
    actions = [
      "events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:ListTagsForResource",
      "events:ListRuleNamesByTarget"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowUpdateRule"
    effect = "Allow"
    actions = [
      "events:DisableRule",
      "events:EnableRule",
      "events:PutTargets",
      "events:RemoveTargets"
    ]
    resources = ["arn:aws:events:*:*:rule/${local.prefix}-periodic-trigger-${local.suffix}"]
  }

  statement {
    sid    = "AllowReadFromSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["${aws_secretsmanager_secret.agentless_scan_secret[0].arn}"]
  }

  statement {
    sid       = "DescribeInstances"
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid    = "CreateSnapshots"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CreateSnapshotTags"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSnapshot"]
    }
  }

  statement {
    sid    = "SnapshotManagement"
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute",
      "ebs:ListChangedBlocks",
      "ebs:ListSnapshotBlocks",
      "ebs:GetSnapshotBlock",
      "ebs:CompleteSnapshot"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/LWTAG_SIDEKICK"
      values   = ["*"]
    }
  }

  statement {
    sid    = "TaskManagement"
    effect = "Allow"
    actions = [
      "ecs:RunTask",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:ListTasks",
      "ecs:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = ["arn:aws:ecs:*:*:cluster/${local.prefix}-cluster-${local.suffix}"]
    }
  }

  statement {
    sid    = "SnapshotEncryption"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }
  }

  statement {
    sid    = "SnapshotEncryptionGrants"
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }

  statement {
    sid    = "PassRoleToTasks"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:ResourceTag/LWTAG_SIDEKICK"
      values   = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid    = "AssumeScanRoles"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:ResourceTag/LWTAG_SIDEKICK"
      values   = ["*"]
    }
  }

  statement {
    sid    = "DecodeErrorMessages"
    effect = "Allow"
    actions = [
      "sts:DecodeAuthorizationMessage"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/ecs/${local.prefix}-*"]
  }
}

resource "aws_iam_policy" "agentless_scan_task_policy" {
  count  = var.global ? (var.use_existing_task_role ? 0 : 1) : 0
  name   = "${local.prefix}-task-policy-${local.suffix}"
  policy = data.aws_iam_policy_document.agentless_scan_task_policy_document[0].json
  tags   = var.tags
}

resource "aws_iam_role" "agentless_scan_ecs_task_role" {
  count                = var.global ? (var.use_existing_task_role ? 0 : 1) : 0
  name                 = "${local.prefix}-task-role-${local.suffix}"
  max_session_duration = 43200
  path                 = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-task-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_iam_role_policy_attachment" "agentless_scan_ecs_task_role_policy_attachment" {
  count                = var.global ? (var.use_existing_task_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_ecs_task_role[0].name
  policy_arn = aws_iam_policy.agentless_scan_task_policy[0].arn
}

resource "aws_iam_role" "agentless_scan_ecs_event_role" {
  count                = var.global ? (var.use_existing_event_role ? 0 : 1) : 0
  name                 = "${local.prefix}-task-event-role-${local.suffix}"
  max_session_duration = 3600
  path                 = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-task-event-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_iam_role_policy_attachment" "agentless_scan_ecs_event_role_policy_attachment" {
  count                = var.global ? (var.use_existing_task_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_ecs_event_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_role" "agentless_scan_ecs_execution_role" {
  count                = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
  name                 = "${local.prefix}-task-execution-role-${local.suffix}"
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-task-execution-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_iam_policy" "agentless-allow-cloudwatch-policy" {
 count  = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
 name   = "${local.prefix}-cloudwatch-policy-${local.suffix}"

  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "AllowLoggingToCloudWatch"
          Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:log-group:/ecs/${local.prefix}-*"
        },
      ]
    })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "agentless_scan_ecs_execution_role_policy_attachment" {
  count      = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_ecs_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "agentless_scan_allow_cloudwatch_policy_attachment" {
  count      = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_ecs_execution_role[0].name
  policy_arn = aws_iam_policy.agentless-allow-cloudwatch-policy[0].arn
}


resource "aws_iam_role" "agentless_scan_snapshot_role" {
  count                = var.snapshot_role ? 1 : 0
  name                 = "${local.prefix}-snapshot-role-${local.suffix}"
  max_session_duration = 43200
  path                 = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = local.agentless_scan_ecs_task_role_arn
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_id
          }
        }
      },
    ]
  })

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-task-execution-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_iam_policy" "agentless_snapshot_policy" {
 count  = var.snapshot_role ? 1 : 0
 name   = "${local.prefix}-snapshot-policy-${local.suffix}"

  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "DescribeInstances"
          Action   = ["ec2:Describe*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid      = "CreateSnapshots"
          Action   = ["ec2:CreateSnapshot"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid    = "CreateSnapshotTags"
          Effect = "Allow"
          Action = [
            "ec2:CreateTags"
          ]
          Resource = ["*"]
          Condition = {
            StringEquals = {
              "ec2:CreateAction" = "CreateSnapshot"
            }
          }
        },
        {
          Sid = "SnapshotManagement"
          Action = [
            "ec2:DeleteSnapshot",
            "ec2:ModifySnapshotAttribute",
            "ec2:ResetSnapshotAttribute",
            "ebs:ListChangedBlocks",
            "ebs:ListSnapshotBlocks",
            "ebs:GetSnapshotBlock",
            "ebs:CompleteSnapshot"
          ]
          Effect   = "Allow"
          Resource = "*",
          Condition = {
            StringLike = {
              "aws:ResourceTag/LWTAG_SIDEKICK" = "*"
            }
          }
        },
        {
          Sid    = "SnapshotEncryption"
          Effect = "Allow"
          Action = [
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*"
          ]
          Resource = "*"
          Condition = {
            StringLike = {
              "kms:ViaService" = "ec2.*.amazonaws.com"
            }
          }
        },
        {
          Sid    = "SnapshotEncryptionGrants"
          Effect = "Allow"
          Action = [
            "kms:CreateGrant"
          ]
          Resource = "*"
          Condition = {
            StringLike = {
              "kms:ViaService" = "ec2.*.amazonaws.com"
            }
            Bool = {
              "kms:GrantIsForAWSResource" = "true"
            }
          }
        },
        {
          Sid      = "OrgPermissions"
          Action   = ["organizations:Describe*", "organizations:List*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "agentless_scan_snapshot_policy_attachment" {
  count      = var.snapshot_role ? 1 : 0
  role       = aws_iam_role.agentless_scan_snapshot_role[0].name
  policy_arn = aws_iam_policy.agentless_snapshot_policy[0].arn
}

resource "aws_s3_bucket" "agentless_scan_bucket" {
  count  = var.global ? 1 : 0
  bucket = "${local.prefix}-bucket-${local.suffix}"

  force_destroy = var.bucket_force_destroy

  tags = merge(var.tags, var.bucket_tags, {
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_s3_bucket_ownership_controls" "agentless_scan_bucket_ownership_controls" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id

  rule {
    object_ownership = "ObjectWriter"
  }
}


resource "aws_s3_bucket_public_access_block" "agentless_scan_bucket_public_access_block" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "agentless_scan_bucket_encryption" {
  count  = var.global && var.bucket_encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.bucket_sse_key_arn
      sse_algorithm     = var.bucket_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "agentless_scan_bucket_lifecyle" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id

  rule {
    id = "Work"
    expiration {
      days = 7
    }
    filter {
      prefix = "sidekick/work/"
    }
    status = "Enabled"
  }

  rule {
    id = "All"
    expiration {
      days = 30
    }
    filter {
      prefix = "sidekick/"
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "agentless_scan_bucket_policy" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id
  policy = data.aws_iam_policy_document.agentless_scan_bucket_policy[0].json
}

data "aws_iam_policy_document" "agentless_scan_bucket_policy" {
  count = var.global ? 1 : 0
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    actions = [
      "s3:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.agentless_scan_bucket[0].arn,
      "${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "ForceSSEOnlyUploads"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"
    ]
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  # To make this more restrictive, we could force the types of SSE.
  # Without this, we still Deny when SSE is Null (see above statement).
  # statement {
  #   sid    = "ForceSSEAES256OnlyUploads"
  #   effect = "Deny"
  #   actions = [
  #     "s3:PutObject"
  #   ]
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   resources = [
  #     "${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"
  #   ]
  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "s3:x-amz-server-side-encryption"
  #     values   = ["AES256"]
  #   }
  # }
}

data "aws_iam_policy_document" "agentless_scan_cross_account_policy" {
  count = var.global ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.lacework_aws_account_id}:role/lacework-platform"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.external_id]
    }
  }
}

data "aws_iam_policy_document" "cross_account_inline_policy_bucket" {
  count = var.global ? 1 : 0
  statement {
    sid    = "ListAndTagBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging"
    ]
    resources = [aws_s3_bucket.agentless_scan_bucket[0].arn]
  }

  statement {
    sid    = "PutGetDeleteObjectsInBucket"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"]
  }
}

data "aws_iam_policy_document" "cross_account_inline_policy_ecs" {
  count = var.global ? 1 : 0
  statement {
    sid    = "AllowEcsStopTask"
    effect = "Allow"
    actions = [
      "ecs:StopTask",
      "ecs:RunTask"
    ]
    resources = [
      "arn:aws:ecs:*:*:task/${local.prefix}-cluster-${local.suffix}/*",
      "arn:aws:ecs:*:*:task-definition/${local.prefix}-cluster-${local.suffix}:*",
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = ["arn:aws:ecs:*:*:cluster/${local.prefix}-cluster-${local.suffix}"]
    }
  }

  statement {
    sid    = "AllowEcsTaskManagementPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/${local.prefix}-task-execution-role-${local.suffix}",
      "arn:aws:iam::*:role/${local.prefix}-task-role-${local.suffix}",
    ]
  }

  statement {
    sid    = "AllowEcsTaskSubnetLookup"
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets"
    ]
    resources = ["arn:aws:ec2:*:*:subnet/subnet-*"]
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/LWTAG_SIDEKICK"
      values   = ["*"]
    }
  }
}

resource "aws_iam_role" "agentless_scan_cross_account_role" {
  count                = var.global ? (var.use_existing_cross_account_role ? 0 : 1) : 0
  name                 = local.cross_account_role_name
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.agentless_scan_cross_account_policy[0].json

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-cross-account-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_iam_policy" "agentless_s3_write_policy" {
 count  = var.global ? (var.use_existing_cross_account_role ? 0 : 1) : 0
 name   = "${local.prefix}-s3-write-policy-${local.suffix}"

  policy = data.aws_iam_policy_document.cross_account_inline_policy_bucket[0].json

  tags = var.tags
}

resource "aws_iam_policy" "agentless_ecs_task_mgmt_policy" {
 count  = var.global ? (var.use_existing_cross_account_role ? 0 : 1) : 0
 name   = "${local.prefix}-ecs-task-mgmt-${local.suffix}"

 policy = data.aws_iam_policy_document.cross_account_inline_policy_ecs[0].json

 tags = var.tags
}

resource "aws_iam_role_policy_attachment" "agentless_s3_write_policy_attachment" {
  count      = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_cross_account_role[0].name
  policy_arn = aws_iam_policy.agentless_s3_write_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "agentless_ecs_task_mgmt_policy_attachment" {
  count      = var.global ? (var.use_existing_execution_role ? 0 : 1) : 0
  role       = aws_iam_role.agentless_scan_cross_account_role[0].name
  policy_arn = aws_iam_policy.agentless_ecs_task_mgmt_policy[0].arn
}

// Regional - The following are resources created once per Aws Region
// Only create regional resources if regional variable is set to true
// count = var.regional ? 1 : 0

resource "aws_vpc" "agentless_scan_vpc" {
  count                = var.regional && !var.use_existing_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-vpc"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_flow_log" "agentless_scan_vpc_flow_log" {
  count        = var.regional && var.use_aws_flow_log && !var.use_existing_vpc ? 1 : 0
  vpc_id       = local.vpc_id
  traffic_type = "REJECT"

  # Send logs to manged S3 bucket.
  log_destination_type = "s3"
  log_destination     = "${local.s3_bucket_arn}/sidekick/flow-logs/"

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-vpc"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_default_network_acl" "default" {
  count                  = var.regional && !var.use_existing_vpc ? 1 : 0
  default_network_acl_id = aws_vpc.agentless_scan_vpc[0].default_network_acl_id
  subnet_ids             = [aws_subnet.agentless_scan_public_subnet[0].id]
  tags                   = var.tags

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = 6
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 3388
  }

  ingress {
    protocol   = 6
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3390
    to_port    = 65535
  }
}

resource "aws_route_table" "agentless_scan_route_table" {
  count  = var.regional && !var.use_existing_subnet ? 1 : 0
  vpc_id = local.vpc_id
  tags = merge(var.tags, {
    Name                     = "${local.prefix}-vpc"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_route_table_association" "agentless_scan_route_table_association" {
  count          = var.regional && !var.use_existing_subnet ? 1 : 0
  subnet_id      = aws_subnet.agentless_scan_public_subnet[0].id
  route_table_id = aws_route_table.agentless_scan_route_table[0].id
}

resource "aws_internet_gateway" "agentless_scan_gateway" {
  count  = var.regional && !var.use_existing_vpc ? 1 : 0
  vpc_id = local.vpc_id

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-gw"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_route" "agentless_scan_route" {
  count                  = var.regional && !var.use_existing_subnet ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.internet_gateway_id
  route_table_id         = aws_route_table.agentless_scan_route_table[0].id
}

resource "aws_default_security_group" "default" {
  count  = var.regional && !var.use_existing_vpc ? 1 : 0
  vpc_id = local.vpc_id
  tags   = var.tags

  ingress = []
  egress  = []
}

resource "aws_security_group" "agentless_scan_sec_group" {
  count       = var.regional && !var.use_existing_security_group ? 1 : 0
  name        = "${local.prefix}-security-group"
  description = "A security group to allow Lacework Agentless Workload Scanning communication."
  vpc_id      = local.vpc_id
  tags        = var.tags

  ingress = []

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "agentless_scan_public_subnet" {
  count                   = var.regional && !var.use_existing_subnet ? 1 : 0
  vpc_id                  = local.vpc_id
  cidr_block              = var.vpc_cidr_block
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-vpc"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })
}

resource "aws_ecs_cluster_capacity_providers" "agentless_scan_capacity_providers" {
  count              = var.regional ? 1 : 0
  cluster_name       = aws_ecs_cluster.agentless_scan_ecs_cluster[0].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_ecs_cluster" "agentless_scan_ecs_cluster" {
  count = var.regional ? 1 : 0
  name  = "${local.prefix}-cluster-${local.suffix}"

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-cluster"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_ecs_task_definition" "agentless_scan_task_definition" {
  count  = var.regional ? 1 : 0
  family = aws_ecs_cluster.agentless_scan_ecs_cluster[0].name
  // if global is true, use created resource, else use input from global output
  task_role_arn = local.agentless_scan_ecs_task_role_arn
  // if global is true, use created resource, else use input from global output
  execution_role_arn       = local.agentless_scan_ecs_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192

  tags = merge(var.tags, {
    Name                     = "${local.prefix}-task-definition"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  })

  container_definitions = jsonencode([
    {
      name      = "sidekick"
      image     = var.image_url
      essential = true
      cpu       = 4096
      memory    = 8192
      environment = setunion(
        local.default_ecs_task_environment_variables,
        var.additional_environment_variables,
        [
          {
            name  = "ECS_CLUSTER_ARN"
            value = aws_ecs_cluster.agentless_scan_ecs_cluster[0].arn
          },
        ]
      )
      linuxParameters = {
        capabilities = {
          Add  = ["SYS_PTRACE"]
          Drop = []
        }
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster[0].name}"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = "ecs"
        }
      }

      mountPoints    = []
      portMappings   = []
      systemControls = []
      volumesFrom    = []
    }
  ])
}

resource "aws_cloudwatch_log_group" "agentless_scan_log_group" {
  count             = var.regional ? 1 : 0
  name              = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster[0].name}"
  retention_in_days = 14
  # the KMS will need to allow the log group to use it.
  # See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
  kms_key_id        = var.secretsmanager_kms_key_id
  tags              = var.tags
}

resource "aws_cloudwatch_event_rule" "agentless_scan_event_rule" {
  depends_on = [
    aws_ecs_cluster.agentless_scan_ecs_cluster,
    aws_ecs_task_definition.agentless_scan_task_definition
  ]

  count               = var.regional ? 1 : 0
  name                = "${local.prefix}-periodic-trigger-${local.suffix}"
  schedule_expression = "rate(1 hour)"
  event_bus_name      = "default"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "agentless_scan_event_target" {
  count     = var.regional ? 1 : 0
  target_id = "sidekick"
  rule      = aws_cloudwatch_event_rule.agentless_scan_event_rule[0].name
  arn       = aws_ecs_cluster.agentless_scan_ecs_cluster[0].arn
  // if global is true, use created resource, else use input from global output
  role_arn = local.agentless_scan_ecs_event_role_arn
  input    = "{\"containerOverrides\":[{\"name\":\"sidekick\",\"environment\":[{\"name\":\"STARTUP_SERVICE\",\"value\":\"ORCHESTRATE\"}]}]}"
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.agentless_scan_task_definition[0].arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets          = [local.subnet_id]
      security_groups  = [local.security_group_id]
      assign_public_ip = true
    }

    tags = merge(var.tags, {
      LWTAG_SIDEKICK           = "1"
      LWTAG_LACEWORK_AGENTLESS = "1"
    })
  }
}

// Complex input validation checks.

resource "null_resource" "check_organization_requires_global_input" {
  count = length(var.organization.monitored_accounts) > 0 ? (var.global ? 0 : "Error: When var.organization is used then var.global must also = true") : 0
}

data "lacework_metric_module" "lwmetrics" {
  name    = local.module_name
  version = local.module_version
}
