# Single Account with Existing VPC & Networking Example

### versions.tf
```hcl
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    lacework = {
      source  = "lacework/lacework"
      version = "~> 2.0"
    }
  }
}
```

### main.tf
```hcl
provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

// Create global resources, includes lacework cloud integration.
// This will also create regional resources too.
// If scanning should occur on multiple regions then refer to the 'default' example.
module "lacework_aws_agentless_scanning_singleregion" {
  source = "../.."

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"

  // This expects the VPC to have a route to the internet.
  // There are options in the terraform here to create an IGW if needed.
  use_existing_vpc            = true
  use_internet_gateway        = false
  vpc_id                      = "vpc-123456"
  use_existing_security_group = true
  security_group_id           = "sg-123456"

  // Only a single subnet is needed.
  use_existing_subnet = true
  subnet_id           = "subnet-123456"
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include and ECS cluster.
This example uses a single module to add both types of resources.
This is the simplest usage but only supports a single account and single region.

Refer to the _default_ example for adding scanning to multiple regions.
