#!/usr/bin/env bash
# Deployment Script for OryonTech GCP Baseline Infrastructure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "════════════════════════════════════════════════════════"
echo "  OryonTech GCP Baseline Infrastructure Deployment"
echo "════════════════════════════════════════════════════════"
echo ""

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    local missing_deps=0
    
    # Check for terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}✗${NC} Terraform is not installed"
        missing_deps=1
    else
        echo -e "${GREEN}✓${NC} Terraform $(terraform version | head -n 1)"
    fi
    
    # Check for gcloud
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}✗${NC} gcloud CLI is not installed"
        missing_deps=1
    else
        echo -e "${GREEN}✓${NC} gcloud CLI $(gcloud version | head -n 1 | awk '{print $NF}')"
    fi
    
    if [ $missing_deps -ne 0 ]; then
        echo ""
        echo -e "${RED}Missing required dependencies. Please install them first.${NC}"
        exit 1
    fi
    
    echo ""
}

# Check GCP authentication
check_auth() {
    echo "Checking GCP authentication..."
    
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        echo -e "${GREEN}✓${NC} Authenticated as: $account"
    else
        echo -e "${RED}✗${NC} Not authenticated with GCP"
        echo "Run: gcloud auth application-default login"
        exit 1
    fi
    
    echo ""
}

# Check tfvars file
check_tfvars() {
    echo "Checking configuration..."
    
    if [ ! -f "$PROJECT_ROOT/terraform.tfvars" ]; then
        echo -e "${YELLOW}⚠${NC} terraform.tfvars not found"
        echo ""
        echo "Please create terraform.tfvars from the example:"
        echo "  cp terraform.tfvars.example terraform.tfvars"
        echo ""
        echo "Then edit terraform.tfvars with your values:"
        echo "  - project_id: Your GCP project ID"
        echo "  - openai_api_key: Your OpenAI API key (or use TF_VAR_openai_api_key env var)"
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} terraform.tfvars found"
    
    # Check if OPENAI_API_KEY is set
    if [ -z "${TF_VAR_openai_api_key:-}" ]; then
        echo -e "${YELLOW}⚠${NC} TF_VAR_openai_api_key environment variable not set"
        echo "  Make sure openai_api_key is set in terraform.tfvars or export TF_VAR_openai_api_key"
    fi
    
    echo ""
}

# Run validations
run_validations() {
    echo "Running validations..."
    
    cd "$PROJECT_ROOT"
    
    if [ -x "$SCRIPT_DIR/validate.sh" ]; then
        bash "$SCRIPT_DIR/validate.sh"
    else
        echo -e "${YELLOW}⚠${NC} Validation script not found or not executable"
    fi
    
    echo ""
}

# Terraform init
tf_init() {
    echo "Initializing Terraform..."
    cd "$PROJECT_ROOT"
    terraform init
    echo ""
}

# Terraform plan
tf_plan() {
    echo "Planning infrastructure changes..."
    cd "$PROJECT_ROOT"
    terraform plan -out=tfplan
    echo ""
}

# Terraform apply
tf_apply() {
    echo "Applying infrastructure changes..."
    cd "$PROJECT_ROOT"
    
    echo -e "${YELLOW}This will create real resources in GCP and may incur costs.${NC}"
    read -p "Do you want to continue? (yes/no): " -r
    echo
    
    if [[ $REPLY =~ ^[Yy]es$ ]]; then
        terraform apply tfplan
        rm -f tfplan
        echo ""
        echo -e "${GREEN}✓ Infrastructure deployed successfully!${NC}"
        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo "  Deployment Summary"
        echo "═══════════════════════════════════════════════════════"
        terraform output
    else
        echo "Deployment cancelled"
        rm -f tfplan
        exit 0
    fi
}

# Main execution
main() {
    check_prerequisites
    check_auth
    check_tfvars
    run_validations
    tf_init
    tf_plan
    tf_apply
}

# Run main function
main
