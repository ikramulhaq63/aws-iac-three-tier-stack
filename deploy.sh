#!/bin/bash

# AWS 3-Tier Web Application Deployment Script
# This script automates the deployment of the 3-tier architecture

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if AWS CLI is installed and configured
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi

    # Check AWS CLI configuration
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi

    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform v1.0+ first."
        exit 1
    fi

    print_success "Prerequisites check passed!"
}

# Function to deploy bootstrap resources
deploy_bootstrap() {
    print_status "Deploying bootstrap resources (S3 bucket and DynamoDB table)..."

    # Get the script's directory and navigate to bootstrap
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR/environments/dev/bootstrap"

    print_status "Initializing Terraform for bootstrap..."
    terraform init

    print_status "Planning bootstrap deployment..."
    terraform plan -out=tfplan

    print_status "Applying bootstrap resources..."
    # Try to apply, but don't fail if resources already exist
    if ! terraform apply tfplan 2>/dev/null; then
        print_warning "Bootstrap resources may already exist. Continuing with deployment..."
    else
        print_success "Bootstrap resources deployed successfully!"
    fi

    cd "$SCRIPT_DIR"

    print_success "Bootstrap resources check completed!"
}

# Function to deploy main infrastructure
deploy_infrastructure() {
    print_status "Deploying main infrastructure..."

    # Get the script's directory and navigate to environments/dev
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR/environments/dev"

    print_status "Initializing Terraform with S3 backend..."
    terraform init

    print_status "Planning infrastructure deployment..."
    terraform plan -out=tfplan

    print_warning "About to deploy the 3-tier infrastructure. This will create:"
    echo "  - VPC with public/private subnets"
    echo "  - Security groups"
    echo "  - EC2 instances and Auto Scaling Groups"
    echo "  - Load Balancers"
    echo "  - RDS MySQL database"
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled by user."
        exit 0
    fi

    print_status "Applying infrastructure..."
    terraform apply tfplan

    cd "$SCRIPT_DIR"

    print_success "Infrastructure deployed successfully!"
}

# Function to show outputs
show_outputs() {
    print_status "Getting deployment outputs..."

    # Get the script's directory and navigate to environments/dev
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR/environments/dev"

    echo ""
    echo "=========================================="
    echo "🚀 DEPLOYMENT COMPLETE!"
    echo "=========================================="
    echo ""

    # Get outputs
    WEB_ALB_DNS=$(terraform output -raw web_alb_dns 2>/dev/null || echo "N/A")
    BASTION_PUBLIC_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "N/A")
    DB_ENDPOINT=$(terraform output -raw db_endpoint 2>/dev/null || echo "N/A")

    cd "$SCRIPT_DIR"

    echo "🌐 Web Application URL: http://$WEB_ALB_DNS"
    echo "🖥️  Bastion Host IP: $BASTION_PUBLIC_IP"
    echo "🗄️  Database Endpoint: $DB_ENDPOINT"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Visit the web application URL to see the Apache welcome page"
    echo "  2. SSH to bastion host: ssh -i your-key.pem ec2-user@$BASTION_PUBLIC_IP"
    echo "  3. From bastion, SSH to app servers for management"
    echo "  4. Connect to database from app servers using the endpoint"
    echo ""
    echo "⚠️  Remember to run './destroy.sh' when done to avoid charges!"
}

# Main deployment function
main() {
    echo "=========================================="
    echo "🚀 AWS 3-Tier Web App Deployment Script"
    echo "=========================================="
    echo ""

    check_prerequisites
    deploy_bootstrap
    deploy_infrastructure
    show_outputs

    echo ""
    print_success "Deployment completed successfully! 🎉"
    echo ""
    echo "Don't forget to:"
    echo "  - Test your application"
    echo "  - Run './destroy.sh' when finished to clean up resources"
    echo "  - Check AWS console for any additional costs"
}

# Run main function
main "$@"