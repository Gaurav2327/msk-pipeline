data "aws_availability_zones" "available" {}

data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default-vpc"]
  }
}

# Fetch all subnets in the VPC
data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Fetch public subnets based on them being tagged as "public"
data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-*"]
  }
}

data "aws_security_group" "rds_sg" {
    filter {
        name   = "group-name"
        values = ["rds-sg"]
    }
}

data "aws_security_group" "msk_sg" {
  filter {
    name   = "group-name" # Exact match of the security group's name
    values = ["msk-sg"]
  }
}

data "aws_security_group" "msk_connector_sg" {
  filter {
    name   = "group-name" # Exact match of the security group's name
    values = ["connector-sg"]
  }
  
}

data "aws_s3_bucket" "plugin_bucket" {
  bucket = var.log_bucket  
}

data "aws_rds_cluster" "cdc_rds_cluster" {
  cluster_identifier = "rds-cdc-cluster"
}

# Get the Secrets Manager secret containing RDS password
data "aws_secretsmanager_secret" "rds_password" {
  arn = data.aws_rds_cluster.cdc_rds_cluster.master_user_secret[0].secret_arn
}

# Get the actual password value from Secrets Manager
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.rds_password.id
}