# OryonTech GCP Baseline Infrastructure

A production-ready Terraform module for deploying secure baseline infrastructure on GCP with complete CI/CD pipeline. Features Cloud Run, private Cloud SQL PostgreSQL, Artifact Registry, automated deployments, security scanning, and cost estimation.

## Overview

This infrastructure provisions:
- **Cloud Run** service with auto-scaling and health checks
- **Cloud SQL PostgreSQL** (private IP only, no public access)
- **Artifact Registry** for Docker image storage
- **VPC** and Serverless VPC Access Connector for private connectivity
- **Secret Manager** for secure credential storage
- **Service accounts** with least privilege IAM permissions
- **CI/CD Pipeline** with GitHub Actions (validation, security, cost estimation, Docker build/deploy)
- **Security scanning** with Trivy and Checkov
- **Cost estimation** with Infracost on infrastructure changes

## Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                        Internet / GitHub                            │
└────────────────────────┬───────────────────────────┬────────────────┘
                         │                           │
                    HTTPS│                           │ CI/CD Pipeline
                         ▼                           ▼
                ┌─────────────────┐         ┌──────────────────┐
                │   Cloud Run     │◄────────│ Artifact Registry│
                │   (Container)   │  Deploy │ (Docker Images)  │
                └────────┬────────┘         └──────────────────┘
                         │
                         │ Secrets from Secret Manager:
                         │ - OPENAI_API_KEY
                         │ - DB_CONNECTION_NAME
                         │ - DB_USER / DB_PASSWORD / DB_NAME
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

**Key Security Features:**
- Cloud Run connects to Cloud SQL via VPC Connector (private networking only)
- Database has NO public IP address
- All secrets stored in Secret Manager
- Service account with least privilege permissions
- Docker images scanned for vulnerabilities before deployment

## Prerequisites

- **GCP Account** with billing enabled
- **gcloud CLI** - [Install](https://cloud.google.com/sdk/docs/install)
- **Terraform** >= 1.5.0 - [Install](https://www.terraform.io/downloads)
- **GitHub Account** (for CI/CD pipeline)
- **TFLint** (optional) - [Install](https://github.com/terraform-linters/tflint)
- **Checkov** (optional) - `pip install checkov`

## 🚀 Quick Start

### 1. Authenticate with GCP

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Enable Required APIs

```bash
gcloud services enable compute.googleapis.com \
  servicenetworking.googleapis.com \
  sqladmin.googleapis.com \
  run.googleapis.com \
  vpcaccess.googleapis.com \
  secretmanager.googleapis.com \
  cloudresourcemanager.googleapis.com \
  artifactregistry.googleapis.com
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Set required variables:
```hcl
project_id                = "your-gcp-project-id"
environment               = "staging"
openai_api_key            = "sk-your-key"
github_actions_sa_email   = "github-actions@your-project.iam.gserviceaccount.com"
```

### 4. Deploy Infrastructure

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

### 5. Set Up CI/CD (GitHub Actions)

```bash
# Create GitHub Actions service account
gcloud iam service-accounts create staging-github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=YOUR_PROJECT_ID

# Grant required roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:staging-github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/viewer"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:staging-github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:staging-github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.developer"

# Create and download key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=staging-github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Set GitHub secrets
gh secret set GCP_SA_KEY < github-actions-key.json
gh secret set GCP_PROJECT_ID --body "YOUR_PROJECT_ID"
gh secret set OPENAI_API_KEY --body "sk-your-key"
gh secret set INFRACOST_API_KEY --body "your-infracost-key"

# Clean up local key file
rm github-actions-key.json
```

## � CI/CD Pipeline

The GitHub Actions pipeline automatically runs on Terraform file changes (`*.tf`, `*.tfvars`):

### Pipeline Jobs

1. **Validate** - Terraform fmt, validate, TFLint, Checkov security scan
2. **Plan** - Terraform plan with PR comments
3. **Infracost** - Cost estimation (PRs only, shows cost impact)
4. **Security** - Trivy vulnerability scanning with SARIF reports
5. **Build & Deploy** - Docker build, push to Artifact Registry, deploy to Cloud Run (main branch only)

### Workflow Triggers

- **Pull Requests** → All jobs run, Infracost shows cost comparison
- **Push to main** → All jobs + Docker build/deploy (if Terraform files changed)
- **Manual** → workflow_dispatch for manual runs

### GitHub Secrets Required

- `GCP_SA_KEY` - Service account key (JSON)
- `GCP_PROJECT_ID` - Your GCP project ID
- `OPENAI_API_KEY` - OpenAI API key (or mock for demo)
- `INFRACOST_API_KEY` - Infracost API key (optional, for cost estimates)

## 📊 Cost Estimation

Infracost automatically analyzes infrastructure cost changes on PRs:
- Runs when Terraform files are modified
- Shows monthly cost estimate in PR checks
- Posts detailed comparison comment on PR
- Helps catch unexpected cost increases before merge

Get your free Infracost API key at: https://www.infracost.io/

## �📁 Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml      # CI/CD pipeline (validate, security, cost, deploy)
├── modules/
│   └── gcp-baseline/             # Main Terraform module
│       ├── main.tf               # Core infrastructure resources
│       ├── variables.tf          # Input variables
│       ├── outputs.tf            # Output values
│       └── README.md             # Module documentation
├── examples/
│   └── sample-app/               # Sample Flask application
│       ├── Dockerfile            # Multi-stage Docker build
│       ├── app.py                # Flask app with DB connectivity test
│       └── requirements.txt      # Python dependencies
├── scripts/
│   ├── deploy.sh                 # Automated deployment
│   ├── validate.sh               # Validation checks (fmt, validate, tflint, checkov)
│   ├── verify.sh                 # Post-deployment verification
│   └── destroy.sh                # Safe cleanup with confirmation
├── main.tf                       # Root module configuration
├── variables.tf                  # Root variables
├── outputs.tf                    # Root outputs
├── terraform.tfvars.example      # Example configuration
├── .tflint.hcl                   # TFLint configuration with GCP rules
├── .checkov.yml                  # Checkov security scanning config
└── README.md                     # This file
```

## 🛡️ Security & Validation

### Automated Security Checks

1. **Checkov** - 200+ policy checks for Terraform
2. **Trivy** - Container and IaC vulnerability scanning
3. **TFLint** - Terraform linting with GCP best practices

### IAM & Least Privilege

**Cloud Run Service Account** has only:
- `roles/cloudsql.client` - Connect to Cloud SQL
- `roles/secretmanager.secretAccessor` - Access specific secrets (not project-wide)

**GitHub Actions Service Account** has only:
- `roles/viewer` - Read project resources
- `roles/artifactregistry.writer` - Push Docker images
- `roles/run.developer` - Deploy Cloud Run services

### Network Security

- Cloud SQL: **Private IP only** (no public access)
- VPC egress: **PRIVATE_RANGES_ONLY** (Cloud Run can't access internet directly)
- Secrets: All credentials stored in Secret Manager (not env vars)

## ✅ Validation Gates

This project implements automated validation checks in CI/CD:

1. **terraform fmt** - Code formatting consistency
2. **terraform validate** - Configuration validation
3. **tflint** - Static analysis with GCP rules
4. **checkov** - Security scanning (200+ checks)
5. **trivy** - Vulnerability scanning

Run all validations locally:
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

## 🐳 Docker Build & Deployment

### Automated Deployment (CI/CD)

On push to `main` branch (when Terraform files change):
1. Docker image built from [`examples/sample-app/`](examples/sample-app/)
2. Pushed to Artifact Registry: `us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/sample-app`
3. Deployed to Cloud Run service: `staging-app`

### Manual Docker Build

```bash
cd examples/sample-app

# Build image
docker build -t us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/sample-app:latest .

# Authenticate Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Push to Artifact Registry
docker push us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/sample-app:latest

# Deploy to Cloud Run
gcloud run deploy staging-app \
  --image=us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/sample-app:latest \
  --region=us-central1 \
  --project=PROJECT_ID
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

## 💰 Cost Optimization

### Estimated Monthly Costs (Staging)

- **Cloud Run**: Free tier covers 2M requests/month, then $0.00002400/request
- **Cloud SQL** (db-f1-micro): ~$7-10/month
- **VPC Connector** (e2-micro, 2 instances): ~$8/month
- **Secret Manager**: First 6 secrets free, $0.06/secret/month after
- **Artifact Registry**: First 0.5GB free, $0.10/GB/month after
- **Total Estimated**: ~$15-20/month for staging with minimal usage

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
docker build -t us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/my-app:v1.0.0 .

# Authenticate and push
gcloud auth configure-docker us-central1-docker.pkg.dev
docker push us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/my-app:v1.0.0

# Update Cloud Run image (auto-deployed via CI/CD on main branch)
# Or manually:
gcloud run deploy staging-app \
  --image=us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app/my-app:v1.0.0 \
  --region=us-central1
```

### Verify Infrastructure

After deployment, verify your infrastructure:

```bash
# Run verification script
./scripts/verify.sh

# Or manually check:
# 1. Cloud Run service
gcloud run services list --region=us-central1

# 2. Cloud SQL instance (private IP only)
gcloud sql instances describe staging-postgres-SUFFIX --format="get(ipAddresses)"

# 3. Artifact Registry
gcloud artifacts repositories list --location=us-central1

# 4. Docker images
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT_ID/oryontech-app

# 5. Test application endpoint
curl https://staging-app-HASH.run.app/health
curl https://staging-app-HASH.run.app/health/db
```

## 🔗 Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [VPC Access Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Infracost](https://www.infracost.io/docs/)

## 📝 Features Checklist

- ✅ Cloud Run with auto-scaling and health checks
- ✅ Private Cloud SQL (PostgreSQL) with VPC peering
- ✅ Serverless VPC Access Connector
- ✅ Secret Manager integration
- ✅ Least privilege IAM (separate service accounts)
- ✅ Artifact Registry for Docker images
- ✅ GitHub Actions CI/CD pipeline
- ✅ Terraform validation (fmt, validate, tflint)
- ✅ Security scanning (Checkov, Trivy)
- ✅ Cost estimation (Infracost)
- ✅ Automated Docker build/push/deploy
- ✅ Infrastructure as Code best practices
- ✅ Automated testing and verification
- ✅ Documentation and examples

---

**Built with** ❤️ **for OryonTech DevOps Technical Challenge**

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

**4. Docker push authentication fails**
```
Error: denied: Unauthenticated request
```
Solution: Regenerate service account key and update `GCP_SA_KEY` secret

**5. Infracost not showing costs**
```
No cost data available
```
Solution: Verify `INFRACOST_API_KEY` secret is set and valid

## 🗑️ How to Destroy

**Using the cleanup script (recommended):**
```bash
./scripts/destroy.sh
```

**Or manually:**
```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all resources including Cloud Run, Cloud SQL database and data, VPC networking, secrets, service accounts, and Artifact Registry.

---

**Built with** ❤️ **for OryonTech DevOps Technical Challenge**
