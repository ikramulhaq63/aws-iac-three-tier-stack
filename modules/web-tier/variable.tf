variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "3tier-webapp"
}
variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}
# Security Configuration
variable "web_security_group_id" {
  description = "Security group ID for web tier"
  type        = string
}
# Instance Configuration
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro" 
}
variable "key_pair_name" {
  description = "Name of the key pair for EC2 instances"
  type        = string
}
variable "public_subnet_1_id" {
  description = "IDs of the public subnets"
  type = string
}
variable "public_subnet_2_id" {
  description = "IDs of the public subnets"
  type = string
}
# Auto Scaling Configuration
variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
  validation {
    condition     = var.min_size >= 1
    error_message = "Minimum size must be at least 1."
  }
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 10
  validation {
    condition     = var.max_size >= var.min_size
    error_message = "Maximum size must be greater than or equal to minimum size."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "Desired capacity must be between min_size and max_size."
  }
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 50.0
  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target value must be between 0 and 100."
  }
}
# variable "private_web_tier_subnet_1_id" {
#   description = "IDs of the private subnet for web tier"
#   type = string
# }
# variable "private_web_tier_subnet_2_id" {
#   description = "IDs of the private subnet for web tier"
#   type = string
# }