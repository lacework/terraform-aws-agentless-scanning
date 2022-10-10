# Single Account with Multiple Regions Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

module "lacework_aws_agentless_scanning_global" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  global                    = true
  lacework_integration_name = "agentless_from_terraform"
}

// Create regional resources in our first region
module "lacework_aws_agentless_scanning_region" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}

// Create regional resources in our second region
module "lacework_aws_agentless_scanning_region_usw2" {
  source  = "lacework/agentless-scanning/aws"
  version = ">= 0.3.2"

  providers = {
    aws = aws.usw2
  }

  regional                = true
  global_module_reference = module.lacework_aws_agentless_scanning_global
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include a VPC, and ECS cluster.
A "one to many" relationship between **global** and **regional** exists so that
scanning and snapshot usage avoids cross-region data transfer.

In a situation where multiple regions are scanned, the **global** resources should
be added once, and the **regional** should be added to each region being scanned.
