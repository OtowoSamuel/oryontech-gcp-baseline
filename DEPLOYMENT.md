# Deployment Guide

## Complete Deployment Walkthrough

This guide walks you through deploying the OryonTech GCP baseline infrastructure from scratch.

## Prerequisites Checklist

- [ ] GCP Account with billing enabled
- [ ] GCP Project created
- [ ] gcloud CLI installed and configured
- [ ] Terraform >= 1.5.0 installed
- [ ] Git installed
- [ ] Basic understanding of GCP services

## Step-by-Step Deployment

### 1. GCP Project Setup

```bash
# Create a new project (optional)
gcloud projects create oryontech-staging --name="OryonTech Staging"

# Set the project
gcloud config set project oryontech-staging

# Enable billing (replace BILLING_ACCOUNT_ID)
gcloud billing projects link oryontech-staging --billing-account=BILLING_ACCOUNT_ID

# Verify project
gcloud config list project
```

### 2. Authentication

```bash
# Authenticate with your Google account
gcloud auth login

# Set application default credentials for Terraform
gcloud auth application-default login

# Verify authentication
gcloud auth list
```

### 3. Clone Repository

```bash
# Clone the repository
git clone <repository-url>
cd oryontech-gcp-baseline

# Verify structure
ls -la
```

### 4. Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

**Minimum required configuration:**

```hcl
# Required
project_id = "oryontech-staging"    # Your GCP project ID
environment = "staging"

# OpenAI API Key - Option 1: Set in tfvars (less secure)
# openai_api_key = "sk-your-key-here"

# OpenAI API Key - Option 2: Use environment variable (recommended)
# export TF_VAR_openai_api_key="sk-your-key-here"

# Optional: Customize defaults
region = "us-central1"
database_tier = "db-f1-micro"
allow_public_access = true  # Set to false for private Cloud Run
```

### 5. Set Secrets (Recommended Method)

```bash
# Set OpenAI API key as environment variable (more secure)
export TF_VAR_openai_api_key="sk-your-openai-api-key"

# Verify it's set
echo $TF_VAR_openai_api_key | cut -c1-10  # Should show "sk-your-op"
```

### 6. Run Validations

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run validation checks
./scripts/validate.sh
```

Expected output:
```
════════════════════════════════════════════════════════
  OryonTech Infrastructure Validation
════════════════════════════════════════════════════════

✓ Terraform Format Check passed
✓ Terraform Init passed
✓ Terraform Validate passed
✓ TFLint passed
✓ Checkov Security Scan passed

✓ All validations passed!
```

### 7. Deploy Infrastructure

#### Option A: Automated (Recommended)

```bash
./scripts/deploy.sh
```

This script will:
1. Check prerequisites
2. Verify authentication
3. Run validations
4. Initialize Terraform
5. Show plan
6. Prompt for confirmation
7. Apply changes
8. Display outputs

#### Option B: Manual

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan -out=tfplan

# Review the plan carefully
# Look for:
# - Resources to be created
# - No unexpected deletions
# - Correct configurations

# Apply changes
terraform apply tfplan
```

### 8. Verify Deployment

```bash
# Run verification script
./scripts/verify.sh
```

Or manually:

```bash
# View outputs
terraform output

# Check Cloud Run service
gcloud run services list --project=oryontech-staging

# Check Cloud SQL instance
gcloud sql instances list --project=oryontech-staging

# Test Cloud Run endpoint
curl $(terraform output -raw cloud_run_url)
```

### 9. Test Database Connectivity

```bash
# Get Cloud Run URL
CLOUD_RUN_URL=$(terraform output -raw cloud_run_url)

# Test health endpoint
curl $CLOUD_RUN_URL/health

# Test database connectivity (if using sample app)
curl $CLOUD_RUN_URL/health/db
```

### 10. View Logs

```bash
# Cloud Run logs
gcloud run logs read \
  --service=$(terraform output -raw cloud_run_service_name) \
  --project=$(terraform output -raw project_id) \
  --limit=50

# Follow logs in real-time
gcloud run logs tail \
  --service=$(terraform output -raw cloud_run_service_name) \
  --project=$(terraform output -raw project_id)
```

## Deployment Timeline

Expected deployment time: **10-15 minutes**

| Step | Resource | Approx Time |
|------|----------|-------------|
| 1 | API Enablement | 2-3 min |
| 2 | VPC Network | 1 min |
| 3 | Cloud SQL | 5-7 min |
| 4 | VPC Connector | 2-3 min |
| 5 | Secrets & IAM | 1 min |
| 6 | Cloud Run | 1-2 min |

## Post-Deployment Tasks

### 1. Save Outputs

```bash
# Save outputs to file
terraform output > deployment-outputs.txt

# Save specific values
echo "Cloud Run URL: $(terraform output -raw cloud_run_url)" >> deployment-info.txt
echo "Database: $(terraform output -raw database_connection_name)" >> deployment-info.txt
```

### 2. Configure Monitoring (Optional)

```bash
# Create uptime check
gcloud monitoring uptime create \
  --display-name="Cloud Run Health Check" \
  --resource-type=uptime-url \
  --monitored-resource="$(terraform output -raw cloud_run_url)/health"
```

### 3. Set Up Alerts (Optional)

```bash
# Create alert policy for Cloud Run errors
# (Configure via Cloud Console or gcloud)
```

### 4. Configure Remote State (Production)

For production deployments, configure remote state:

```hcl
# Add to main.tf
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/state/staging"
  }
}
```

Then migrate state:

```bash
# Create state bucket
gsutil mb gs://your-terraform-state-bucket

# Enable versioning
gsutil versioning set on gs://your-terraform-state-bucket

# Migrate state
terraform init -migrate-state
```

## Deploying Custom Application

### 1. Build Container

```bash
cd examples/sample-app

# Build image
docker build -t gcr.io/oryontech-staging/app:v1.0.0 .

# Configure Docker for GCR
gcloud auth configure-docker

# Push image
docker push gcr.io/oryontech-staging/app:v1.0.0
```

### 2. Update Configuration

```bash
# Edit terraform.tfvars
nano terraform.tfvars
```

```hcl
cloud_run_image = "gcr.io/oryontech-staging/app:v1.0.0"
```

### 3. Update Infrastructure

```bash
# Plan changes
terraform plan

# Apply update
terraform apply
```

## Troubleshooting Deployment

### Issue: API Not Enabled

```
Error: Error 403: ... API has not been used in project
```

**Solution:**
```bash
# Manually enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vpcaccess.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

### Issue: Quota Exceeded

```
Error: Quota 'VPC_ACCESS_CONNECTORS' exceeded
```

**Solution:**
- Request quota increase in GCP Console
- Or use a different region with available quota

### Issue: Permission Denied

```
Error: googleapi: Error 403: Permission denied
```

**Solution:**
```bash
# Ensure you have required roles
gcloud projects add-iam-policy-binding oryontech-staging \
  --member="user:your-email@example.com" \
  --role="roles/owner"
```

### Issue: Cloud SQL Connection Timeout

```
Error: dial tcp: i/o timeout
```

**Solution:**
- Verify VPC connector is created
- Check Cloud SQL instance has private IP
- Ensure no firewall rules blocking traffic

### Issue: State Lock

```
Error: Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

## Cleanup/Destroy

When you're done testing:

```bash
# Safe cleanup with confirmation
./scripts/destroy.sh

# Or manual
terraform destroy
```

**⚠️ Warning:** This permanently deletes all resources and data!

## Next Steps

1. ✅ Deploy infrastructure
2. ✅ Verify connectivity
3. 📝 Deploy your application
4. 📊 Set up monitoring
5. 🔐 Review security settings
6. 📚 Document custom configurations
7. 🚀 Promote to production

## Production Deployment Checklist

Before deploying to production:

- [ ] Configure remote state backend
- [ ] Enable deletion protection (`deletion_protection = true`)
- [ ] Set up high availability (`database_availability_type = "REGIONAL"`)
- [ ] Configure automated backups with longer retention
- [ ] Set up monitoring and alerting
- [ ] Review and harden IAM permissions
- [ ] Enable audit logging
- [ ] Configure VPC Service Controls (optional)
- [ ] Set up disaster recovery procedures
- [ ] Document runbooks
- [ ] Configure CI/CD pipeline
- [ ] Perform security review
- [ ] Load testing
- [ ] Create rollback plan

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review logs: `gcloud run logs read`
3. Check [GCP documentation](https://cloud.google.com/docs)
4. Open an issue in the repository

---

**Remember:** Always test in a staging environment before deploying to production!
