# Database Tier Module - RDS, Subnet Groups, and Secrets

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids  = [var.private_subnet_db_tier_1_id, var.private_subnet_db_tier_2_id]
  tags = {
    Name = "${var.project_name}rds-subnet-group"
  }
}

# Random password for RDS database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
# store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = "${var.project_name}rds-credentials"
  description             = "Database Credientials for ${var.project_name}"
  recovery_window_in_days = var.secret_recovery_window_days
  tags = {
    Name = "${var.project_name}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = var.db_engine
    host     = aws_db_instance.my_rds_instance.address
    port     = var.db_port
    dbname   = var.db_name
  })
}

# RDS MysQL Database Instance
resource "aws_db_instance" "my_rds_instance" {
  identifier            = "tier-${lower(var.project_name)}-db-instance"
  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted
  #Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = var.db_port
  #Network Configuration
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids     = [var.db_security_group_id]
  publicly_accessible        = false
  availability_zone          = "us-east-2a"
  multi_az                   = var.db_multi_az
  backup_retention_period    = var.backup_retention_period
  backup_window              = var.backup_window
  maintenance_window         = var.maintenance_window
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  tags = {
    Name = "${var.project_name}-instance"
  }
}