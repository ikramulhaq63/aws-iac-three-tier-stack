output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
output "public_subnet_1_id" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet_1.id
}
output "public_subnet_2_id" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet_2.id
}
output "private_subnet_app_tier_1_id" {
  description = "IDs of the app tier private subnets"
  value       = aws_subnet.private_app_subnet_1.id
}
output "private_subnet_app_tier_2_id" {
  description = "IDs of the app tier private subnets"
  value       = aws_subnet.private_app_subnet_2.id
}
output "private_subnet_db_tier_1_id" {
  description = "IDs of the db tier private subnets"
  value       = aws_subnet.private_db_subnet_1.id
}
output "private_subnet_db_tier_2_id" {
  description = "IDs of the db tier private subnets"
  value       = aws_subnet.private_db_subnet_2.id
}