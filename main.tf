locals {
  agentless_scan_ecs_task_role_arn      = var.global ? aws_iam_role.agentless_scan_ecs_task_role[0].arn : var.agentless_scan_ecs_task_role_arn
  agentless_scan_ecs_execution_role_arn = var.global ? aws_iam_role.agentless_scan_ecs_execution_role[0].arn : var.agentless_scan_ecs_execution_role_arn
  agentless_scan_ecs_event_role_arn     = var.global ? aws_iam_role.agentless_scan_ecs_event_role[0].arn : var.agentless_scan_ecs_event_role_arn
  agentless_scan_secret_arn             = var.global ? aws_secretsmanager_secret.agentless_scan_secret[0].id : var.agentless_scan_secret_arn
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

// Todo: replace with iam role module
resource "random_string" "external_id" {
  length           = 16
  override_special = "=,.@:/-"
}

resource "random_id" "uniq" {
  byte_length = 4
}

// Global - The following are resources created once per Aws Account
// includes the lacework cloud account integration
// Only create global resources if global variable is set to true
// count = var.global ? 1 : 0

// TF provider agentless scan resource

resource "lacework_integration_aws_agentless_scanning" "lacework_cloud_account" {
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

// SecretsManagers
resource "aws_secretsmanager_secret" "agentless_scan_secret" {
  count = var.global ? 1 : 0
  name  = "${var.prefix}-secret-${var.suffix}"
}

resource "aws_secretsmanager_secret_version" "agentless_scan_secret_version" {
  count         = var.global ? 1 : 0
  secret_id     = aws_secretsmanager_secret.agentless_scan_secret[0].id
  secret_string = <<EOF
   {
    "account": "${var.lacework_account}",
    "token": "${lacework_integration_aws_agentless_scanning.lacework_cloud_account[0].server_token}"
   }
EOF
}

// AWS::IAM::ServiceLinkedRole
resource "aws_iam_service_linked_role" "agentless_scan_linked_role" {
  count            = var.global && var.iam_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"
  description      = "Role to enable Amazon ECS to manage your cluster."
}

data "aws_iam_policy_document" "agentless_scan_task_policy_document" {
  count = var.global ? 1 : 0
  statement {
    sid       = "AllowControlOfBucket"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.agentless_scan_bucket[0].arn}", "${aws_s3_bucket.agentless_scan_bucket[0].arn}/*"]
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
    resources = ["arn:aws:events:*:*:rule/${var.prefix}-periodic-trigger-${var.suffix}"]
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
    sid       = "AllowListSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
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
      "ec2:CreateTags",
      "ec2:CreateSnapshot"
    ]
    resources = ["*"]
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
      values   = ["arn:aws:ecs:*:*:cluster/${var.prefix}-cluster-${var.suffix}"]
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
      "kms:GenerateDataKey*",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PassRoleToTasks"
    effect = "Allow"
    actions = [
      "iam:PassRole",
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
    sid    = "ReadLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/ecs/${var.prefix}-*"]
  }

}

// AWS::IAM::ManagedPolicy
resource "aws_iam_policy" "agentless_scan_task_policy" {
  count  = var.global ? 1 : 0
  name   = "${var.prefix}-task-policy-${var.suffix}"
  policy = data.aws_iam_policy_document.agentless_scan_task_policy_document[0].json
}

// AWS::IAM::Role
resource "aws_iam_role" "agentless_scan_ecs_task_role" {
  count                = var.global ? 1 : 0
  name                 = "${var.prefix}-task-role-${var.suffix}"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = [aws_iam_policy.agentless_scan_task_policy[0].arn]
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
  tags = {
    Name           = "${var.prefix}-task-role-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// AWS::IAM::Role

resource "aws_iam_role" "agentless_scan_ecs_event_role" {
  count                = var.global ? 1 : 0
  name                 = "${var.prefix}-task-event-role-${var.suffix}"
  max_session_duration = 3600
  path                 = "/service-role/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"]
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
  tags = {
    Name           = "${var.prefix}-task-event-role-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}
// AWS::IAM::Role
resource "aws_iam_role" "agentless_scan_ecs_execution_role" {
  count                = var.global ? 1 : 0
  name                 = "${var.prefix}-task-exec-role-${var.suffix}"
  max_session_duration = 3600
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
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
  inline_policy {
    name = "AllowCloudWatch"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "AllowLoggingToCloudWatch"
          Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:log-group:/ecs/${var.prefix}-*"
        },
      ]
    })
  }

  tags = {
    Name           = "${var.prefix}-task-execution-role-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// AWS::S3::Bucket
resource "aws_s3_bucket" "agentless_scan_bucket" {
  count  = var.global ? 1 : 0
  bucket = "${var.prefix}-bucket-${var.suffix}"

  force_destroy = var.bucket_force_destroy

  tags = {
    LWTAG_SIDEKICK = "1"
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

// AWS::S3::BucketPolicy
resource "aws_s3_bucket_policy" "agentless_scan_bucket_policy" {
  count  = var.global ? 1 : 0
  bucket = aws_s3_bucket.agentless_scan_bucket[0].id
  policy = data.aws_iam_policy_document.agentless_scan_bucket_policy[0].json
}

data "aws_iam_policy_document" "agentless_scan_bucket_policy" {
  count = var.global ? 1 : 0
  statement {
    sid     = "ForceSSLOnlyAccess"
    effect  = "Deny"
    actions = ["s3:*"]
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
}

// AWS::IAM::Role
data "aws_iam_policy_document" "agentless_scan_cross_account_policy" {
  count = var.global ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.lacework_aws_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_string.external_id.result]
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
    resources = [aws_s3_bucket.agentless_scan_bucket[0].arn]
  }
}

data "aws_iam_policy_document" "cross_account_inline_policy_ecs" {
  count = var.global ? 1 : 0
  statement {
    sid       = "AllowEcsStopTask"
    effect    = "Allow"
    actions   = ["ecs:StopTask"]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = ["arn:aws:ecs:*:*:cluster/${var.prefix}-cluster-${var.suffix}"]
    }
  }
}

// Todo: use module - lacework_iam_role

resource "aws_iam_role" "agentless_scan_cross_account_role" {
  count                = var.global ? 1 : 0
  name                 = "${var.prefix}-cross-account-role-${var.suffix}"
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.agentless_scan_cross_account_policy[0].json

  inline_policy {
    name   = "S3WriteAllowPolicy"
    policy = data.aws_iam_policy_document.cross_account_inline_policy_bucket[0].json
  }

  inline_policy {
    name   = "ECSTaskManagement"
    policy = data.aws_iam_policy_document.cross_account_inline_policy_ecs[0].json
  }

  tags = {
    Name           = "${var.prefix}-cross-account-role-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}


// Regional - The following are resources created once per Aws Region
// Only create regional resources if regional variable is set to true
// count = var.regional ? 1 : 0
// VPC
resource "aws_vpc" "agentless_scan_vpc" {
  count                = var.regional ? 1 : 0
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name           = "${var.prefix}-vpc-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// RouteTable
resource "aws_route_table" "agentless_scan_route_table" {
  count  = var.regional ? 1 : 0
  vpc_id = aws_vpc.agentless_scan_vpc[0].id
  tags = {
    Name           = "${var.prefix}-vpc-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// SubnetRouteTableAsccociation
resource "aws_route_table_association" "agentless_scan_route_table_association" {
  count          = var.regional ? 1 : 0
  subnet_id      = aws_subnet.agentless_scan_public_subnet[0].id
  route_table_id = aws_route_table.agentless_scan_route_table[0].id
}

// InternetGateway
resource "aws_internet_gateway" "agentless_scan_gateway" {
  count  = var.regional ? 1 : 0
  vpc_id = aws_vpc.agentless_scan_vpc[0].id

  tags = {
    Name           = "${var.prefix}-vpc-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// Route
resource "aws_route" "agentless_scan_route" {
  count                  = var.regional ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.agentless_scan_gateway[0].id
  route_table_id         = aws_route_table.agentless_scan_route_table[0].id
}

// SecurityGroupEgress
resource "aws_security_group" "agentless_scan_vpc_egress" {
  count = var.regional ? 1 : 0
  name  = "AgentlessScanVPCEgress"
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Subnet
resource "aws_subnet" "agentless_scan_public_subnet" {
  count                   = var.regional ? 1 : 0
  vpc_id                  = aws_vpc.agentless_scan_vpc[0].id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = false


  tags = {
    Name           = "${var.prefix}-vpc-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "agentless_scan_capacity_providers" {
  count              = var.regional ? 1 : 0
  cluster_name       = aws_ecs_cluster.agentless_scan_ecs_cluster[0].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

// Cluster
resource "aws_ecs_cluster" "agentless_scan_ecs_cluster" {
  count = var.regional ? 1 : 0
  name  = "${var.prefix}-cluster-${var.suffix}"

  tags = {
    Name           = "${var.prefix}-vpc-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// TaskDefinition
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
  tags = {
    Name           = "${var.prefix}-task-definition-${var.suffix}"
    LWTAG_SIDEKICK = "1"
  }
  container_definitions = jsonencode([
    {
      name      = "sidekick"
      image     = var.image_url
      essential = true
      environment = [
        {
          name  = "STARTUP_PROVIDER"
          value = "AWS"
        },
        {
          name  = "STARTUP_RUNMODE"
          value = "TASK"
        },
        {
          name  = "ECS_CLUSTER_ARN"
          value = "${aws_ecs_cluster.agentless_scan_ecs_cluster[0].arn}"
        },
        {
          name  = "S3_BUCKET"
          value = "${var.prefix}-bucket-${var.suffix}"
        },
        {
          name  = "LACEWORK_APISERVER"
          value = "${var.lacework_account}.${var.lacework_domain}"
        },
        {
          name  = "SECRET_ARN"
          value = "${local.agentless_scan_secret_arn}"
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
      linuxParameters = {
        capabilities = {
          Add = ["SYS_PTRACE"]
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
    }
  ])
}

// LogGroup
resource "aws_cloudwatch_log_group" "agentless_scan_log_group" {
  count             = var.regional ? 1 : 0
  name              = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster[0].name}"
  retention_in_days = 14
}

// AgentlessScanOrchestrateEvent
resource "aws_cloudwatch_event_rule" "agentless_scan_event_rule" {
  depends_on = [
    aws_ecs_cluster.agentless_scan_ecs_cluster,
    aws_ecs_task_definition.agentless_scan_task_definition
  ]

  count               = var.regional ? 1 : 0
  name                = "${var.prefix}-periodic-trigger-${var.suffix}"
  schedule_expression = "rate(1 hour)"
  event_bus_name      = "default"
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
      subnets          = [aws_subnet.agentless_scan_public_subnet[0].id]
      security_groups  = [aws_vpc.agentless_scan_vpc[0].default_security_group_id]
      assign_public_ip = true
    }
    tags = {
      LWTAG_SIDEKICK = "1"
    }
  }
}
