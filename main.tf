
data "aws_region" "current" {}

// replace with iam role module
resource "random_string" "external_id" {
  length           = 256
  override_special = "=,.@:/-"
}

// TF provider agentless scan resource

resource "lacework_integration_aws_agentless_scanning" "lacework_cloud_account" {
  name                      = var.cloud_integration_name
  scan_frequency            = var.scan_frequency
  query_text                = var.query_text
  scan_containers           = var.scan_containers
  scan_host_vulnerabilities = var.scan_host_vulnerabilities
}

// Global
// SecretsManagers
resource "aws_secretsmanager_secret" "agentless_scan_secret" {
  name = "${var.resource_name_prefix}-secret-${var.resource_name_suffix}"
}

resource "aws_secretsmanager_secret_version" "agentless_scan_secret_version" {
  secret_id     = aws_secretsmanager_secret.agentless_scan_secret.id
  secret_string = <<EOF
   {
    "account": "${var.lacework_aws_account_id}",
    "token": "${lacework_integration_aws_agentless_scanning.lacework_cloud_account.server_token}"
   }
EOF
}

// AWS::IAM::ServiceLinkedRole
resource "aws_iam_service_linked_role" "agentless_scan_linked_role" {
  aws_service_name = "ecs.amazonaws.com"
  description      = "Role to enable Amazon ECS to manage your cluster."
}

data "aws_iam_policy_document" "agentless_scan_task_policy_document" {
  statement {
    sid       = "AllowControlOfBucket"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.agentless_scan_bucket.arn}", "${aws_s3_bucket.agentless_scan_bucket.arn}/*"]
  }

  statement {
    sid       = "AllowTagECSCluster"
    effect    = "Allow"
    actions   = ["ecs:TagResource", "ecs:UntagResource", "ecs:ListTagsForResource"]
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
    actions = ["events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:ListTagsForResource",
    "events:ListRuleNamesByTarget"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowUpdateRule"
    effect = "Allow"
    actions = ["events:DisableRule",
      "events:EnableRule",
      "events:PutTargets",
    "events:RemoveTargets"]
    resources = ["arn:aws:events:*:*:rule/${var.resource_name_prefix}-periodic-trigger-${var.resource_name_suffix}"]
  }

  statement {
    sid    = "AllowReadFromSecretsManager"
    effect = "Allow"
    actions = ["secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
    "secretsmanager:GetResourcePolicy"]
    resources = ["${aws_secretsmanager_secret.agentless_scan_secret.arn}"]
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
    actions = ["ec2:CreateTags",
    "ec2:CreateSnapshot"]
    resources = ["*"]
  }

  statement {
    sid    = "SnapshotManagement"
    effect = "Allow"
    actions = ["ec2:DeleteSnapshot",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute",
      "ebs:ListChangedBlocks",
      "ebs:ListSnapshotBlocks",
      "ebs:GetSnapshotBlock",
    "ebs:CompleteSnapshot"]
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
    actions = ["ecs:RunTask",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:ListTasks",
    "ecs:Describe*"]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = ["arn:aws:ecs:*:*:cluster/${var.resource_name_prefix}-cluster-${var.resource_name_suffix}"]
    }
  }

  statement {
    sid    = "SnapshotEncryption"
    effect = "Allow"
    actions = ["kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    "kms:CreateGrant"]
    resources = ["*"]
  }

  statement {
    sid    = "PassRoleToTasks"
    effect = "Allow"
    actions = ["iam:PassRole",
    "sts:AssumeRole"]
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
    actions = ["logs:DescribeLogStreams",
    "logs:GetLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/ecs/${var.resource_name_prefix}-*"]
  }

}


// AWS::IAM::ManagedPolicy
resource "aws_iam_policy" "agentless_scan_task_policy" {
  name   = "${var.resource_name_prefix}-task-policy-${var.resource_name_suffix}"
  policy = data.aws_iam_policy_document.agentless_scan_task_policy_document.json
}


// AWS::IAM::Role
resource "aws_iam_role" "agentless_scan_ecs_task_role" {
  name                 = "${var.resource_name_prefix}-task-role-${var.resource_name_suffix}"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = [aws_iam_policy.agentless_scan_task_policy.arn]
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
    Name           = "${var.resource_name_prefix}-task-role-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// AWS::IAM::Role

resource "aws_iam_role" "agentless_scan_ecs_event_role" {
  name                 = "${var.resource_name_prefix}-task-event-role-${var.resource_name_suffix}"
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
    Name           = "${var.resource_name_prefix}-task-event-role-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}
// AWS::IAM::Role
resource "aws_iam_role" "agentless_scan_ecs_execution_role" {
  name                 = "${var.resource_name_prefix}-task-execution-role-${var.resource_name_suffix}"
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
          Resource = "arn:aws:logs:*:*:log-group:/ecs/${var.resource_name_prefix}-*"
        },
      ]
    })
  }

  tags = {
    Name           = "${var.resource_name_prefix}-task-execution-role-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// AWS::S3::Bucket
resource "aws_s3_bucket" "agentless_scan_bucket" {
  bucket = "${var.resource_name_prefix}-bucket-${var.resource_name_suffix}"

  tags = {
    LWTAG_SIDEKICK = "1"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.agentless_scan_bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "agentless_scan_bucket_lifecyle" {
  bucket = aws_s3_bucket.agentless_scan_bucket.id

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
  bucket = aws_s3_bucket.agentless_scan_bucket.id
  policy = data.aws_iam_policy_document.agentless_scan_bucket_policy.json
}

data "aws_iam_policy_document" "agentless_scan_bucket_policy" {
  statement {
    sid     = "ForceSSLOnlyAccess"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.agentless_scan_bucket.arn,
      "${aws_s3_bucket.agentless_scan_bucket.arn}/*"
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
  statement {
    sid     = "ForceSSLOnlyAccess"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.lacework_aws_account_id}:root"]
    }
    resources = [
      aws_s3_bucket.agentless_scan_bucket.arn,
      "${aws_s3_bucket.agentless_scan_bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_string.external_id.result]
    }
  }
}

// Todo: use module - lacework_iam_role

resource "aws_iam_role" "agentless_scan_cross_account_role" {
  name                 = "${var.resource_name_prefix}-cross-account-role-${var.resource_name_suffix}"
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.agentless_scan_cross_account_policy.json
  inline_policy {
    name = "S3WriteAllowPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "ListAndTagBucket"
          Action   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:GetBucketTagging", "s3:PutBucketTagging"]
          Effect   = "Allow"
          Resource = aws_s3_bucket.agentless_scan_bucket.arn
        },
        {
          Sid      = "PutGetDeleteObjectsInBucket"
          Action   = ["s3:DeleteObject", "s3:PutObject", "s3:GetObject"]
          Effect   = "Allow"
          Resource = aws_s3_bucket.agentless_scan_bucket.arn
        }
      ]
    })
  }

  inline_policy {
    name = "ECSTaskManagement"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "AllowEcsStopTask"
          Action   = ["ecs:StopTask"]
          Effect   = "Allow"
          Resource = "*"
          Condition = {
            "ArnEquals" : { "ecs:cluster" : "arn:aws:ecs:*:*:cluster/${var.resource_name_prefix}-cluster-${var.resource_name_suffix}" }
          }
        }
      ]
    })
  }

  tags = {
    Name           = "${var.resource_name_prefix}-cross-account-role-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}


// Per Region
// EC2 VPC
resource "aws_vpc" "agentless_scan_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"


  tags = {
    Name           = "${var.resource_name_prefix}-vpc-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}



// EC2 RouteTable
resource "aws_route_table" "agentless_scan_route_table" {
  vpc_id = aws_vpc.agentless_scan_vpc.id
  tags = {
    Name           = "${var.resource_name_prefix}-vpc-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// EC2 SubnetRouteTableAsccociation

resource "aws_route_table_association" "agentless_scan_route_table_association" {
  subnet_id      = aws_subnet.agentless_scan_public_subnet.id
  route_table_id = aws_route_table.agentless_scan_route_table.id
}

// EC2:InternetGateway
resource "aws_internet_gateway" "agentless_scan_gateway" {
  vpc_id = aws_vpc.agentless_scan_vpc.id

  tags = {
    Name           = "${var.resource_name_prefix}-vpc-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// EC2 Route
resource "aws_route" "agentless_scan_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.agentless_scan_gateway.id
  route_table_id         = aws_route_table.agentless_scan_route_table.id
  #Depends on AgentlessScanGatewayAttachment
}

// EC2 SecurityGroupEgress
resource "aws_security_group" "agentless_scan_vpc_egress" {
  name = "AgentlessScanVPCEgress"
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
// EC2 Subnet
resource "aws_subnet" "agentless_scan_public_subnet" {
  vpc_id            = aws_vpc.agentless_scan_vpc.id
  availability_zone = data.aws_region.current.name
  cidr_block        = "10.10.1.0/24"

  map_public_ip_on_launch = false


  tags = {
    Name           = "${var.resource_name_prefix}-vpc-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// ECS Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name       = aws_ecs_cluster.agentless_scan_ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}
// ECS Cluster
resource "aws_ecs_cluster" "agentless_scan_ecs_cluster" {
  name = "${var.resource_name_prefix}-cluster-${var.resource_name_suffix}"

  tags = {
    Name           = "${var.resource_name_prefix}-vpc-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// ECS TaskDefinition
resource "aws_ecs_task_definition" "agentless_scan_task_definition" {
  family                   = aws_ecs_cluster.agentless_scan_ecs_cluster.name
  task_role_arn            = aws_iam_role.agentless_scan_ecs_task_role.arn
  execution_role_arn       = aws_iam_role.agentless_scan_ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  tags = {
    Name           = "${var.resource_name_prefix}-task-definition-${var.resource_name_suffix}"
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
          value = "${aws_ecs_cluster.agentless_scan_ecs_cluster.arn}"
        },
        {
          name  = "S3_BUCKET"
          value = "${var.resource_name_prefix}-bucket-${var.resource_name_suffix}"
        },
        {
          name  = "LACEWORK_APISERVER"
          value = "${var.lacework_aws_account_id}"
        },
        {
          name  = "SECRET_ARN"
          value = "${var.resource_name_prefix}-bucket-${var.resource_name_suffix}"
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
          awslogs-group         = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster.name}"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

// Logs LogGroup
resource "aws_cloudwatch_log_group" "agentless_scan_log_group" {
  name              = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster.name}"
  retention_in_days = 14
}

// TODO: AgentlessScanOrchestrateEvent
resource "aws_cloudwatch_event_rule" "agentless_scan_event_rule" {
  name                = "${var.resource_name_prefix}-periodic-trigger-${var.resource_name_suffix}"
  schedule_expression = "rate(1 hour)"
  event_bus_name      = "default"
}

resource "aws_cloudwatch_event_target" "agentless_scan_event_target" {
  target_id = "sidekick"
  rule      = aws_cloudwatch_event_rule.agentless_scan_event_rule.name
  arn       = aws_ecs_cluster.agentless_scan_ecs_cluster.arn
  input     = "{\"containerOverrides\":[{\"name\":\"sidekick\",\"environment\":[{\"name\":\"STARTUP_SERVICE\",\"value\":\"ORCHESTRATE\"}]}]}"
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.agentless_scan_task_definition.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    network_configuration {
      subnets          = [aws_subnet.agentless_scan_public_subnet.id]
      security_groups  = [aws_vpc.agentless_scan_vpc.default_security_group_id]
      assign_public_ip = true
    }
    tags = {
      LWTAG_SIDEKICK = "1"
    }
  }
}
