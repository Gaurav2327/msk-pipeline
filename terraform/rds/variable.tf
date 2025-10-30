variable "rds_subnet_group_name" {
    description = "The name of the RDS subnet group"
    type        = string
    default     = "rds-cdc-subnet-group"
  
}

variable "rds_identifier_suffix" {
    description = "The identifier suffix for the RDS instance"
    type        = string
    default     = "cdc"
  
}

variable "rds_cluster_name" {
    description = "The name of the RDS cluster"
    type        = string
    default     = "rds-cdc-cluster"
}

variable "rds_cluster_instance_name" {
  description = "The name of rds instance"
  type = string
  default = "rds-cdc-instance"
}

variable "db_cluster_parameter_group_name" {
    description = "The name of the RDS cluster parameter group"
    type        = string
    default     = "rds-cdc-cluster-params"
}

variable "db_parameter_group_name" {
    description = "The name of the RDS instance parameter group"
    type        = string
    default     = "rds-cdc-instance-params"
}

variable "db_engine_type" {
    description = "The type of the RDS database engine"
    type        = string
    default     = "aurora-mysql" 
}

variable "db_engine_version" {
    description = "The version of the RDS database engine"
    type        = string
    default     = "5.7.mysql_aurora.2.11.2"
}

variable "db_instance_type" {
    description = "The instance type of the RDS database"
    type        = string
    default     = "db.t3.small"
}

variable "db_master_username" {
    description = "The master username for the RDS database"
    type        = string
    default     = "admin"
}

variable "db_master_password" {
    description = "The master password for the RDS database"
    type        = string
    default     = "Admin123"
}

variable "db_parameter_group_family" {
    description = "The family of the RDS instance parameter group"
    type        = string
    default     = "aurora-mysql5.7"
}

variable "db_cluster_parameter_group_family" {
  description = "The family of the RDS cluster parameter group"
  type        = string
  default     = "aurora-mysql5.7"
}

variable "rds_tags" {
    description = "A map of tags to assign to the RDS resources"
    type        = map(string)
    default     = {}
}