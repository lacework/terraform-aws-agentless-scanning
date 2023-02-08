# Single Account with Existing VPC & Networking Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "existing" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "existing" {
  vpc_id = aws_vpc.existing.id
}

resource "aws_route_table" "existing" {
  vpc_id = aws_vpc.existing.id
}

resource "aws_route" "existing" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.existing.id
  route_table_id         = aws_route_table.existing.id
}

resource "aws_route_table_association" "agentless_scan_route_table_association" {
  subnet_id      = aws_subnet.existing.id
  route_table_id = aws_route_table.existing.id
}

resource "aws_subnet" "existing" {
  vpc_id                  = aws_vpc.existing.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
}

resource "aws_security_group" "existing" {
  name   = "existing-security-group"
  vpc_id = aws_vpc.existing.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "lacework_aws_agentless_scanning_singleregion" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.8"

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"

  use_existing_vpc            = true
  vpc_id                      = aws_vpc.existing.id
  use_existing_security_group = true
  security_group_id           = aws_security_group.existing.id
  use_existing_subnet         = true
  subnet_id                   = aws_subnet.existing.id
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include and ECS cluster.
This example uses a single module to add both types of resources.
This is the simplest usage but only supports a single account and single region.

Refer to the _default_ example for adding scanning to multiple regions.
