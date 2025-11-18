variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "3tier-webapp"
}
variable "private_subnet_db_tier_1_id" {
  description = "IDs of the private subnets"
  type = string
}
variable "private_subnet_db_tier_2_id" {
  description = "IDs of the private subnets"
  type = string
}
variable "secret_recovery_window_days" {
  description = "Recovery window for secrets manager secret in days"
  type        = number
  default     = 0
}
# Database Configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "myappdb"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "adminuser"
  validation {
    condition     = length(var.db_username) > 0
    error_message = "Database username cannot be empty."
  }
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 3306
}

# Database Engine Configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.db_engine)
    error_message = "Database engine must be one of: mysql, postgres, mariadb."
  }
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

# Storage Configuration
variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GB."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "db_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.db_storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2."
  }
}

variable "db_storage_encrypted" {
  description = "Whether to encrypt the database storage"
  type        = bool
  default     = true
}
variable "db_security_group_id" {
  description = "Security group ID for the database"
  type        = string
}
variable "db_multi_az" {
  description = "Whether to enable multi-AZ deployment"
  type        = bool
  default     = false
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

# Deletion Configuration
variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Whether to enable automatic minor version upgrades"
  type        = bool
  default     = true
}