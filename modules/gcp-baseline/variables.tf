variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

# VPC Configuration
variable "vpc_connector_cidr" {
  description = "CIDR range for VPC connector subnet (must be /28)"
  type        = string
  default     = "10.8.0.0/28"

  validation {
    condition     = can(cidrhost(var.vpc_connector_cidr, 0)) && split("/", var.vpc_connector_cidr)[1] == "28"
    error_message = "VPC connector CIDR must be a valid /28 range."
  }
}

variable "vpc_connector_machine_type" {
  description = "Machine type for VPC connector"
  type        = string
  default     = "e2-micro"
}

variable "vpc_connector_min_instances" {
  description = "Minimum number of VPC connector instances"
  type        = number
  default     = 2

  validation {
    condition     = var.vpc_connector_min_instances >= 2 && var.vpc_connector_min_instances <= 10
    error_message = "VPC connector min instances must be between 2 and 10."
  }
}

variable "vpc_connector_max_instances" {
  description = "Maximum number of VPC connector instances"
  type        = number
  default     = 3

  validation {
    condition     = var.vpc_connector_max_instances >= 2 && var.vpc_connector_max_instances <= 10
    error_message = "VPC connector max instances must be between 2 and 10."
  }
}

# Cloud SQL Configuration
variable "database_version" {
  description = "PostgreSQL database version"
  type        = string
  default     = "POSTGRES_15"

  validation {
    condition     = can(regex("^POSTGRES_[0-9]+$", var.database_version))
    error_message = "Database version must be in format POSTGRES_XX."
  }
}

variable "database_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "database_availability_type" {
  description = "Availability type for Cloud SQL instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.database_availability_type)
    error_message = "Database availability type must be either ZONAL or REGIONAL."
  }
}

variable "database_disk_size" {
  description = "Initial disk size in GB for Cloud SQL instance"
  type        = number
  default     = 10

  validation {
    condition     = var.database_disk_size >= 10
    error_message = "Database disk size must be at least 10 GB."
  }
}

variable "database_backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7

  validation {
    condition     = var.database_backup_retention_days >= 1 && var.database_backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}

variable "database_name" {
  description = "Name of the PostgreSQL database to create"
  type        = string
  default     = "oryontech_db"
}

variable "database_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "oryontech_user"
}

variable "deletion_protection" {
  description = "Enable deletion protection for Cloud SQL instance"
  type        = bool
  default     = true
}

# Secrets Configuration
variable "openai_api_key" {
  description = "OpenAI API key to store in Secret Manager"
  type        = string
  sensitive   = true
}

# Cloud Run Configuration
variable "cloud_run_image" {
  description = "Container image for Cloud Run service"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service"
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "4", "8"], var.cloud_run_cpu)
    error_message = "Cloud Run CPU must be 1, 2, 4, or 8."
  }
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "512Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.cloud_run_memory))
    error_message = "Cloud Run memory must be in format like '512Mi' or '2Gi'."
  }
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0

  validation {
    condition     = var.cloud_run_min_instances >= 0 && var.cloud_run_min_instances <= 100
    error_message = "Cloud Run min instances must be between 0 and 100."
  }
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10

  validation {
    condition     = var.cloud_run_max_instances >= 1 && var.cloud_run_max_instances <= 1000
    error_message = "Cloud Run max instances must be between 1 and 1000."
  }
}

variable "allow_public_access" {
  description = "Allow public access to Cloud Run service (allUsers invoker)"
  type        = bool
  default     = false
}

variable "github_actions_sa_email" {
  description = "Email of the GitHub Actions service account for Artifact Registry access"
  type        = string
  default     = ""
}

