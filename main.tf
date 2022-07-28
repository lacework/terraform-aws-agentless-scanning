
data "aws_region" "current" {}

// TF provider agentless scan resource

resource "lacework_aws_agentless_scanning" "lacework-cloud-account" {
  name                      = var.name
  scan_frequency            = var.scan_frequency
  query_text                = var.query_text
  scan_containers           = var.scan_containers
  scan_host_vulnerabilities = var.scan_host_vulnerabilities
}

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

// Todo SecretsManagers

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
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_arn
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

