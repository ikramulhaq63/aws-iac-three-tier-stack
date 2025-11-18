# AWS 3-Tier Web Application Infrastructure as Code

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

A production-ready Terraform configuration that deploys a highly available, scalable 3-tier web application architecture on AWS. This project implements the architecture described in the [Medium article](https://medium.com/@aaloktrivedi/building-a-3-tier-web-application-architecture-with-aws-1b2c5e35b5a3) by Aalok Trivedi, but fully automated with Infrastructure as Code.

## 🏗️ Architecture Overview

This implementation creates a secure, highly available 3-tier architecture across multiple Availability Zones:

```
Internet
    ↓
[Application Load Balancer] (Web Tier)
    ↓
[Auto Scaling Group - Web Servers] (Public Subnets)
    ↓
[Application Load Balancer] (App Tier)
    ↓
[Auto Scaling Group - App Servers] (Private Subnets)
    ↓
[Amazon RDS MySQL] (Database Tier - Private Subnets)
```

### Key Components

- **Web Tier**: Auto-scaling EC2 instances behind an Application Load Balancer
- **Application Tier**: Backend servers in private subnets with internal load balancing
- **Database Tier**: MySQL RDS instance with Multi-AZ deployment
- **Networking**: VPC with public/private subnets across multiple AZs
- **Security**: Security groups with least-privilege access
- **State Management**: S3 backend with DynamoDB locking for team collaboration

## ✨ Features

- 🚀 **Highly Available**: Multi-AZ deployment with auto-scaling
- 🔒 **Secure**: Private subnets, security groups, and encrypted state
- 📈 **Scalable**: Auto-scaling groups with CPU-based scaling policies
- 🛡️ **Production-Ready**: State locking, versioning, and backup retention
- 🤝 **Team-Friendly**: Remote state management for collaboration
- 📚 **Well-Documented**: Comprehensive README and inline comments
- 🧪 **Tested**: Validated Terraform configurations

## 📋 Prerequisites

Before deploying, ensure you have:

- **AWS Account** with appropriate permissions
- **AWS CLI** configured (`aws configure`)
- **Terraform** v1.0 or later
- **Git** for cloning the repository
- **SSH Key Pair** for EC2 access (created in AWS console)

### Required AWS Permissions

Your AWS user/role needs these permissions:
- EC2 full access
- VPC full access
- RDS full access
- S3 full access
- DynamoDB full access
- IAM full access (for key pairs)
- Auto Scaling full access
- ELB full access

## 🚀 Quick Start

For the impatient, here's the fast track:

```bash
# Clone and deploy
git clone https://github.com/ikramulhaq63/aws-iac-three-tier-stack.git
cd aws-iac-three-tier-stack
./deploy.sh

# Access your application
# Get the ALB DNS from Terraform outputs
terraform output web_alb_dns
```

## 📖 Detailed Deployment Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/ikramulhaq63/aws-iac-three-tier-stack.git
cd aws-iac-three-tier-stack
```

### Step 2: Configure Your Environment

Edit `environments/dev/terraform.tfvars` to customize:

```hcl
# Example customizations
project_name = "my-awesome-app"
vpc_cidr = "10.0.0.0/16"
web_instance_type = "t3.small"
db_instance_class = "db.t3.small"
```

### Step 3: Deploy Bootstrap Resources

First, create the S3 bucket and DynamoDB table for state management:

```bash
cd environments/dev/bootstrap
terraform init
terraform apply
cd ../..
```

### Step 4: Deploy Infrastructure

Now deploy the full 3-tier stack:

```bash
cd environments/dev
terraform init  # Migrates to S3 backend
terraform plan  # Review changes
terraform apply # Deploy everything
```

### Step 5: Access Your Application

After deployment, get the web tier load balancer DNS:

```bash
terraform output web_alb_dns
```

Visit the DNS name in your browser to see the Apache welcome page!

## 🛠️ Available Scripts

This project includes helper scripts for easier management:

### `deploy.sh`
Automated deployment script that handles the entire process:

```bash
./deploy.sh
```

### `destroy.sh`
Safe destruction script that preserves state storage:

```bash
./destroy.sh
```

### Manual Commands

If you prefer manual control:

```bash
# Bootstrap (run once)
cd environments/dev/bootstrap && terraform init && terraform apply && cd ../..

# Deploy infrastructure
cd environments/dev && terraform init && terraform apply

# Destroy infrastructure (keeps state)
cd environments/dev && terraform destroy

# Destroy everything including state (use with caution!)
cd environments/dev/bootstrap && terraform destroy
```

## 📊 Architecture Details

### Networking
- **VPC**: 10.0.0.0/16 CIDR
- **Public Subnets**: 2 subnets for web tier load balancers
- **Private App Subnets**: 2 subnets for application servers
- **Private DB Subnets**: 2 subnets for RDS instances
- **NAT Gateway**: For private subnet internet access
- **Internet Gateway**: For public subnet internet access

### Security Groups
- **Web Tier**: Allows HTTP/HTTPS from anywhere, SSH from your IP
- **App Tier**: Allows HTTP from web tier, SSH from bastion host
- **Database**: Allows MySQL from app tier only
- **Bastion**: Allows SSH from your IP only

### Auto Scaling
- **Web Tier**: 2-3 instances, scales on CPU > 50%
- **App Tier**: 1-3 instances, scales on CPU > 50%

### Database
- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro (configurable)
- **Storage**: 20GB with 100GB max auto-scaling
- **Backup**: 7-day retention
- **Multi-AZ**: Disabled (enable for production)

## 🔧 Customization

### Environment Variables

Create multiple environments by copying the `dev` folder:

```bash
cp -r environments/dev environments/prod
# Edit terraform.tfvars in prod for different settings
```

### Scaling Configuration

Adjust scaling in `terraform.tfvars`:

```hcl
# Web tier scaling
web_min_size = 2
web_max_size = 10
web_desired_capacity = 3

# App tier scaling
app_min_size = 1
app_max_size = 5
app_desired_capacity = 2
```

### Database Configuration

Customize database settings:

```hcl
db_engine = "mysql"
db_engine_version = "8.0"
db_instance_class = "db.t3.small"
db_allocated_storage = 20
```

## 🧪 Testing

After deployment, verify:

1. **Web Access**: Visit ALB DNS - should show Apache page
2. **SSH Access**: Connect via bastion host to app servers
3. **Database**: Connect from app server using MySQL client
4. **Scaling**: Monitor CPU and verify auto-scaling works
5. **High Availability**: Test failover (terminate instances)

## 🛡️ Security Considerations

- All sensitive data is parameterized (no hardcoded secrets)
- Database credentials stored in AWS Secrets Manager
- Private subnets protect backend services
- Security groups follow least-privilege principle
- SSH access restricted to bastion host
- State files encrypted in S3

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork and clone
git clone https://github.com/your-username/aws-iac-three-tier-stack.git

# Create feature branch
git checkout -b feature/amazing-improvement

# Make changes, test thoroughly
terraform validate
terraform plan

# Submit pull request
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Aalok Trivedi's Medium article](https://medium.com/@aaloktrivedi/building-a-3-tier-web-application-architecture-with-aws-1b2c5e35b5a3)
- Thanks to the Terraform and AWS communities for excellent documentation
- Special thanks to all contributors and users

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/ikramulhaq63/aws-iac-three-tier-stack/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ikramulhaq63/aws-iac-three-tier-stack/discussions)
- **Documentation**: Check the [Wiki](https://github.com/ikramulhaq63/aws-iac-three-tier-stack/wiki)

---

**Happy Deploying!** 🎉

Built with ❤️ for the DevOps community
```bash
terraform init    # Retrieves state from S3
terraform apply   # Recreates infrastructure
```

## For Different Environments
- Copy the `dev` folder to `prod`, `staging`, etc.
- Update bucket/table names in `bootstrap.tf` and `main.tf` backend config
- Repeat steps 3-5 for each environment

## Security Notes
- S3 bucket has versioning and server-side encryption enabled
- State is encrypted in transit and at rest
- DynamoDB table uses pay-per-request billing for cost efficiency