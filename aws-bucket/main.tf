terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "sa-east-1"
  default_tags {
    tags = {
      "owner"      = "gk",
      "managed-by" = "terraform"
    }
  }
}