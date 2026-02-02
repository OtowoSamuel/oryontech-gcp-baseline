# Sample Application

This is a sample Flask application that demonstrates:
- Cloud Run deployment
- Private Cloud SQL connectivity via VPC connector
- Secret Manager integration
- Health check endpoints
- Database connectivity testing

## Endpoints

- `GET /` - Service information
- `GET /health` - Basic health check
- `GET /health/db` - Database connectivity check
- `GET /info` - Configuration information
- `GET /metrics` - Simple metrics

## Build and Deploy

```bash
# Build container image
docker build -t gcr.io/YOUR_PROJECT_ID/oryontech-app:latest .

# Push to Container Registry
docker push gcr.io/YOUR_PROJECT_ID/oryontech-app:latest

# Update terraform.tfvars with your image
cloud_run_image = "gcr.io/YOUR_PROJECT_ID/oryontech-app:latest"

# Apply changes
terraform apply
```

## Local Testing

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export FLASK_ENV=development
export INSTANCE_CONNECTION_NAME=project:region:instance
export DB_USER=user
export DB_PASSWORD=password
export DB_NAME=database
export OPENAI_API_KEY=sk-test

# Run locally
python app.py
```

## Testing Database Connectivity

```bash
# Test health check
curl https://your-service-url/health

# Test database connectivity
curl https://your-service-url/health/db

# View logs
gcloud run logs read --service=staging-app --project=YOUR_PROJECT_ID
```
