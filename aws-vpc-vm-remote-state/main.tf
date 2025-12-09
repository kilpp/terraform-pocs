terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1"
    }
  }
  backend "s3" {
    bucket = "gk-remote-state-terraform"
    key    = "aws-vm/terraform.tfstate"
    region = "sa-east-1"
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

data "terraform_remote_state" "vpc_remote_state" {
    backend = "s3"
    config = {
        bucket = "gk-remote-state-terraform"
        key = "aws-vpc/terraform.tfstate"
        region = "as-east-1"
    }
}
