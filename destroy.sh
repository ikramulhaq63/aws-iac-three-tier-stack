#!/bin/bash

# AWS 3-Tier Web Application Destruction Script
# This script safely destroys the infrastructure while preserving state

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

# Function to destroy main infrastructure
destroy_infrastructure() {
    print_status "Destroying main infrastructure..."

    # Get the script's directory and navigate to environments/dev
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR/environments/dev"

    print_status "Initializing Terraform..."
    terraform init

    print_warning "About to destroy the 3-tier infrastructure. This will remove:"
    echo "  - All EC2 instances and Auto Scaling Groups"
    echo "  - Load Balancers"
    echo "  - RDS MySQL database (with data loss!)"
    echo "  - VPC, subnets, and security groups"
    echo ""
    echo "⚠️  WARNING: Database data will be permanently lost!"
    echo "⚠️  S3 bucket and DynamoDB table will be preserved for state management."
    echo ""

    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destruction cancelled by user."
        exit 0
    fi

    print_status "Planning infrastructure destruction..."
    terraform plan -destroy -out=tfplan-destroy

    print_status "Destroying infrastructure..."
    terraform apply tfplan-destroy

    cd "$SCRIPT_DIR"

    print_success "Main infrastructure destroyed successfully!"
}

# Function to optionally destroy bootstrap resources
destroy_bootstrap() {
    print_warning "Bootstrap resources (S3 bucket and DynamoDB table) are still present."
    echo "These are needed to maintain Terraform state for future deployments."
    echo ""

    read -p "Do you want to destroy bootstrap resources too? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destroying bootstrap resources..."

        # Get the script's directory and navigate to bootstrap
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        cd "$SCRIPT_DIR/environments/dev/bootstrap"

        print_status "Initializing Terraform for bootstrap..."
        terraform init

        print_status "Planning bootstrap destruction..."
        terraform plan -destroy -out=tfplan-destroy

        print_warning "This will permanently remove the S3 bucket and DynamoDB table!"
        read -p "Final confirmation - destroy bootstrap resources? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Destroying bootstrap resources..."
            terraform apply tfplan-destroy

            print_success "Bootstrap resources destroyed successfully!"
            print_warning "Terraform state is no longer persisted. Run deploy.sh again for new deployments."
        else
            print_status "Bootstrap destruction cancelled. Resources preserved."
        fi

        cd "$SCRIPT_DIR"
    else
        print_status "Bootstrap resources preserved for future deployments."
    fi
}

# Function to clean up local files
cleanup_local() {
    print_status "Cleaning up local Terraform files..."

    # Remove plan files
    find . -name "tfplan*" -type f -delete 2>/dev/null || true

    # Remove .terraform directories
    find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true

    # Remove terraform.tfstate files (but keep remote state)
    find . -name "terraform.tfstate*" -type f -delete 2>/dev/null || true

    print_success "Local cleanup completed!"
}

# Main destruction function
main() {
    echo "=========================================="
    echo "🗑️  AWS 3-Tier Web App Destruction Script"
    echo "=========================================="
    echo ""

    check_prerequisites
    destroy_infrastructure
    destroy_bootstrap
    cleanup_local

    echo ""
    print_success "Destruction completed successfully! 🧹"
    echo ""
    echo "Resources cleaned up. You can run './deploy.sh' again for new deployments."
}

# Run main function
main "$@"