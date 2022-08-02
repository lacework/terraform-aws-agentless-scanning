# Default Example

```hcl
terraform {
  required_providers {
    lacework = {
      source = "lacework/lacework"
    }
  }
}

provider "lacework" {}

module "lacework_module" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.1"

  resource_name_prefix      = "lacework"
  resource_name_suffix      = "terraform"
  cloud_integration_name    = "sidekick_from_terraform"
  scan_frequency            = 24
  scan_containers           = true
  scan_host_vulnerabilities = true
}
```
