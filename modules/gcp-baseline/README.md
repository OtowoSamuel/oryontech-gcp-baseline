# Module README

## GCP Baseline Infrastructure Module

This Terraform module provides a secure baseline infrastructure for OryonTech's Agent-as-a-Service platform on Google Cloud Platform.

### Features

- **Cloud Run Service** with auto-scaling and health checks
- **Cloud SQL PostgreSQL** with private networking (no public IP)
- **VPC and Serverless VPC Access Connector** for private connectivity
- **Secret Manager** for secure credential storage
- **IAM with Least Privilege** - service account with only required permissions
- **Automated API enablement**
- **Comprehensive security controls**

### Architecture

```
┌─────────────────┐
│   Cloud Run     │
│   (Container)   │
└────────┬────────┘
         │
         │ VPC Connector
         │
    ┌────▼────┐
    │   VPC   │
    └────┬────┘
         │ Private IP
         │
┌────────▼────────┐
│  Cloud SQL      │
│  (PostgreSQL)   │
│  No Public IP   │
└─────────────────┘
```

### Security Features

1. **Network Isolation**: Cloud SQL has no public IP, only accessible via private VPC
2. **Secrets Management**: All credentials stored in Secret Manager, injected at runtime
3. **Least Privilege IAM**: Service account with minimal required permissions
4. **SSL/TLS Enforcement**: Required for all database connections
5. **Audit Logging**: Connection and query logging enabled
6. **Backup & Recovery**: Automated backups with point-in-time recovery

### Usage

```hcl
module "gcp_baseline" {
  source = "./modules/gcp-baseline"

  project_id      = "your-project-id"
  region          = "us-central1"
  environment     = "staging"
  openai_api_key  = "your-openai-api-key" # Use from Secret Manager or CI/CD

  # Optional overrides
  database_tier              = "db-f1-micro"
  cloud_run_min_instances    = 0
  cloud_run_max_instances    = 10
  allow_public_access        = false
}
```

### Outputs

- `cloud_run_url`: URL of the deployed Cloud Run service
- `database_connection_name`: Cloud SQL connection string
- `vpc_connector_name`: VPC connector for private access
- `secret_manager_secrets`: Map of all secret IDs

For complete list, see `outputs.tf`.
