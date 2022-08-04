# Default Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias    = "usw2"
  region = "us-west-2"
}

module "lacework_aws_agentless_scanning" {
  source                    = "lacework/agentless-scanning/aws"
  version                   = "~> 0.1"
  global                    = true
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  cloud_integration_name    = "sidekick_from_terraform"
  scan_frequency_hours      = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}

module "lacework_aws_agentless_scanning" {
  source                    = "../.."
    providers = {
    aws = aws.usw2
  }
  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
}
```
