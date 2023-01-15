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

// Create global resources, includes lacework cloud integration.
// This will also create regional resources too.
// If scanning should occur on multiple regions then refer to the 'default' example.
module "lacework_aws_agentless_scanning_singleregion" {
  source = "../.."

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"

  use_existing_vpc = true
  vpc_id           = aws_vpc.existing.id
  vpc_cidr_block   = "10.0.0.0/24" # This should be an unused subnet within the VPC's CIDR Block
}
