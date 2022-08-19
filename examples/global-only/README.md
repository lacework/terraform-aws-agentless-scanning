# Global Only Example

```hcl

provider "lacework" {}

provider "aws" {
  region = "us-east-1"
}

module "lacework_aws_agentless_scanning_global" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.1"

  global                    = true
  regional                  = false
  prefix                    = "lacework-agentless-scanning"
  suffix                    = "terraform"
  lacework_integration_name = "sidekick_from_terraform"
  scan_frequency_hours      = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}
```
