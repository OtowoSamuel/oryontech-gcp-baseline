# Walkthrough Video Script (3-5 minutes)

## OryonTech GCP Baseline Infrastructure Walkthrough

**Duration:** 3-5 minutes
**Presenter:** Samuel Otowo

---

## Introduction (30 seconds)

**[Screen: Terminal with project structure]**

"Hi, I'm Samuel Otowo, and this is my submission for the OryonTech DevOps Technical Challenge.

I've built a production-grade Terraform module that provisions a secure baseline infrastructure for OryonTech's Agent-as-a-Service platform on Google Cloud Platform.

Let me walk you through the solution."

---

## Architecture Overview (45 seconds)

**[Screen: README.md showing architecture diagram]**

"The architecture follows security best practices:

1. **Cloud Run** for serverless container deployment
2. **Cloud SQL PostgreSQL** with NO public IP - only private networking
3. **VPC and Serverless VPC Access Connector** for secure connectivity
4. **Secret Manager** for all credentials - nothing is hardcoded
5. **Least privilege IAM** - service account with only required permissions

The key security feature: Cloud Run connects to Cloud SQL through a private VPC connector, meaning the database is completely isolated from the internet."

---

## Code Structure (30 seconds)

**[Screen: Tree view of repository]**

"The repository is organized for reusability:

- A reusable **Terraform module** in `modules/gcp-baseline`
- **Validation scripts** for format, lint, and security scanning
- **GitHub Actions CI/CD** pipeline
- A **sample application** with database connectivity
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

## CI/CD Pipeline (20 seconds)

**[Screen: GitHub Actions workflow file]**

"The GitHub Actions pipeline includes:
- All validation checks on every push
- Terraform plan on pull requests
- Security scanning with Trivy
- Optional cost estimation with Infracost

This ensures code quality and security before any deployment."

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

✅ Secure infrastructure with private Cloud SQL
✅ Secret Manager integration
✅ Least privilege IAM
✅ Four validation gates
✅ Complete documentation
✅ Reusable module structure
✅ CI/CD ready

Everything is production-grade and follows Google Cloud best practices.

The repository includes comprehensive documentation for deployment, verification, and troubleshooting.

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
# - Cloud Run service
# - Cloud SQL (private IP only)
# - Secret Manager

# Terminal: Test endpoints
curl $CLOUD_RUN_URL/health
curl $CLOUD_RUN_URL/health/db

# Terminal: Show logs
gcloud run logs read --service=staging-app --limit=10
```

---

## Q&A Preparation

Anticipate these questions:

**Q: Why VPC Connector instead of Direct VPC Egress?**
A: VPC Connector is more flexible and works with all Cloud Run features. Direct VPC Egress is newer but has some limitations.

**Q: Why not use Cloud SQL Proxy?**
A: Cloud Run has built-in Cloud SQL proxy support via the connection annotation. For external connections, we recommend using the Cloud SQL connector libraries (shown in sample app).

**Q: Cost implications?**
A: Free tier covers most staging usage. Estimated $15-20/month for staging environment.

**Q: How to scale to multiple environments?**
A: Use Terraform workspaces or separate tfvars files per environment.

**Q: Production recommendations?**
A: Enable deletion protection, use REGIONAL availability, increase instance sizes, configure remote state backend, implement proper monitoring.
