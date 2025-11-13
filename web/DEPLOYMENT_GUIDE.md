# Static Document Hosting Deployment Guide

## Overview

This guide walks you through hosting `privacy.html` and `terms.html` on `Monitor.app` using AWS S3 + CloudFront.

**Total Cost**: ~$0.50-1/month
**Setup Time**: 30-45 minutes
**Maintenance**: Near-zero (just upload new files when updating)

---

## Architecture

```
User Request: https://Monitor.app/privacy
    ↓
Route 53 DNS (Monitor.app → CloudFront)
    ↓
CloudFront Distribution (CDN + HTTPS + caching)
    ↓
S3 Bucket (stores privacy.html, terms.html)
```

---

## Prerequisites

1. AWS Account (you already have one for your feedback API)
2. Domain `Monitor.app` registered (where is it registered?)
3. AWS CLI installed (optional, but helpful)

---

## Step-by-Step Deployment

### Phase 1: Create S3 Bucket

1. **Go to S3 Console**
   https://s3.console.aws.amazon.com/s3/

2. **Create Bucket**
   - Click "Create bucket"
   - **Bucket name**: `Monitor-app-legal-docs` (must be globally unique)
   - **Region**: `us-east-1` (same as your existing infrastructure)
   - **Block Public Access**: UNCHECK "Block all public access"
     - ⚠️ You'll get a warning—this is expected. We need public access for the HTML files.
   - Click "Create bucket"

3. **Upload HTML Files**
   - Click into your new bucket
   - Click "Upload"
   - Drag and drop:
     - `privacy.html`
     - `terms.html`
   - Click "Upload"

4. **Set Bucket Policy**
   - Click on the bucket name
   - Go to "Permissions" tab
   - Scroll to "Bucket policy"
   - Click "Edit"
   - Paste this policy (replace `YOUR-BUCKET-NAME` with your actual bucket name):

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
       }
     ]
   }
   ```

   - Click "Save changes"

5. **Test Direct S3 Access**
   - Click on `privacy.html` in your bucket
   - Copy the "Object URL" (e.g., `https://Monitor-app-legal-docs.s3.amazonaws.com/privacy.html`)
   - Open it in a browser—you should see your privacy policy

---

### Phase 2: Request SSL Certificate (ACM)

1. **Go to Certificate Manager**
   https://console.aws.amazon.com/acm/home?region=us-east-1

   ⚠️ **IMPORTANT**: You MUST use `us-east-1` region for CloudFront certificates!

2. **Request Certificate**
   - Click "Request a certificate"
   - Choose "Request a public certificate"
   - Click "Next"

3. **Domain Names**
   - **Fully qualified domain name**: `Monitor.app`
   - Click "Add another name to this certificate"
   - Add: `*.Monitor.app` (wildcard for subdomains)
   - Click "Next"

4. **Validation Method**
   - Choose "DNS validation" (recommended)
   - Click "Request"

5. **Validate Certificate**
   - You'll see pending validation status
   - Click "Create records in Route 53" (if your domain is in Route 53)
     - OR manually add CNAME records to your DNS provider
   - Wait 5-30 minutes for validation (AWS will email you when ready)

---

### Phase 3: Create CloudFront Distribution

1. **Go to CloudFront Console**
   https://console.aws.amazon.com/cloudfront/

2. **Create Distribution**
   - Click "Create distribution"

3. **Origin Settings**
   - **Origin domain**: Select your S3 bucket from dropdown (e.g., `Monitor-app-legal-docs.s3.amazonaws.com`)
   - **Origin path**: Leave empty
   - **Name**: Auto-filled (leave as-is)
   - **Origin access**: Choose "Public"

4. **Default Cache Behavior**
   - **Viewer protocol policy**: "Redirect HTTP to HTTPS"
   - **Allowed HTTP methods**: "GET, HEAD"
   - **Cache policy**: "CachingOptimized" (recommended for static content)
   - Leave other defaults

5. **Settings**
   - **Price class**: "Use all edge locations" (or "Use only North America and Europe" to save ~$0.10/month)
   - **Alternate domain names (CNAMEs)**: Add `Monitor.app`
   - **Custom SSL certificate**: Select the ACM certificate you created in Phase 2
   - **Default root object**: Leave empty (we'll use CloudFront Functions for routing)

6. **Create Distribution**
   - Click "Create distribution"
   - Wait 5-15 minutes for deployment (status will change from "Deploying" to "Enabled")
   - Copy the "Distribution domain name" (e.g., `d1234abcdef8.cloudfront.net`)

---

### Phase 4: Configure URL Routing (CloudFront Functions)

We need to route `/privacy` → `/privacy.html` and `/terms` → `/terms.html`.

1. **Create CloudFront Function**
   - In CloudFront console, go to "Functions" in left sidebar
   - Click "Create function"
   - **Name**: `url-rewrite-legal-docs`
   - **Runtime**: CloudFront Functions
   - Click "Create function"

2. **Add Function Code**
   - In the "Build" tab, paste this code:

   ```javascript
   function handler(event) {
       var request = event.request;
       var uri = request.uri;

       // Add .html extension if missing
       if (uri === '/privacy') {
           request.uri = '/privacy.html';
       } else if (uri === '/terms') {
           request.uri = '/terms.html';
       } else if (uri === '/') {
           // Redirect root to privacy (or you can add an index.html later)
           return {
               statusCode: 302,
               statusDescription: 'Found',
               headers: {
                   'location': { value: '/privacy' }
               }
           };
       }

       return request;
   }
   ```

   - Click "Save changes"

3. **Publish Function**
   - Click "Publish" tab
   - Click "Publish function"

4. **Associate with Distribution**
   - Click "Associate" tab
   - Click "Add association"
   - **Distribution**: Select your distribution
   - **Event type**: "Viewer request"
   - **Cache behavior**: "Default (*)"
   - Click "Add association"

---

### Phase 5: Update DNS (Route 53 or Your Registrar)

#### If using Route 53:

1. **Go to Route 53 Console**
   https://console.aws.amazon.com/route53/

2. **Select Hosted Zone**
   - Click on `Monitor.app`

3. **Create A Record**
   - Click "Create record"
   - **Record name**: Leave empty (this is the root domain)
   - **Record type**: A
   - **Alias**: Toggle ON
   - **Route traffic to**: "Alias to CloudFront distribution"
   - **Choose distribution**: Select your CloudFront distribution
   - Click "Create records"

#### If using another registrar (Namecheap, Google Domains, etc.):

1. Log into your domain registrar
2. Find DNS settings for `Monitor.app`
3. Add a CNAME record:
   - **Host**: `@` (or leave empty for root domain)
   - **Value**: Your CloudFront distribution domain (e.g., `d1234abcdef8.cloudfront.net`)
   - **TTL**: 3600 (1 hour)

   ⚠️ **Note**: Some registrars don't allow CNAME on root domain. If that's the case:
   - Use an A record pointing to CloudFront's IP (you'll need to look this up)
   - OR use a subdomain like `www.Monitor.app` or `legal.Monitor.app`

---

### Phase 6: Test Your Deployment

1. **Wait for DNS Propagation** (5-60 minutes)

2. **Test URLs**
   - Open: `https://Monitor.app/privacy`
   - Open: `https://Monitor.app/terms`
   - Verify HTTPS is working (look for padlock icon)
   - Test on mobile device

3. **Verify in App**
   - Update your app's Privacy Policy URL to: `https://Monitor.app/privacy`
   - Update your app's Terms URL to: `https://Monitor.app/terms`
   - Test links in your iOS app

---

## Updating Documents

When you need to update your legal documents:

### Option A: AWS Console (Easy)

1. Go to S3 Console
2. Navigate to your bucket
3. Click "Upload"
4. Upload the new `privacy.html` or `terms.html` (will overwrite)
5. Wait 5-10 minutes for CloudFront cache to refresh
   - OR manually invalidate cache (see below)

### Option B: AWS CLI (Faster)

```bash
# Upload new file
aws s3 cp privacy.html s3://Monitor-app-legal-docs/privacy.html

# Invalidate CloudFront cache (immediate update)
aws cloudfront create-invalidation \
  --distribution-id YOUR-DISTRIBUTION-ID \
  --paths "/privacy.html"
```

### Manually Invalidate CloudFront Cache

If you need immediate updates:

1. Go to CloudFront Console
2. Select your distribution
3. Go to "Invalidations" tab
4. Click "Create invalidation"
5. **Object paths**: Enter `/privacy.html` and `/terms.html` (one per line)
6. Click "Create invalidation"
7. Wait 1-2 minutes for invalidation to complete

---

## Cost Breakdown

### One-Time Costs
- **Domain registration**: $12-15/year (you already own `Monitor.app`)
- **SSL Certificate (ACM)**: FREE ✅

### Monthly Costs

| Service | Cost | Notes |
|---------|------|-------|
| **S3 Storage** | ~$0.01/month | 2 HTML files (~50KB total) |
| **S3 Requests** | ~$0.01/month | Assuming 1,000 requests/month |
| **CloudFront** | ~$0.50-1/month | First 1TB transfer free, then $0.085/GB |
| **Route 53** (if used) | $0.50/month | Per hosted zone |
| **Total** | **$0.50-1.50/month** | |

### Free Tier Eligibility

- **S3**: 5GB storage free for 12 months (new accounts)
- **CloudFront**: 1TB data transfer out free for 12 months
- **Route 53**: Not eligible for free tier

**Bottom line**: For your traffic (likely <1,000 visitors/month initially), you'll pay **$0.50-1/month**.

---

## Alternative: GitHub Pages (Free)

If you want a FREE option and don't mind another service:

### Pros:
- **Free** (no cost at all)
- Custom domain support (Monitor.app)
- Free SSL certificate
- Git-based updates (just push to update)
- Simple to set up

### Cons:
- Not integrated with your AWS infrastructure
- Another service to manage
- Requires GitHub account

### Quick Setup:

1. **Create GitHub Repo**
   ```bash
   cd /Users/japacheco/ios-development/Monitor/web
   git init
   git add privacy.html terms.html
   git commit -m "Add legal documents"
   git remote add origin https://github.com/YOUR-USERNAME/Monitor-legal.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**
   - Go to repo settings → Pages
   - Source: Deploy from `main` branch
   - Custom domain: `Monitor.app`

3. **Update DNS**
   - Add A records for GitHub Pages IPs:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`

4. **Test**: Visit `https://Monitor.app/privacy.html` after DNS propagates

**Note**: GitHub Pages serves files with `.html` extension, so you'd link to:
- `https://Monitor.app/privacy.html`
- `https://Monitor.app/terms.html`

---

## Troubleshooting

### Issue: "Access Denied" Error

**Cause**: Bucket policy not set correctly
**Solution**: Double-check bucket policy in Phase 1, Step 4

### Issue: "Certificate doesn't match domain"

**Cause**: ACM certificate not validated or not in `us-east-1`
**Solution**: Ensure certificate is in `us-east-1` and fully validated

### Issue: CloudFront serves old cached version

**Cause**: CloudFront caching (default 24 hours)
**Solution**: Create invalidation for `/privacy.html` and `/terms.html`

### Issue: DNS not resolving

**Cause**: DNS propagation delay or incorrect records
**Solution**: Wait up to 48 hours, check records with `dig Monitor.app`

### Issue: `/privacy` shows 404, but `/privacy.html` works

**Cause**: CloudFront Function not associated
**Solution**: Re-check Phase 4, ensure function is published and associated

---

## Security Best Practices

1. **Enable S3 Server Access Logging** (optional)
   - Track who's accessing your files
   - Helps with compliance

2. **Enable CloudFront Logging** (optional)
   - Monitor traffic patterns
   - Identify potential abuse

3. **Set Cache-Control Headers**
   - For legal docs, consider `Cache-Control: max-age=3600` (1 hour)
   - Allows quick updates while reducing S3 requests

4. **Use Least Privilege IAM**
   - Create IAM user specifically for S3 uploads
   - Don't use root account for deployments

---

## Automation (Optional)

### Deploy Script

Create `/Users/japacheco/ios-development/Monitor/web/deploy.sh`:

```bash
#!/bin/bash

BUCKET_NAME="Monitor-app-legal-docs"
DISTRIBUTION_ID="YOUR-CLOUDFRONT-DISTRIBUTION-ID"

echo "Uploading files to S3..."
aws s3 cp privacy.html s3://$BUCKET_NAME/privacy.html
aws s3 cp terms.html s3://$BUCKET_NAME/terms.html

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/privacy.html" "/terms.html"

echo "Deployment complete!"
```

Run with:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Next Steps

1. **Deploy** using Phase 1-6 above
2. **Update iOS App** with new URLs:
   - Privacy Policy: `https://Monitor.app/privacy`
   - Terms of Service: `https://Monitor.app/terms`
3. **Test** thoroughly before App Store submission
4. **Monitor Costs** in AWS Cost Explorer after 30 days

---

## Questions?

If you run into issues or have questions:
- Check AWS documentation: https://docs.aws.amazon.com/
- Contact AWS Support (if you have a support plan)
- Email me (Claude) with specific error messages

Good luck with your app launch! 🚀
