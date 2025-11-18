variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  type = string
  default = "10.0.0.0/16"
}
variable "project_name" {
  description = "Name of my project resources"
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
# Web Tier Variables
variable "web_instance_type" {
  description = "Instance type for web tier"
  type        = string
  default     = "t3.micro"
}
variable "web_min_size" {
  description = "Minimum number of instances in web tier"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Maximum number of instances in web tier"
  type        = number
  default     = 3
}

variable "web_desired_capacity" {
  description = "Desired number of instances in web tier"
  type        = number
  default     = 2
}

variable "app_min_size" {
  description = "Minimum number of instances in app tier"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of instances in app tier"
  type        = number
  default     = 3
}

variable "app_desired_capacity" {
  description = "Desired number of instances in app tier"
  type        = number
  default     = 2
}
variable "app_instance_type" {
  description = "Instance type for app tier"
  type        = string
  default     = "t2.micro"
}

# Database Variables
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}