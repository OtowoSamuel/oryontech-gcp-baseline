# Contributing to OryonTech GCP Baseline

Thank you for your interest in contributing to this project!

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/oryontech-gcp-baseline.git
   cd oryontech-gcp-baseline
   ```

2. **Install prerequisites**
   - Terraform >= 1.5.0
   - gcloud CLI
   - TFLint
   - Checkov
   - Pre-commit hooks (optional)

3. **Configure GCP credentials**
   ```bash
   gcloud auth application-default login
   ```

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow Terraform style guide
   - Add comments for complex logic
   - Update documentation

3. **Run validations**
   ```bash
   make validate
   make test
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: description of your changes"
   ```

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Code Standards

### Terraform Style

- Use `terraform fmt` for consistent formatting
- Follow HashiCorp naming conventions
- Add descriptions to all variables and outputs
- Use validation blocks for input variables
- Keep resources logically organized

### Documentation

- Update README.md for user-facing changes
- Update module README for internal changes
- Include examples for new features
- Document breaking changes clearly

### Security

- Never commit credentials
- Use Secret Manager for sensitive data
- Follow least privilege principle
- Add security scanning for new resources

## Testing

All changes must pass:
- `terraform fmt -check`
- `terraform validate`
- `tflint --recursive`
- `checkov -d .`

## Pull Request Process

1. Update documentation
2. Add/update tests if applicable
3. Ensure all CI checks pass
4. Request review from maintainers
5. Address review feedback
6. Squash commits if requested

## Questions?

Open an issue for discussion before starting major changes.
