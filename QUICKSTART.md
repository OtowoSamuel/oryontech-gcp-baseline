# 🚀 Quick Start Guide

Get started with OryonTech GCP baseline infrastructure in 5 minutes!

## Prerequisites

```bash
# Verify you have required tools
terraform --version  # >= 1.5.0
gcloud --version     # Latest
```

## 5-Minute Setup

### 1. Authenticate

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Clone & Configure

```bash
# Clone repository
git clone <repo-url>
cd oryontech-gcp-baseline

# Copy configuration
cp terraform.tfvars.example terraform.tfvars

# Set your project ID
sed -i 's/your-gcp-project-id/YOUR_PROJECT_ID/g' terraform.tfvars

# Set OpenAI key (use environment variable for security)
export TF_VAR_openai_api_key="sk-your-key"
```

### 3. Deploy

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy everything
./scripts/deploy.sh
```

That's it! The script will:
- ✓ Check prerequisites
- ✓ Run validations  
- ✓ Deploy infrastructure
- ✓ Show outputs

### 4. Verify

```bash
# Run verification
./scripts/verify.sh

# Or test manually
curl $(terraform output -raw cloud_run_url)
```

## What Gets Created?

- **Cloud Run** service at https://staging-app-xxx.run.app
- **Cloud SQL** PostgreSQL (private IP only)
- **VPC** network with connector
- **Secrets** in Secret Manager
- **Service Account** with least privilege

## View Resources

```bash
# See all outputs
terraform output

# View in Cloud Console
gcloud run services list
gcloud sql instances list
```

## Cleanup

```bash
./scripts/destroy.sh
```

## Next Steps

- 📖 Read full [README.md](README.md)
- 📝 Check [DEPLOYMENT.md](DEPLOYMENT.md) for details
- 🔧 Customize [terraform.tfvars](terraform.tfvars.example)
- 🚢 Deploy your app with [examples/sample-app](examples/sample-app/)

## Common Commands

```bash
# Validate code
make validate

# Format code
make fmt

# Show outputs
make output

# Full deployment
make deploy

# Cleanup
make destroy
```

## Get Help

```bash
# Show all make targets
make help

# View deployment guide
cat DEPLOYMENT.md

# Check troubleshooting
grep -A 5 "Troubleshooting" README.md
```

## Troubleshooting Quick Fixes

**APIs not enabled?**
```bash
gcloud services enable compute.googleapis.com sqladmin.googleapis.com run.googleapis.com
```

**Permission denied?**
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/owner"
```

**Need to re-deploy?**
```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

---

**⏱️ Total Time:** 5 minutes
**💰 Cost:** ~$15-20/month for staging
**🔐 Security:** Production-grade with private networking

**Ready to deploy? Run:** `./scripts/deploy.sh`
