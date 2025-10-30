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

# Fetch private subnets based on them being tagged as "private" //if you are using private subnets for this demo i will be using public subnets
data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["private-subnet-*"]
  }
}

data "aws_security_group" "vpc_sg" {
  filter {
    name   = "group-name" # Exact match of the security group's name
    values = ["default"]
  }
}

output "security_group_id" {
  value = data.aws_security_group.vpc_sg.id
}

data "aws_security_group" "rds" {
  filter {
    name   = "group-name" # Exact match of the security group's name
    values = ["db-sg"]
  }
}

output "all_subnets" {
  value = data.aws_subnets.all_subnets.ids
}

output "public_subnets" {
  value = data.aws_subnets.public_subnets.ids
}

output "private_subnets" {
  value = data.aws_subnets.private_subnets.ids
}

output "rds_sg" {
  value = data.aws_security_group.rds.id
}