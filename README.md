# OryonTech GCP Baseline Infrastructure

A reusable Terraform module for deploying secure baseline infrastructure on GCP. This module provisions Cloud Run, Cloud SQL PostgreSQL with private networking, Secret Manager integration, and proper IAM configuration.

## Overview

This module creates:
- Cloud Run service with auto-scaling
- Cloud SQL PostgreSQL (private IP only, no public access)
- VPC and Serverless VPC Access Connector for private connectivity
- Secret Manager for credential storage
- Service account with least privilege IAM permissions
- Validation tooling (terraform fmt, validate, tflint, checkov)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ HTTPS
                           ▼
                  ┌─────────────────┐
                  │   Cloud Run     │◄─── Secrets from
                  │   (Container)   │     Secret Manager
                  └────────┬────────┘
                           │
                           │ VPC Connector
                           │ (Private Egress)
                           ▼
                      ┌─────────┐
                      │   VPC   │
                      │ Network │
                      └────┬────┘
                           │
                           │ Private IP Only
                           │ (No Public Access)
                           ▼
                  ┌─────────────────┐
                  │  Cloud SQL      │
                  │  PostgreSQL     │
                  │  (Private IP)   │
                  └─────────────────┘
```

Cloud Run connects to Cloud SQL through a Serverless VPC Access Connector over private networking. The database has no public IP address. All secrets are stored in Secret Manager and injected into Cloud Run at runtime.

## Prerequisites

- **GCP Account** with billing enabled
- **gcloud CLI** - [Install](https://cloud.google.com/sdk/docs/install)
- **Terraform** >= 1.5.0 - [Install](https://www.terraform.io/downloads)
- **TFLint** (optional) - [Install](https://github.com/terraform-linters/tflint)
- **Checkov** (optional) - `pip install checkov`

### 1. Authenticate with GCP

```bash
# GCP Account with billing enabled
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed
- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- TFLint (optional for validation)
- Checkov (optional for security scanning):YOUR_PROJECT_ID
```
 How to Deploy

**1. Authenticate with GCP:**

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

**2. Configure Variables:**
Required variables:
```hcl
project_id     = "your-gcp-project-id"
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Set required variables:
```hcl
project_id     = "your-gcp-project-id"
environment    = "staging"
openai_api_key = "sk-your-key"  # or use TF_VAR_openai_api_key env variable
```

**3. Deploy:**

Using the automated script (recommended):
```bash
./scripts/deploy.sh
```

Or manually:
```bash
terraform init
terraform plan
terraform apply
```

## How to Verify

## 📁 Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml      # CI/CD pipeline
├── modules/
│   └── gcp-baseline/             # Main Terraform module
│       ├── main.tf               # Core infrastructure
│       ├── variables.tf          # Input variables
│       ├── outputs.tf            # Output values
│       └── README.md             # Module documentation
├── examples/
│   └── sample-app/               # Sample application
│       ├── Dockerfile
│       ├── app.py                # Flask app with DB connectivity
│       └── requirements.txt
├── scripts/
│   ├── deploy.sh                 # Automated deployment
│   ├── validate.sh               # Validation checks
│   ├── verify.sh                 # Post-deployment verification
│   └── destroy.sh                # Safe cleanup
├── main.tf                       # Root module configuration
├── variables.tf                  # Root variables
├── outputs.tf                    # Root outputs
├── terraform.tfvars.example      # Example configuration
├── .tflint.hcl                   # TFLint configuration
├── .checkov.yml                  # Checkov security scanning
└── README.md                     # This file
## Validation Gates

This project implements four automated validation checks:

1. **terraform fmt** - Code formatting
2. **terraform validate** - Configuration validation
3. **tflint** - Static analysis with GCP rules
4. **checkov** - Security scanning (200+ checks)

Run all validations:
```bash
./scripts/validate.sh
```

Or individually:
```bash
terraform fmt -check -recursive
terraform validate
tflint --init && tflint --recursive
checkov -d . --config-file .checkov.yml
```

## IAM & Security

The Cloud Run service account has least privilege access with only these permissions:
- `roles/cloudsql.client` - Connect to Cloud SQL
- `roles/secretmanager.secretAccessor` - Access specific secrets only (not project-wide)

All secrets are stored in Secret Manager:
- OPENAI_API_KEY
- DB_CONNECTION_NAME
- DB_USER
- DB_PASSWORD (auto-generated)
- DB_NAME

Cloud SQL has NO public IP address and is only accessible via private VPC networking.

## How to Destroy

```bash
# Run cleanup script (with confirmation)
./scripts/destroy.sh

# Or manually
terraform destroy
```

**⚠️ Warning**: This will permanently delete:
- Cloud Run service
- Cloud SQL database and all data
- VPC and networking
- Secret Manager secrets
- Service accounts

## 🎯 Cost Optimization

### Estimated Monthly Costs (Free Tier)

- **Cloud Run**: Free tier covers 2M requests/month
- **Cloud SQL**: db-f1-micro ~$7-10/month
- **VPC Connector**: ~$8/month
- **Secret Manager**: First 6 secrets free
- **Total**: ~$15-20/month for staging

### Production Recommendations

```hcl
# For production environment
database_tier              = "db-custom-2-7680"
database_availability_type = "REGIONAL"  # High availability
cloud_run_min_instances    = 1           # Always warm
deletion_protection        = true        # Prevent accidental deletion
```

## 🔧 Advanced Configuration

### Using Remote State

```hcl
# Configure in main.tf
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/state/staging"
  }
}
```

### Multiple Environments

```bash
# Create workspace per environment
terraform workspace new production
terraform workspace select production

# Or use separate state files
terraform apply -var-file=production.tfvars
```

### Custom Container Image

```bash
# Build your application
cd examples/sample-app
docker build -t gcr.io/PROJECT_ID/oryontech-app:v1.0.0 .

# Push to registry
docker push gcr.io/PROJECT_ID/oryontech-app:v1.0.0

# Update terraform.tfvars
cloud_run_image = "gcr.io/PROJECT_ID/oryontech-app:v1.0.0"

# Apply changes
terraform apply
```

## 📚 Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [VPC Access Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🐛 Troubleshooting

### Common Issues

**1. VPC Connector creation fails**
```
Error: Quota exceeded for resource 'VPC_ACCESS_CONNECTORS'
```
Solution: Request quota increase or use existing connector

**2. Cloud SQL connection timeout**
```
Error: dial tcp: i/o timeout
```
Solution: Verify VPC connector is attached and instance has private IP

**3. Permission denied errors**
```
Error: googleapi: Error 403: Permission denied
```
Solution: Verify service account has required IAM roles

### Debug Mode

## How to Destroy

**Using the cleanup script (recommended):**
```bash
./scripts/destroy.sh
```

**Or manually:**
```bash
terraform destroy
```

This will remove all resources including Cloud Run service, Cloud SQL database, VPC networking, secrets, and service accounts. The destroy operation requires confirmation before proceeding.

## Repository Structure

```
.
├── modules/gcp-baseline/     # Reusable Terraform module
├── examples/sample-app/      # Sample Flask app with DB connectivity
├── scripts/                  # Automation scripts (deploy, validate, verify, destroy)
├── .github/workflows/        # CI/CD pipeline
├── main.tf                   # Root configuration
├── variables.tf              # Input variables
├── outputs.tf                # Outputs
└── terraform.tfvars.example  # Example configuration
```

## Additional Notes

**Private Networking Approach:** This implementation uses Serverless VPC Access Connector. Cloud Run connects to the VPC connector, which provides access to the private VPC where Cloud SQL resides. This is the recommended approach for Cloud Run to Cloud SQL private connectivity.

**Cost:** Estimated ~$15-20/month for staging environment with minimal usage.

**Observability:** The sample application includes structured logging, health check endpoints (`/health` and `/health/db`), and Cloud SQL insights are enabled for query analysis.

**Infracost:** CI/CD pipeline includes Infracost integration (see `.github/workflows/terraform-ci.yml`). Set `INFRACOST_API_KEY` secret to enable cost estimation on pull requests.

---

Built for OryonTech DevOps Technical Challenge
