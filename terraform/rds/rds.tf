locals {
  cluster_group_params = [
    {
        name = "binlog_format"
        value = "row"
        apply_method = "pending-reboot"
    },
    {
        name = "binlog_row_image"
        value = "FULL"
        apply_method = "pending-reboot"
    },
  ]
  instance_group_params = []
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.rds_subnet_group_name
  subnet_ids = [ data.aws_subnets.public_subnets.ids[0], data.aws_subnets.public_subnets.ids[1] ]

  tags = {
    Name = var.rds_subnet_group_name
  }
}

module "rds_mysql_db" {
    source = "terraform-aws-modules/rds-aurora/aws"
    version = "9.16.1"
    name = var.rds_cluster_name
    engine = var.db_engine_type
    engine_version = var.db_engine_version
    master_username = var.db_master_username
    # Auto-generate password and store in Secrets Manager
    manage_master_user_password = true
    instances = {
        main = {
            instance_class = var.db_instance_type
            identifier     = "${var.rds_cluster_instance_name}-${var.rds_identifier_suffix}"
        }
    }
    vpc_id = data.aws_vpc.default_vpc.id
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
    apply_immediately = true
    skip_final_snapshot = true
    create_db_cluster_parameter_group      = true
    db_cluster_parameter_group_name        = var.db_cluster_parameter_group_name
    db_cluster_parameter_group_description = "Custom parameter group for MySQL RDS cluster"
    db_cluster_parameter_group_parameters = local.cluster_group_params
    db_cluster_parameter_group_family = var.db_cluster_parameter_group_family
    create_db_parameter_group = true
    db_parameter_group_name   = var.db_parameter_group_name
    db_parameter_group_description = "Custom parameter group for MySQL RDS instances"
    db_parameter_group_parameters = local.instance_group_params
    db_parameter_group_family = var.db_parameter_group_family
    publicly_accessible = true
    tags     = merge(local.default_tags, 
    { 
        Name = var.rds_cluster_name
    })    
}