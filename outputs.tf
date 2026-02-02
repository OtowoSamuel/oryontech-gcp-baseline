output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = module.gcp_baseline.cloud_run_url
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = module.gcp_baseline.cloud_run_service_name
}

output "cloud_run_service_account" {
  description = "Email of the Cloud Run service account"
  value       = module.gcp_baseline.cloud_run_service_account
}

output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.gcp_baseline.database_instance_name
}

output "database_connection_name" {
  description = "Connection name for Cloud SQL instance"
  value       = module.gcp_baseline.database_connection_name
}

output "database_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.gcp_baseline.database_private_ip
  sensitive   = true
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.gcp_baseline.vpc_network_name
}

output "vpc_connector_name" {
  description = "Name of the VPC connector"
  value       = module.gcp_baseline.vpc_connector_name
}

output "secret_manager_secrets" {
  description = "Map of Secret Manager secret IDs"
  value       = module.gcp_baseline.secret_manager_secrets
}

output "project_id" {
  description = "GCP project ID"
  value       = module.gcp_baseline.project_id
}

output "region" {
  description = "GCP region"
  value       = module.gcp_baseline.region
}

output "environment" {
  description = "Environment name"
  value       = module.gcp_baseline.environment
}

# Deployment summary
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    cloud_run_url         = module.gcp_baseline.cloud_run_url
    database_connection   = module.gcp_baseline.database_connection_name
    vpc_connector         = module.gcp_baseline.vpc_connector_name
    service_account       = module.gcp_baseline.cloud_run_service_account
    environment           = module.gcp_baseline.environment
    region                = module.gcp_baseline.region
  }
}
