terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws    = {
      source = "hashicorp/aws"
      version = ">= 4.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 2.1"
    }
    null = {
      source = "hashicorp/null"
      version = ">= 3.1.1"
    }
    lacework = {
      source  = "lacework/lacework"
      version = "~> 1.8"
    }
  }
}
