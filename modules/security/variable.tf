# Security Module Variables

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "3tier-webapp"
}