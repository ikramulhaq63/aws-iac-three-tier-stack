# Database Tier Outputs
output "rds_endpoint" {
  description = "Endpoint of the RDS database instance"
  value       = module.database_tier.rds_endpoint
}

output "rds_address" {
  description = "RDS database address without port"
  value       = module.database_tier.rds_address
}

output "rds_port" {
  description = "Port of the RDS database instance"
  value       = module.database_tier.rds_port
}

output "db_username" {
  description = "Username for the RDS database instance"
  value       = module.database_tier.db_username
}

output "db_password_secret_arn" {
  description = "ARN of the secret containing db password"
  value       = module.database_tier.db_password_secret_arn
}

output "mysql_connection_command" {
  description = "Command to connect to MySQL database"
  value       = module.database_tier.mysql_connection_command
}

output "retrieve_db_password_command" {
  description = "AWS CLI command to retrieve database password"
  value       = module.database_tier.retrieve_db_password_command
}