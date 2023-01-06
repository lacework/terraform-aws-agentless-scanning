# Single Account with Single Region Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-west-1"
}

module "lacework_aws_agentless_scanning_singleregion" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.5"

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"
}
```

In this example the **global** resources and **regional** resources are added.
Global resources include the single per-account resources like IAM roles,
policies, and S3 bucket. Regional resources include a VPC, and ECS cluster.
This example uses a single module to add both types of resources.
This is the simplest usage but only supports a single account and single region.

Refer to the _default_ example for adding scanning to multiple regions.
