
data "aws_region" "current" {}

// TF provider agentless scan resource

resource "lacework_aws_agentless_scanning" "lacework_cloud_account" {
  name                      = var.name
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
    "account": "${var.account}",
    "token": "${lacework_aws_agentless_scanning.lacework_cloud_account.server_token}"
   }
EOF
}

// AWS::IAM::ServiceLinkedRole
resource "aws_iam_service_linked_role" "agentless_scan_linked_role" {
  aws_service_name = "ecs.amazonaws.com"
  description      = "Role to enable Amazon ECS to manage your cluster."
}
// TODO: AWS::IAM::ManagedPolicy
resource "aws_iam_policy" "agentless_scan_task_policy" {
  name   = "${var.resource_name_prefix}-task-policy-${var.resource_name_suffix}"
  policy = <<EOF
  {
    "Version": "2012-10-17",
      "Statement": [
        { 
        "Sid": "AllowControlOfBucket",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
            "${aws_s3_bucket.agentless_scan_bucket.arn}",
            "${aws_s3_bucket.agentless_scan_bucket.arn}/*" 
            ]
        },
        {
        "Sid": "AllowTagECSCluster",
        "Effect": "Allow",
        "Action": [
                "ecs:TagResource",
                "ecs:UntagResource",
                "ecs:ListTagsForResource"
                ],
        "Resource": "*",
        "Condition": {
            "StringLike": {
            "ecs:ResourceTag/LWTAG_SIDEKICK": "*"
                    }
            }
        },
        {
          "Sid": "AllowListRules",
            "Effect": "Allow",
            "Action": [
                "events:DescribeRule",
                "events:ListRules",
                "events:ListTargetsByRule",
                "events:ListTagsForResource",
                "events:ListRuleNamesByTarget"
                    ],
            "Resource": "*"
        },
        {
         "Sid": "AllowUpdateRule",
         "Effect": "Allow",
         "Action": [
            "events:DisableRule",
            "events:EnableRule",
            "events:PutTargets",
            "events:RemoveTargets"
                ],
        "Resource": "arn:aws:events:*:*:rule/${ResourceNamePrefix}-periodic-trigger-${ResourceNameSuffix}"
        },
        {
        "Sid": "AllowReadFromSecretsManager",
        "Effect": "Allow",
        "Action": [
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:GetSecretValue",
                "secretsmanager:GetResourcePolicy"
                ],
        "Resource": "${aws_secretsmanager_secret.agentless_scan_secret.arn}"
        },
        {
        "Sid": "AllowListSecrets",
        "Effect": "Allow",
        "Action": "secretsmanager:ListSecrets",
        "Resource": "*"
        },
        {
        "Sid": "DescribeInstances",
        "Effect": "Allow",
         "Action": [
         "ec2:Describe*"
                ],
        "Resource": "*"
        },
        {
        "Sid": "CreateSnapshots",
        "Effect": "Allow",
        "Action": [
            "ec2:CreateTags",
            "ec2:CreateSnapshot"
            ],
        "Resource": "*"
        },
        {
        "Sid": "SnapshotManagement",
        "Effect": "Allow",
        "Action": [
            "ec2:DeleteSnapshot",
            "ec2:ModifySnapshotAttribute",
            "ec2:ResetSnapshotAttribute",
            "ebs:ListChangedBlocks",
            "ebs:ListSnapshotBlocks",
            "ebs:GetSnapshotBlock",
            "ebs:CompleteSnapshot"
                ],
        "Resource": "*",
        "Condition": {
            "StringLike": {
                "aws:ResourceTag/LWTAG_SIDEKICK": "*"
                    }
                }
        },
        {
        "Sid": "TaskManagement",
        "Effect": "Allow",
        "Action": [
            "ecs:RunTask",
            "ecs:StartTask",
            "ecs:StopTask",
            "ecs:ListTasks",
            "ecs:Describe*"
             ],
        "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "ecs:cluster": "arn:aws:ecs:*:*:cluster/${ResourceNamePrefix}-cluster-${ResourceNameSuffix}"  
                            }
                        }
            },
            {
            "Sid": "SnapshotEncryption",
            "Effect": "Allow",
            "Action": [
                    "kms:DescribeKey",
                    "kms:Encrypt",
                    "kms:Decrypt",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*",
                    "kms:CreateGrant"
                        ],
            "Resource": "*"
            },
            {
            "Sid": "PassRoleToTasks",
            "Effect": "Allow",
            "Action": [
                    "iam:PassRole",
                    "sts:AssumeRole"
                    ],
            "Resource": "*",
                "Condition": {
                    "StringLike": {
                        "iam:ResourceTag/LWTAG_SIDEKICK": "*"
                        }
                    }
            },
            {
            "Sid": "ReadLogs",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
                ],
            "Resource": "arn:aws:logs:*:*:log-group:/ecs/${ResourceNamePrefix}-*"
            }
    ]
  }
  EOF
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
          Resource = "arn:aws:logs:*:*:log-group:/ecs/${ResourceNamePrefix}-*"
        },
      ]
    })
  }

  tags = {
    Name           = "${var.resource_name_prefix}-task-execution-role-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
}

// TODO: AWS::S3::Bucket
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
// TODO: AWS::S3::BucketPolicy
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

// TODO: AWS::IAM::Role
resource "aws_iam_role" "agentless_scan_cross_account_role" {
  //...
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
  vpc_id = aws_vpc.main.id

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
    security_groups = ""
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
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
  name                     = "sidekick"
  image                    = var.image_url
  family                   = aws_ecs_cluster.agentless_scan_ecs_cluster.name
  task_role_arn            = aws_iam_role.agentless_scan_ecs_task_role.arn
  execution_role_arn       = aws_iam_role.agentless_scan_ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  essential                = true
  tags = {
    Name           = "${var.resource_name_prefix}-task-definition-${var.resource_name_suffix}"
    LWTAG_SIDEKICK = "1"
  }
  container_definitions = jsonencode([
    {
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
          value = "${var.lacework_apiserver}"
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
          awslogs-create-group  = true
          awslogs-group         = "/ecs/${aws_ecs_cluster.agentless_scan_ecs_cluster.name}"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = ecs
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
    task_count       = 1
    launch_type      = "FARGATE"
    platform_version = "LATEST"
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
