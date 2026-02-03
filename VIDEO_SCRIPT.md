# Walkthrough Video Script (3-5 minutes)

## OryonTech GCP Baseline Infrastructure Walkthrough

**Duration:** 3-5 minutes
**Presenter:** Samuel Otowo

---

## Introduction (30 seconds)

**[Screen: Terminal with project structure]**

"Hi, I'm Samuel Otowo, and this is my submission for the OryonTech DevOps Technical Challenge.

I've built a production-ready infrastructure solution with:
- Secure GCP baseline infrastructure using Terraform
- Complete CI/CD pipeline with GitHub Actions
- Automated Docker build and deployment
- Security scanning and cost estimation
- Everything production-grade and fully automated.

Let me walk you through the solution."

---

## Architecture Overview (45 seconds)

**[Screen: README.md showing architecture diagram]**

"The architecture follows security and DevOps best practices:

1. **Cloud Run** for serverless container deployment
2. **Cloud SQL PostgreSQL** with NO public IP - only private networking
3. **Artifact Registry** for Docker image storage
4. **VPC and Serverless VPC Access Connector** for secure connectivity
5. **Secret Manager** for all credentials - nothing is hardcoded
6. **Least privilege IAM** - separate service accounts for runtime and CI/CD
7. **GitHub Actions CI/CD** - fully automated pipeline

The key security feature: Cloud Run connects to Cloud SQL through a private VPC connector, meaning the database is completely isolated from the internet.

The CI/CD pipeline automatically builds, scans, and deploys Docker images when changes are pushed to main."

---

## Code Structure (30 seconds)

**[Screen: Tree view of repository]**

"The repository is organized for production use:

- A reusable **Terraform module** in `modules/gcp-baseline`
- **Validation scripts** for format, lint, and security scanning
- **GitHub Actions CI/CD** pipeline with 5 automated jobs
- A **containerized sample application** with Dockerfile
- **Artifact Registry** for Docker image storage
- **Infracost integration** for cost estimation on PRs
- Comprehensive documentation"

---

## Validation Gates (45 seconds)

**[Screen: Terminal running ./scripts/validate.sh]**

"I've implemented four validation gates as required:

1. `terraform fmt` - format checking
2. `terraform validate` - syntax validation
3. `tflint` - static analysis with Google Cloud rules
4. `checkov` - security scanning for 200+ checks

Let me run all validations..."

**[Show output: All checks passing with green checkmarks]**

"All validations pass. The code is formatted, syntactically correct, follows best practices, and has no security issues."

---

## Deployment Demo (45 seconds)

**[Screen: Terminal running ./scripts/deploy.sh]**

"Deployment is automated with a single command:

```bash
./scripts/deploy.sh
```

The script:
- Checks prerequisites
- Validates the code
- Runs terraform plan to show changes
- Prompts for confirmation
- Deploys infrastructure
- Shows outputs"

**[Show: terraform outputs]**

"Here are the outputs: Cloud Run URL, database connection name, VPC connector, and service account."

---

## Verification (30 seconds)

**[Screen: Running verification script]**

"Let me verify everything is working:

```bash
./scripts/verify.sh
```

This checks:
- Cloud Run is accessible
- Cloud SQL is running with private IP only
- VPC Connector is ready
- Secrets are configured
- IAM permissions are correct"

**[Show: All checks passing]**

---

## Security Features (30 seconds)

**[Screen: GCP Console - Cloud SQL instance]**

"Security highlights:

1. **No Public IP** - See the Cloud SQL instance has only a private IP
2. **Secrets in Secret Manager** - All credentials are stored securely
3. **Least Privilege** - Service account has only two roles: Cloud SQL Client and Secret Accessor
4. **SSL Required** - Database requires encrypted connections
5. **Audit Logging** - All connections are logged"

**[Show: Secret Manager with secrets listed]**
**[Show: IAM page with service account permissions]**

---

## Docker Deployment Pipeline (30 seconds)

**[Screen: GitHub Actions - build-docker job]**

"Let me show you the Docker deployment in action:

**[Show: Docker build logs]**

1. Container image built from the sample Flask app
2. Pushed to Artifact Registry with commit SHA and 'latest' tags
3. Deployed to Cloud Run automatically

**[Screen: GCP Console - Artifact Registry]**

Here in Artifact Registry, you can see our Docker images with multiple versions.

**[Screen: Cloud Run service with latest revision]**

And Cloud Run automatically deployed the latest image.

## Testing Database Connectivity (20 seconds)

**[Screen: Terminal with curl commands]**

"Testing the endpoints:

```bash
# Health check
curl https://[cloud-run-url]/health

# Database connectivity
curl https://[cloud-run-url]/health/db
```

**[Show: JSON response showing database connected]**

"Perfect! Cloud Run successfully connects to Cloud SQL through private networking."

---

## CI/CD Pipeline (60 seconds)

**[Screen: GitHub Actions workflow running]**

"The CI/CD pipeline is fully automated with GitHub Actions:

**On Pull Requests:**
1. **Validate** - Terraform fmt, validate, TFLint, Checkov (200+ security checks)
2. **Plan** - Shows infrastructure changes in PR comments
3. **Infracost** - Estimates cost impact and posts comparison
4. **Security** - Trivy scans for vulnerabilities

**[Show: PR #1 with Infracost comment showing cost increase]**

See here - Infracost automatically calculated the cost impact of increasing Cloud SQL disk size.

**On Merge to Main:**
5. **Build Docker** - Builds container image from sample app
6. **Push to Artifact Registry** - Stores versioned images
7. **Deploy to Cloud Run** - Automatically updates the service

**[Screen: GitHub Actions successful run]**

All checks pass, and deployment happens automatically. No manual intervention needed."

---

## Cleanup (10 seconds)

**[Screen: Terminal]**

"When done, cleanup is safe and easy:

```bash
./scripts/destroy.sh
```

It prompts for confirmation before destroying resources."

---

## Closing (20 seconds)

**[Screen: README.md]**

"Summary of what I've delivered:

**Infrastructure:**
✅ Secure Cloud Run + Private Cloud SQL architecture
✅ Artifact Registry for Docker images
✅ Secret Manager integration
✅ Least privilege IAM (separate service accounts)
✅ VPC with private networking

**CI/CD & Automation:**
✅ GitHub Actions pipeline (5 automated jobs)
✅ Terraform validation (fmt, validate, TFLint, Checkov)
✅ Security scanning (Trivy for containers)
✅ Cost estimation (Infracost on PRs)
✅ Automated Docker build/push/deploy

**Code Quality:**
✅ Reusable Terraform module structure
✅ Comprehensive documentation
✅ Sample containerized application
✅ Automated verification scripts

Everything is production-ready, fully automated, and follows GCP and DevOps best practices.

Thank you for reviewing my submission!"

---

## Recording Tips

### Screen Recording Tools
- **macOS:** QuickTime, OBS Studio
- **Linux:** OBS Studio, SimpleScreenRecorder
- **Windows:** OBS Studio, Windows Game Bar

### Terminal Setup
```bash
# Use a clean terminal with good font size
# Set PS1 for clean prompt
export PS1='\[\033[01;32m\]\u@oryontech\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Clear history
clear
```

### Recording Checklist
- [ ] Close unnecessary applications
- [ ] Hide sensitive information
- [ ] Use a clean terminal with large font (16pt+)
- [ ] Test audio before recording
- [ ] Speak clearly and at moderate pace
- [ ] Show mouse cursor for navigation
- [ ] Pause briefly between sections
- [ ] Keep under 5 minutes

### Editing
- Trim dead space
- Add transitions between sections
- Consider adding text overlays for key points
- Add intro/outro slides
- Export in 1080p

### Upload Options
- YouTube (unlisted)
- Google Drive (shareable link)
- Loom
- Vimeo

---

## Alternative: Live Demo Script

If doing a live demo instead of recording:

1. **Have everything pre-deployed** in one terminal
2. **Use a second terminal** for fresh deployment
3. **Have browser tabs ready** with GCP Console views
4. **Practice timing** - aim for 3-4 minutes, leaving 1 minute buffer

### Quick Demo Flow

```bash
# Terminal 1: Show structure
tree -L 2

# Terminal 2: Run validation
./scripts/validate.sh

# Terminal 3: Show already deployed infrastructure
terraform output

# Browser: Show GCP Console
# - Cloud Run service (latest revision)
# - Cloud SQL (private IP only)
# - Secret Manager
# - Artifact Registry (Docker images)

# Browser: Show GitHub
# - Actions tab (successful workflows)
# - Pull Request #1 (with Infracost comment)
# - Checks passed (validate, security, plan, cost)

# Terminal: Test endpoints
curl $CLOUD_RUN_URL/health
curl $CLOUD_RUN_URL/health/db

# Terminal: Show deployment logs
gcloud run services describe staging-app --region=us-central1 --format="value(status.latestCreatedRevisionName)"
```

---

## Q&A Preparation

Anticipate these questions:

**Q: Why VPC Connector instead of Direct VPC Egress?**
A: VPC Connector is more flexible and works with all Cloud Run features. Direct VPC Egress is newer but has some limitations.

**Q: Why not use Cloud SQL Proxy?**
A: Cloud Run has built-in Cloud SQL proxy support. For external connections, we use the Cloud SQL Python connector library (shown in sample app).

**Q: How does the CI/CD pipeline work?**
A: GitHub Actions runs 5 jobs: validation, security scanning, Terraform plan, cost estimation (PRs only), and Docker build/deploy (main branch only). Everything is automated on push.

**Q: How do you handle secrets in CI/CD?**
A: GitHub Secrets store the service account key, project ID, and API keys. The pipeline uses these to authenticate to GCP and deploy resources.

**Q: Cost implications?**
A: Estimated $15-20/month for staging with minimal usage. Infracost automatically estimates cost changes on every PR before merge.

**Q: How to scale to multiple environments?**
A: Use Terraform workspaces or separate tfvars files per environment. The module is reusable across staging, production, etc.

**Q: What about container image security?**
A: We scan with Trivy before deployment. Images are stored in Artifact Registry with versioning (commit SHA + latest tag).

**Q: Production recommendations?**
A: Enable deletion protection, use REGIONAL availability, increase instance sizes, configure remote state backend (GCS), set up monitoring/alerting, implement proper backup strategy.
