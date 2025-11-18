# Steps to Deploy the 3-Tier Web Application with Terraform State Locking
# This project uses S3 for state storage and DynamoDB for state locking.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (v1.0+)
- Git

## Deployment Steps

### 1. Clone the Repository
```bash
git clone https://github.com/ikramulhaq63/aws-iac-three-tier-stack.git
cd aws-iac-three-tier-stack
```

### 2. Navigate to Environment Directory
```bash
cd environments/dev
```

### 3. Create Bootstrap Resources (S3 Bucket & DynamoDB Table)
```bash
cd bootstrap
terraform init
terraform apply  # Creates S3 bucket and DynamoDB table for state management
cd ..
```

### 4. Initialize Terraform with S3 Backend
```bash
terraform init  # Configures S3 backend with locking
```

### 5. Deploy Infrastructure
```bash
terraform apply  # Creates VPC, subnets, security groups, EC2 instances, RDS, etc.
```

## State Management
- **State Storage**: Stored in S3 bucket `3tier-webapp-terraform-state-dev`
- **State Locking**: Enabled via DynamoDB table `3tier-webapp-terraform-locks-dev`
- **Persistence**: S3 bucket and DynamoDB table survive `terraform destroy`

## Destroy Infrastructure (Optional)
```bash
terraform destroy  # Destroys infrastructure, keeps state storage
```

## Recreate Infrastructure
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