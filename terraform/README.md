# Monitor Feedback API - Terraform Infrastructure

This Terraform configuration deploys a complete serverless feedback API infrastructure on AWS for the Monitor iOS app.

## Architecture

```
┌─────────────┐
│  iOS App    │
│  (Monitor)  │
└──────┬──────┘
       │ HTTPS POST
       ▼
┌──────────────────────┐
│  api.Monitor.app     │
│  (Custom Domain)     │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  API Gateway         │
│  - /feedback (POST)  │
│  - /admin/feedback   │
│  - Rate limiting     │
│  - API keys          │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  Lambda Functions    │
│  - Feedback Handler  │
│  - Admin Handler     │
└──────┬───────────────┘
       │
       ├─────────────┬─────────────┐
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ DynamoDB │  │   SES    │  │CloudWatch│
│ (Storage)│  │ (Email)  │  │  (Logs)  │
└──────────┘  └──────────┘  └──────────┘
```

## Resources Created

- **API Gateway**: REST API with custom domain
- **Lambda Functions**: 2 functions (feedback handler, admin handler)
- **DynamoDB Table**: NoSQL database for feedback storage
- **SES**: Email service for notifications
- **ACM Certificate**: SSL/TLS certificate for custom domain
- **CloudWatch**: Logs and monitoring
- **IAM Roles**: Least-privilege permissions

## Cost Estimate

For **50 feedback submissions/month** (typical early usage):

| Service | Cost |
|---------|------|
| API Gateway | ~$0.00 (free tier) |
| Lambda | ~$0.00 (free tier) |
| DynamoDB | ~$0.25/month (on-demand) |
| SES | ~$0.00 (first 1,000 emails free) |
| Route 53 | $0.50/month (if using) |
| CloudWatch | ~$0.00 (free tier) |
| **Total** | **~$0.25-0.75/month** |

## Prerequisites

### 1. Install Terraform

```bash
# macOS (using Homebrew)
brew install terraform

# Verify installation
terraform version
```

### 2. Configure AWS CLI

```bash
# Install AWS CLI
brew install awscli

# Configure credentials
aws configure

# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

### 3. Verify AWS Credentials

```bash
aws sts get-caller-identity
```

## Setup Instructions

### Step 1: Prepare Configuration

```bash
# Navigate to terraform directory
cd terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars
```

**Required variables to set:**
```hcl
notification_email = "your-email@example.com"  # Your email
from_email         = "noreply@Monitor.app"     # Sender email
domain_name        = "Monitor.app"             # Your domain
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init
```

### Step 3: Plan Deployment

```bash
# Review what will be created
terraform plan

# Save plan to file (optional)
terraform plan -out=tfplan
```

**Review the plan carefully!** Ensure:
- Resources are being created in the correct region (us-east-1)
- Domain name is correct
- Email addresses are correct

### Step 4: Deploy Infrastructure

```bash
# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

**Deployment takes ~5-10 minutes**. You'll see outputs when complete.

### Step 5: Verify SES Email Addresses

After Terraform completes:

1. **Check your email inbox** for verification emails from AWS
2. **Click the verification link** in each email
3. Verify both:
   - `from_email` (e.g., noreply@Monitor.app)
   - `notification_email` (your email)

### Step 6: Configure DNS (Namecheap)

Since your domain is in Namecheap, you need to add DNS records:

#### Option A: Certificate Validation (Required)

1. Get validation records:
```bash
terraform output domain_validation_records
```

2. In Namecheap DNS settings, add the CNAME record shown

#### Option B: API Endpoint (Required)

1. Get the API Gateway target:
```bash
terraform output api_gateway_domain_target
```

2. In Namecheap, add CNAME record:
   - **Type**: CNAME Record
   - **Host**: api
   - **Value**: [regional_domain from output]
   - **TTL**: Automatic

**Wait 5-30 minutes for DNS propagation**

### Step 7: Get API Key (if enabled)

```bash
# View the API key
terraform output -raw api_key

# Save this securely - you'll need it for the iOS app
```

### Step 8: Test the API

```bash
# Get the endpoint URL
terraform output feedback_endpoint

# Test POST request
curl -X POST $(terraform output -raw feedback_endpoint) \
  -H "Content-Type: application/json" \
  -H "x-api-key: $(terraform output -raw api_key)" \
  -d '{
    "feedback": "Test feedback from Terraform setup",
    "type": "general_feedback",
    "diagnostic": {
      "appVersion": "1.0.0",
      "iosVersion": "17.2",
      "device": "iPhone15,2",
      "locale": "en_US"
    },
    "timestamp": "2025-11-08T12:00:00Z"
  }'
```

**Expected response:**
```json
{
  "success": true,
  "feedbackId": "uuid-here",
  "message": "Feedback received successfully"
}
```

### Step 9: Update iOS App

If API key is enabled, update `FeedbackService.swift`:

```swift
// In FeedbackService.swift

private let apiKey = "YOUR-API-KEY-FROM-TERRAFORM-OUTPUT"

func sendFeedback(...) async -> Result<Void, FeedbackError> {
    // ... existing code ...

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key") // ADD THIS LINE

    // ... rest of code ...
}
```

## Managing Infrastructure

### View Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output feedback_endpoint

# View sensitive output (API key)
terraform output -raw api_key
```

### Update Infrastructure

```bash
# Make changes to .tf files or terraform.tfvars

# Review changes
terraform plan

# Apply changes
terraform apply
```

### Monitor Resources

```bash
# View Lambda logs
aws logs tail /aws/lambda/Monitor-feedback-handler-prod --follow

# Check DynamoDB items
aws dynamodb scan --table-name Monitor-feedback-prod --limit 10

# View API Gateway metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=Monitor-api-prod \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

### Destroy Infrastructure

⚠️ **WARNING**: This will delete all resources and data!

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

## Troubleshooting

### Issue: Certificate Validation Pending

**Solution:**
1. Check Namecheap DNS for validation CNAME record
2. Wait 15-30 minutes for DNS propagation
3. Verify record with: `dig _validation.api.Monitor.app CNAME`

### Issue: SES Email Not Verified

**Solution:**
1. Check spam folder for verification email
2. Resend verification: AWS Console → SES → Verified identities → Resend
3. Ensure email address is exactly correct in `terraform.tfvars`

### Issue: API Returns 403 Forbidden

**Solution:**
1. Check if API key is required: `terraform output enable_api_key`
2. Verify API key header: `x-api-key: YOUR-KEY`
3. Check CloudWatch logs for detailed error

### Issue: DNS Not Resolving

**Solution:**
1. Verify CNAME record in Namecheap
2. Wait 30 minutes for propagation
3. Test with: `dig api.Monitor.app`
4. Flush DNS cache: `sudo dscacheutil -flushcache`

### Issue: Terraform State Lock

**Solution:**
```bash
# If using S3 backend and state is locked
terraform force-unlock LOCK_ID

# Or manually remove lock in DynamoDB table
```

## File Structure

```
terraform/
├── README.md                      # This file
├── providers.tf                   # AWS provider configuration
├── variables.tf                   # Input variables
├── terraform.tfvars.example       # Example variables file
├── outputs.tf                     # Output values
├── main.tf                        # Main configuration (if needed)
├── dynamodb.tf                    # DynamoDB table
├── iam.tf                         # IAM roles and policies
├── lambda.tf                      # Lambda functions
├── api_gateway.tf                 # API Gateway configuration
├── route53.tf                     # DNS and domain setup
├── ses.tf                         # Email service
└── lambda-packages/               # Packaged Lambda code (auto-generated)
    ├── feedback-handler.zip
    └── admin-handler.zip
```

## Security Best Practices

✅ **Implemented:**
- API Gateway throttling (10 req/sec, 20 burst)
- API key authentication
- HTTPS only (TLS 1.2+)
- IAM least-privilege permissions
- DynamoDB encryption at rest
- CloudWatch logging enabled
- Deletion protection on DynamoDB (prod)

🔒 **Recommendations:**
- Store API key in iOS app's secure keychain
- Enable AWS GuardDuty for threat detection
- Set up CloudWatch alarms for errors
- Regularly review CloudWatch logs
- Enable AWS Config for compliance

## Extending the Infrastructure

### Add Staging Environment

```bash
# Create new workspace
terraform workspace new staging

# Apply with different variables
terraform apply -var="environment=staging"
```

### Add SNS Alerts

```hcl
# In ses.tf
enable_ses_notifications = true
```

### Add Custom Metrics

```hcl
# In lambda.tf - add environment variable
METRICS_NAMESPACE = "Monitor/Feedback"
```

### Enable X-Ray Tracing

```hcl
# In terraform.tfvars
enable_xray_tracing = true
```

## Support

For issues with:
- **Terraform**: Check Terraform docs or open an issue
- **AWS Services**: Consult AWS documentation
- **iOS App**: See main README.md in project root

## License

This Terraform configuration is part of the Monitor project.
