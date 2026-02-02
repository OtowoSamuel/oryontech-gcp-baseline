#!/usr/bin/env bash
# Terraform Validation Script
# Runs all validation checks for infrastructure code

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
VALIDATION_FAILED=0

echo "════════════════════════════════════════════════════════"
echo "  OryonTech Infrastructure Validation"
echo "════════════════════════════════════════════════════════"
echo ""

# Function to print colored status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
    fi
}

# Function to run validation step
run_validation() {
    local name=$1
    local command=$2
    
    echo ""
    echo "─────────────────────────────────────────────────────────"
    echo "Running: $name"
    echo "─────────────────────────────────────────────────────────"
    
    if eval "$command"; then
        print_status 0 "$name passed"
        return 0
    else
        print_status 1 "$name failed"
        VALIDATION_FAILED=1
        return 1
    fi
}

# 1. Terraform Format Check
run_validation "Terraform Format Check" "terraform fmt -check -recursive"

# 2. Terraform Init
run_validation "Terraform Init" "terraform init -backend=false"

# 3. Terraform Validate
run_validation "Terraform Validate" "terraform validate"

# 4. TFLint
if command -v tflint &> /dev/null; then
    run_validation "TFLint" "tflint --init && tflint --recursive"
else
    echo -e "${YELLOW}⚠${NC} TFLint not installed, skipping..."
fi

# 5. Checkov Security Scan
if command -v checkov &> /dev/null; then
    run_validation "Checkov Security Scan" "checkov -d . --config-file .checkov.yml --quiet --compact"
else
    echo -e "${YELLOW}⚠${NC} Checkov not installed, skipping..."
fi

# 6. Terraform Plan (dry-run check)
if [ -f "terraform.tfvars" ]; then
    echo ""
    echo "─────────────────────────────────────────────────────────"
    echo "Running: Terraform Plan"
    echo "─────────────────────────────────────────────────────────"
    echo -e "${YELLOW}Note:${NC} Terraform plan requires valid credentials and tfvars"
    echo "Skipping plan in validation script. Run manually with: terraform plan"
else
    echo ""
    echo "─────────────────────────────────────────────────────────"
    echo -e "${YELLOW}⚠${NC} terraform.tfvars not found, skipping plan"
    echo "─────────────────────────────────────────────────────────"
fi

# Final Summary
echo ""
echo "════════════════════════════════════════════════════════"
if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo "════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    echo "════════════════════════════════════════════════════════"
    exit 1
fi
