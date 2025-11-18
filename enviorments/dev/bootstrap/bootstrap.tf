# Bootstrap resources for Terraform state management
# Run terraform apply on this file first to create the S3 bucket and DynamoDB table
# Then run terraform apply on main.tf for the infrastructure

provider "aws" {
  alias  = "bootstrap"
  region = "us-east-2"
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.bootstrap
  bucket = "3tier-webapp-terraform-state-dev"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  provider = aws.bootstrap
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  provider = aws.bootstrap
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for locking
resource "aws_dynamodb_table" "terraform_locks" {
  provider = aws.bootstrap
  name         = "3tier-webapp-terraform-locks-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}