# Root configuration for GCP baseline infrastructure

terraform {
  required_version = ">= 1.5.0"

  # Configure remote backend for state management (uncomment and configure)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state/staging"
  # }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.17.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Deploy the GCP Baseline Module
module "gcp_baseline" {
  source = "./modules/gcp-baseline"

  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  openai_api_key = var.openai_api_key

  # VPC Configuration
  vpc_connector_cidr          = var.vpc_connector_cidr
  vpc_connector_machine_type  = var.vpc_connector_machine_type
  vpc_connector_min_instances = var.vpc_connector_min_instances
  vpc_connector_max_instances = var.vpc_connector_max_instances

  # Database Configuration
  database_version               = var.database_version
  database_tier                  = var.database_tier
  database_availability_type     = var.database_availability_type
  database_disk_size             = var.database_disk_size
  database_backup_retention_days = var.database_backup_retention_days
  database_name                  = var.database_name
  database_user                  = var.database_user
  deletion_protection            = var.deletion_protection

  # Cloud Run Configuration
  cloud_run_image         = var.cloud_run_image
  cloud_run_cpu           = var.cloud_run_cpu
  cloud_run_memory        = var.cloud_run_memory
  cloud_run_min_instances = var.cloud_run_min_instances
  cloud_run_max_instances = var.cloud_run_max_instances
  allow_public_access     = var.allow_public_access
}
