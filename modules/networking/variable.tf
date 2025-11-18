variable "vpc_cidr" {
    description = "CIDR block for my VPC"
    type = string
    validation {
        condition     = can(cidrhost(var.vpc_cidr, 0))
        error_message = "VPC CIDR must be a valid IPv4 CIDR block."
    }
}

variable "project_name" {
  description = "Name of the project for the resource"
  type = string
  default = "3tier-webapp"
}

variable "public_subnet_1_cidr" {
  description = "my public subnet 1"
  type = string
  default = "10.0.1.0/24"
}
variable "public_subnet_2_cidr" {
  description = "My public subnet 2"
  type = string
  default = "10.0.2.0/24"
}
variable "availability_zone_1" {
  description = "availabile zone 1"
  type = string
  default = "us-east-2a"
}
variable "availability_zone_2" {
  description = "available zone 2"
  type = string
  default = "us-east-2b"
}
variable "private_subnet_1_app_cidr" {
  description = "my public subnet 1"
  type = string
  default = "10.0.11.0/24"
}
variable "private_subnet_2_app_cidr" {
  description = "My public subnet 2"
  type = string
  default = "10.0.12.0/24"
}
variable "private_subnet_1_db_cidr" {
  description = "my public subnet 1"
  type = string
  default = "10.0.13.0/24"
}
variable "private_subnet_2_db_cidr" {
  description = "My public subnet 2"
  type = string
  default =  "10.0.14.0/24"
}