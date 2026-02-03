output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.name
}

output "cloud_run_service_account" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloud_run_sa.email
}

output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "database_connection_name" {
  description = "Connection name for Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_connector_name" {
  description = "Name of the VPC connector"
  value       = google_vpc_access_connector.connector.name
}

output "secret_manager_secrets" {
  description = "Map of Secret Manager secret IDs"
  value = {
    openai_api_key     = google_secret_manager_secret.openai_api_key.secret_id
    db_connection_name = google_secret_manager_secret.db_connection_name.secret_id
    db_user            = google_secret_manager_secret.db_user.secret_id
    db_password        = google_secret_manager_secret.db_password.secret_id
    db_name            = google_secret_manager_secret.db_name.secret_id
  }
}

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
output "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "artifact_registry_repository_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "artifact_registry_docker_image_prefix" {
  description = "Prefix for Docker images in the Artifact Registry"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/oryontech-app"
}