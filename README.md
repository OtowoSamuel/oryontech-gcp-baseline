# OryonTech GCP Baseline Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.14.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Provider%207.17-4285F4?logo=google-cloud)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Production-grade Terraform infrastructure for OryonTech's Agent-as-a-Service platform on Google Cloud Platform**

## 📋 Overview

This repository contains a reusable, secure, and production-ready Terraform module that provisions baseline infrastructure for OryonTech's multi-tenant Agent-as-a-Service platform on GCP.

### Key Features

- ✅ **Cloud Run Service** - Serverless container deployment with auto-scaling
- ✅ **Cloud SQL PostgreSQL** - Private networking (no public IP)
- ✅ **VPC & Serverless VPC Access** - Secure private connectivity
- ✅ **Secret Manager** - Secure credential storage and injection
- ✅ **Least Privilege IAM** - Service account with minimal required permissions
- ✅ **Infrastructure Validation** - Format, validate, lint, and security scanning
- ✅ **CI/CD Ready** - GitHub Actions workflow included
- ✅ **Cost Estimation** - Infracost integration (optional)
- ✅ **Observability** - Structured logging and health checks

## 🏗️ Architecture

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
                  │  🔒 Private IP  │
                  └─────────────────┘
```

### Security Architecture

1. **Network Isolation**: Cloud SQL accessible only via private VPC, no public IP
2. **Secret Management**: All credentials in Secret Manager, injected at runtime
3. **Least Privilege**: Service account with minimal scoped permissions
4. **Encrypted Transit**: SSL/TLS required for all database connections
5. **Audit Logging**: Connection and query logging enabled
6. **Automated Backups**: Point-in-time recovery with 7-day retention

## 🚀 Quick Start

### Prerequisites

- **GCP Account** with billing enabled
- **gcloud CLI** - [Install](https://cloud.google.com/sdk/docs/install)
- **Terraform** >= 1.5.0 - [Install](https://www.terraform.io/downloads)
- **TFLint** (optional) - [Install](https://github.com/terraform-linters/tflint)
- **Checkov** (optional) - `pip install checkov`

### 1. Authenticate with GCP

```bash
# Authenticate with your GCP account
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Required variables:
```hcl
project_id     = "your-gcp-project-id"
environment    = "staging"
openai_api_key = "sk-your-key"  # Or use TF_VAR_openai_api_key env var
```

### 3. Deploy Infrastructure

#### Option A: Automated Deployment (Recommended)

```bash
# Run the deployment script
./scripts/deploy.sh
```

#### Option B: Manual Deployment

```bash
# Validate configuration
./scripts/validate.sh

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply changes
terraform apply
```

### 4. Verify Deployment

```bash
# Run verification checks
./scripts/verify.sh

# Or manually check
terraform output
gcloud run services list
gcloud sql instances list
```

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
```

## 🔍 Validation Gates

The infrastructure includes comprehensive validation:

### 1. Terraform Format
```bash
terraform fmt -check -recursive
```

### 2. Terraform Validate
```bash
terraform validate
```

### 3. TFLint
```bash
tflint --init
tflint --recursive
```

### 4. Checkov Security Scan
```bash
checkov -d . --config-file .checkov.yml
```

### 5. Automated Testing
```bash
# Run all validations
./scripts/validate.sh
```

## 🔐 IAM & Security

### Service Account Permissions

The Cloud Run service account has **least privilege** access:

- `roles/cloudsql.client` - Connect to Cloud SQL
- `roles/secretmanager.secretAccessor` - Access specific secrets only

### Secrets Managed

All secrets stored in Secret Manager:
- `OPENAI_API_KEY` - OpenAI API credentials
- `DB_CONNECTION_NAME` - Cloud SQL connection string
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password (auto-generated)
- `DB_NAME` - Database name

## 📊 Outputs

After deployment, you'll get:

```hcl
cloud_run_url              = "https://staging-app-xxx.run.app"
database_connection_name   = "project:region:instance"
vpc_connector_name         = "staging-vpc-connector"
service_account           = "staging-cloud-run-sa@project.iam.gserviceaccount.com"
```

## 🧪 Testing & Verification

### Health Check Endpoints

Using the sample application:

```bash
# Basic health check
curl https://your-service-url/health

# Database connectivity check
curl https://your-service-url/health/db

# Service information
curl https://your-service-url/info
```

### View Logs

```bash
# Cloud Run logs
gcloud run logs read --service=staging-app --limit=50

# Cloud SQL logs
gcloud sql operations list --instance=staging-postgres-xxxx
```

### Connect to Database (via Cloud SQL Proxy)

```bash
# Install Cloud SQL Proxy
gcloud components install cloud-sql-proxy

# Connect using connection name from outputs
cloud-sql-proxy PROJECT:REGION:INSTANCE
```

## 🔄 CI/CD Pipeline

GitHub Actions workflow includes:

- ✅ **Terraform Format** check
- ✅ **Terraform Validate**
- ✅ **TFLint** static analysis
- ✅ **Checkov** security scanning
- ✅ **Terraform Plan** on PRs
- ✅ **Infracost** cost estimation (optional)
- ✅ **Trivy** vulnerability scanning

### Setup GitHub Secrets

Required secrets for CI/CD:
```
GCP_SA_KEY         # Service account JSON key
GCP_PROJECT_ID     # Your GCP project ID
OPENAI_API_KEY     # OpenAI API key
INFRACOST_API_KEY  # Infracost API key (optional)
```

## 🗑️ Cleanup

### Safe Destruction

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

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# Check Cloud Run logs
gcloud run logs read --service=SERVICE_NAME --limit=100

# Test VPC connectivity
gcloud compute networks subnets describe SUBNET_NAME --region=REGION
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 👤 Author

**Samuel Otowo**
- Senior DevOps Engineer
- Submission for OryonTech Technical Challenge

## 🙏 Acknowledgments

- OryonTech Engineering Leadership for the challenge
- HashiCorp for Terraform
- Google Cloud Platform for excellent documentation
- Open source community for tooling and best practices

---

**Built with ❤️ using Infrastructure as Code best practices**
