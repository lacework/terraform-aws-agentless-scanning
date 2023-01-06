# Single Account with Existing VPC Example

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

module "lacework_aws_agentless_scanning_singleregion" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"

  use_existing_vpc = true
  vpc_id           = aws_vpc.existing.id
  vpc_cidr_block   = "10.0.0.0/24" # This should be an unused subnet within the VPC's CIDR Block
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include and ECS cluster.
This example uses a single module to add both types of resources.
This is the simplest usage but only supports a single account and single region.

Refer to the _default_ example for adding scanning to multiple regions.
