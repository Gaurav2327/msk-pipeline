provider "aws" {
  region = local.region
}

terraform {
  required_version = "~> 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }
  backend "s3" {
    key     = "terraform/backend/aws-msk-cluster.tfstate"
    bucket  = "terraform-state-bucket-dops"
    encrypt = true
  }
}

