terraform {
  required_version = "~> v0.51.0, < v0.51.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0, < 6.0"
    }
  }
}
