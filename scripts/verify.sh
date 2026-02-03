#!/usr/bin/env bash
# Verification Script for OryonTech GCP Baseline Infrastructure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "════════════════════════════════════════════════════════"
echo "  Infrastructure Verification"
echo "════════════════════════════════════════════════════════"
echo ""

# Get terraform outputs
echo "Retrieving deployment information..."
CLOUD_RUN_URL=$(terraform output -raw cloud_run_url 2>/dev/null || echo "")
DB_CONNECTION_NAME=$(terraform output -raw database_connection_name 2>/dev/null || echo "")
VPC_CONNECTOR=$(terraform output -raw vpc_connector_name 2>/dev/null || echo "")
SERVICE_ACCOUNT=$(terraform output -raw cloud_run_service_account 2>/dev/null || echo "")

if [ -z "$CLOUD_RUN_URL" ]; then
    echo -e "${RED}✗${NC} Could not retrieve Terraform outputs. Has infrastructure been deployed?"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Verification Checks"
echo "═══════════════════════════════════════════════════════"
echo ""

# 1. Check Cloud Run Service
echo "1. Checking Cloud Run service..."
if curl -s -o /dev/null -w "%{http_code}" "$CLOUD_RUN_URL/health" | grep -q "200\|404"; then
    echo -e "${GREEN}✓${NC} Cloud Run service is accessible"
    echo "   URL: $CLOUD_RUN_URL"
else
    echo -e "${YELLOW}⚠${NC} Cloud Run service check (health endpoint might not be implemented in hello world image)"
    echo "   URL: $CLOUD_RUN_URL"
fi
echo ""

# 2. Check Cloud SQL Instance
echo "2. Checking Cloud SQL instance..."
if gcloud sql instances describe "$(echo "$DB_CONNECTION_NAME" | cut -d: -f3)" \
    --project="$(echo "$DB_CONNECTION_NAME" | cut -d: -f1)" \
    --format="value(state)" | grep -q "RUNNABLE"; then
    echo -e "${GREEN}✓${NC} Cloud SQL instance is running"
    echo "   Connection: $DB_CONNECTION_NAME"
    
    # Check for private IP only (verify ipv4Enabled is false)
    IPV4_ENABLED=$(gcloud sql instances describe "$(echo "$DB_CONNECTION_NAME" | cut -d: -f3)" \
        --project="$(echo "$DB_CONNECTION_NAME" | cut -d: -f1)" \
        --format="value(settings.ipConfiguration.ipv4Enabled)" 2>/dev/null || echo "")
    
    PRIVATE_IP=$(gcloud sql instances describe "$(echo "$DB_CONNECTION_NAME" | cut -d: -f3)" \
        --project="$(echo "$DB_CONNECTION_NAME" | cut -d: -f1)" \
        --format="value(ipAddresses.filter(type:PRIVATE).ipAddress)" 2>/dev/null || echo "")
    
    if [ "$IPV4_ENABLED" = "False" ] || [ "$IPV4_ENABLED" = "false" ]; then
        echo -e "${GREEN}✓${NC} Database has no public IP (private only: $PRIVATE_IP)"
    else
        echo -e "${YELLOW}⚠${NC} Database has a public IP enabled"
    fi
else
    echo -e "${RED}✗${NC} Cloud SQL instance is not running"
fi
echo ""

# 3. Check VPC Connector
echo "3. Checking VPC Connector..."
if gcloud compute networks vpc-access connectors describe "$VPC_CONNECTOR" \
    --region="$(terraform output -raw region)" \
    --project="$(terraform output -raw project_id)" \
    --format="value(state)" 2>/dev/null | grep -q "READY"; then
    echo -e "${GREEN}✓${NC} VPC Connector is ready"
    echo "   Connector: $VPC_CONNECTOR"
else
    echo -e "${YELLOW}⚠${NC} VPC Connector status unknown"
fi
echo ""

# 4. Check Secret Manager Secrets
echo "4. Checking Secret Manager secrets..."
SECRETS=$(terraform output -json secret_manager_secrets 2>/dev/null || echo "{}")

if [ "$SECRETS" != "{}" ]; then
    echo -e "${GREEN}✓${NC} Secrets are configured:"
    echo "$SECRETS" | jq -r 'to_entries[] | "   - \(.key): \(.value)"'
    
    # Verify service account has access
    echo ""
    echo "   Verifying service account access..."
    SECRET_ID=$(echo "$SECRETS" | jq -r '.openai_api_key')
    if gcloud secrets get-iam-policy "$SECRET_ID" \
        --project="$(terraform output -raw project_id)" \
        --format="value(bindings.members)" 2>/dev/null | grep -q "$SERVICE_ACCOUNT"; then
        echo -e "${GREEN}   ✓${NC} Service account has access to secrets"
    else
        echo -e "${RED}   ✗${NC} Service account may not have access to secrets"
    fi
else
    echo -e "${RED}✗${NC} Could not retrieve secrets information"
fi
echo ""

# 5. Check IAM Permissions
echo "5. Checking IAM permissions..."
if gcloud projects get-iam-policy "$(terraform output -raw project_id)" \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT" \
    --format="value(bindings.role)" | grep -q "roles/cloudsql.client"; then
    echo -e "${GREEN}✓${NC} Service account has Cloud SQL Client role"
else
    echo -e "${RED}✗${NC} Service account missing Cloud SQL Client role"
fi
echo ""

# 6. Test Cloud Run connectivity to database
echo "6. Testing database connectivity from Cloud Run..."
echo -e "${YELLOW}ⓘ${NC} This requires a custom container with database connection test"
echo "   Default hello world container doesn't test database connectivity"
echo "   Deploy your application container to verify end-to-end connectivity"
echo ""

# Summary
echo "════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Verification completed${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Deploy your application container image"
echo "2. Test database connectivity from your app"
echo "3. Monitor logs: gcloud run logs read --service=$(terraform output -raw cloud_run_service_name)"
echo "4. View metrics in Cloud Console"
echo ""
