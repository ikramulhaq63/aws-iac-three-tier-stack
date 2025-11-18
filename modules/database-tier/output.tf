# Output RDS Endpoint
output "rds_endpoint" {
  value       = aws_db_instance.my_rds_instance.address
  description = "Endpoint of the RDS database instance"
}
output "rds_address" {
  value       = aws_db_instance.my_rds_instance.address
  description = "RDS database address without port"
}
output "rds_port" {
  value       = aws_db_instance.my_rds_instance.port
  description = "Port of the RDS database instance"
}
output "db_username" {
  value       = aws_db_instance.my_rds_instance.username
  description = "Username for the RDS database instance"
}
output "db_password_secret_arn" {
  value       = aws_secretsmanager_secret.rds_secret.arn
  description = "ARN of the secret containing db password"
}
output "mysql_connection_command" {
  value       = "mysql -h ${aws_db_instance.my_rds_instance.address} -P 3306 -u ${aws_db_instance.my_rds_instance.username} -p"
  description = "Command to connect to MySQL database (you'll be prompted for password)"
}
output "retrieve_db_password_command" {
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.rds_secret.name} --query SecretString --output text | jq -r .password"
  description = "AWS CLI command to retrieve database password"
}