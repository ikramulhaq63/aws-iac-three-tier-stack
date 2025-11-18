output "amazon_linux_2_ami_id" {
  description = "ID of the latest Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux_2.id
}
output "web_security_group_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web_sg.id
}
output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.deployer_key.key_name
}
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}
output "app_security_group_id" {
  description = "ID of the application tier security group"
  value       = aws_security_group.app_tier.id
}
output "db_security_group_id" {
  description = "ID of the database tier security group"
  value       = aws_security_group.rds_sg.id
}