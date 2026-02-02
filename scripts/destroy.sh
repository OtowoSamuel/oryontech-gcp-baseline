#!/usr/bin/env bash
# Cleanup Script - Safely destroy infrastructure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "════════════════════════════════════════════════════════"
echo "  Infrastructure Cleanup"
echo "════════════════════════════════════════════════════════"
echo ""

echo -e "${RED}WARNING: This will destroy ALL infrastructure resources!${NC}"
echo ""
echo "This includes:"
echo "  - Cloud Run service"
echo "  - Cloud SQL database (and all data)"
echo "  - VPC and networking components"
echo "  - Secret Manager secrets"
echo "  - Service accounts"
echo ""

read -p "Are you absolutely sure? Type 'destroy' to confirm: " -r
echo

if [ "$REPLY" != "destroy" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Running terraform destroy..."
echo ""

terraform destroy

echo ""
echo -e "${GREEN}✓ Infrastructure destroyed successfully${NC}"
echo ""
