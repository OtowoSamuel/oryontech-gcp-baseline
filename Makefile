.PHONY: help init validate fmt plan apply deploy verify destroy clean

# Default target
.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)OryonTech GCP Baseline Infrastructure$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	terraform init

fmt: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	terraform fmt -recursive

validate: ## Run all validation checks
	@echo "$(BLUE)Running validation checks...$(NC)"
	@./scripts/validate.sh

plan: init ## Run terraform plan
	@echo "$(BLUE)Planning infrastructure changes...$(NC)"
	terraform plan -out=tfplan

apply: ## Apply terraform changes (requires plan)
	@echo "$(BLUE)Applying infrastructure changes...$(NC)"
	@if [ ! -f tfplan ]; then \
		echo "$(YELLOW)No plan file found. Run 'make plan' first.$(NC)"; \
		exit 1; \
	fi
	terraform apply tfplan
	@rm -f tfplan

deploy: ## Full deployment (validate + plan + apply)
	@./scripts/deploy.sh

verify: ## Verify deployed infrastructure
	@./scripts/verify.sh

destroy: ## Destroy all infrastructure
	@./scripts/destroy.sh

clean: ## Clean temporary files
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@rm -f tfplan
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@echo "$(GREEN)Clean complete$(NC)"

lint: ## Run TFLint
	@echo "$(BLUE)Running TFLint...$(NC)"
	@tflint --init
	@tflint --recursive

security: ## Run security scan with Checkov
	@echo "$(BLUE)Running security scan...$(NC)"
	@checkov -d . --config-file .checkov.yml

test: validate lint security ## Run all tests
	@echo "$(GREEN)All tests passed!$(NC)"

output: ## Show terraform outputs
	@terraform output

state: ## List terraform state
	@terraform state list

docs: ## Generate documentation
	@echo "$(BLUE)Documentation available in README.md$(NC)"
	@echo "Module docs: modules/gcp-baseline/README.md"
	@echo "Sample app: examples/sample-app/README.md"

install-tools: ## Install required tools
	@echo "$(BLUE)Installing required tools...$(NC)"
	@echo "Please install manually:"
	@echo "  - Terraform: https://www.terraform.io/downloads"
	@echo "  - gcloud CLI: https://cloud.google.com/sdk/docs/install"
	@echo "  - TFLint: https://github.com/terraform-linters/tflint"
	@echo "  - Checkov: pip install checkov"
