# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-tier-sg"
  description = "Security group for web server allow SSH,HTTP,HTTPS traffic"
  vpc_id      = var.vpc_id
  # ssh access from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-tier-security-group"
  }
}

# Generate SSH key pair
resource "tls_private_key" "deployer_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair from generated public key
resource "aws_key_pair" "deployer_key" {
  key_name   = "${var.project_name}-key-pair"
  public_key = tls_private_key.deployer_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key-pair"
  }
}   

# Save private key to local file (for SSH access)
resource "local_file" "private_key" {
  content         = tls_private_key.deployer_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}

resource "aws_security_group" "app_tier" {
  name = "${var.project_name}-apptier-sg"
  description = "security group for application tier"
  vpc_id = var.vpc_id
    # ICMP (ping) from web tier
  ingress {
    description     = "Allow ICMP from web tier"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # HTTP from web tier
  ingress {
    description     = "Allow HTTP from web tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # # SSH from bastion host
  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name = "${var.project_name}-app-sg"
  }

}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.project_name}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # SSH from anywhere (consider restricting to your IP in production)
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id
  # Allow MySQL/Aurora traffic from App Server Security Group
  ingress {
    description     = "Allow MySQL/Aurora traffic from App Server SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }
  # Allow all outbound traffic to application servers
  egress {
    description     = "Allow all outbound traffic"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }
  # Allow all outbound traffic for patches and updates
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}database-sg"
  }
}
# Update Application Server Security Group to allow Mysql/Aurora traffic to/from RDS
resource "aws_security_group_rule" "app_to_db_mysql_rule" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_tier.id
  source_security_group_id = aws_security_group.rds_sg.id
  description              = "Allow MySQL/Aurora traffic to RDS from App Server SG"
}
resource "aws_security_group_rule" "db_from_app_mysql_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_tier.id
  source_security_group_id = aws_security_group.rds_sg.id
  description              = "Allow MySQL/Aurora traffic from App Server SG to RDS"
}