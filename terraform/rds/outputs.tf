# Output the RDS cluster endpoint
output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = module.rds_mysql_db.cluster_endpoint
}

# Output the RDS cluster identifier
output "rds_cluster_identifier" {
  description = "The cluster identifier"
  value       = module.rds_mysql_db.cluster_id
}

# Output the Secrets Manager secret ARN containing the master password
output "rds_master_user_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the master user password"
  value       = module.rds_mysql_db.cluster_master_user_secret[0].secret_arn
  sensitive   = true
}

# Output the master username
output "rds_master_username" {
  description = "The master username for the RDS cluster"
  value       = var.db_master_username
}

