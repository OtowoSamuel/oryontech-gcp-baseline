# Core Configuration
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
  default     = "staging"

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
}

variable "vpc_connector_max_instances" {
  description = "Maximum number of VPC connector instances"
  type        = number
  default     = 3
}

# Cloud SQL Configuration
variable "database_version" {
  description = "PostgreSQL database version"
  type        = string
  default     = "POSTGRES_15"
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
}

variable "database_disk_size" {
  description = "Initial disk size in GB for Cloud SQL instance"
  type        = number
  default     = 10
}

variable "database_backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7
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
  description = "OpenAI API key to store in Secret Manager (use TF_VAR_openai_api_key env var)"
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
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "512Mi"
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "allow_public_access" {
  description = "Allow public access to Cloud Run service (allUsers invoker)"
  type        = bool
  default     = true
}
variable "github_actions_sa_email" {
  description = "Email of the GitHub Actions service account for Artifact Registry access"
  type        = string
  default     = ""
}