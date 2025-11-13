# Quick Start: Host Legal Docs on Monitor.app

## TL;DR - Recommended Solution

**Use S3 + CloudFront**
- **Cost**: ~$0.50-1/month
- **Setup**: 30-45 minutes
- **Maintenance**: Near-zero

---

## 5-Minute Setup (Console-Based)

### 1. Create S3 Bucket (5 min)
```
S3 Console → Create bucket
- Name: Monitor-app-legal-docs
- Region: us-east-1
- Uncheck "Block all public access"
- Upload privacy.html and terms.html
- Add bucket policy (see DEPLOYMENT_GUIDE.md)
```

### 2. Get SSL Certificate (5 min + wait)
```
ACM Console (us-east-1 region!)
- Request certificate for: Monitor.app, *.Monitor.app
- Validation: DNS (auto-create Route 53 records if possible)
- Wait 5-30 min for validation
```

### 3. Create CloudFront Distribution (10 min)
```
CloudFront Console → Create distribution
- Origin: Your S3 bucket
- Viewer protocol: Redirect HTTP to HTTPS
- CNAMEs: Monitor.app
- SSL: Your ACM certificate
- Wait 5-15 min for deployment
```

### 4. Add URL Routing (5 min)
```
CloudFront → Functions → Create function
- Name: url-rewrite-legal-docs
- Code: See DEPLOYMENT_GUIDE.md Phase 4
- Publish → Associate with distribution
```

### 5. Update DNS (5 min + wait)
```
Route 53 (or your registrar)
- Create A record (alias) for Monitor.app → CloudFront
- Wait 5-60 min for DNS propagation
```

### 6. Test
```
https://Monitor.app/privacy
https://Monitor.app/terms
```

---

## Alternative: GitHub Pages (FREE)

If you want zero cost and don't mind GitHub:

```bash
cd /Users/japacheco/ios-development/Monitor/web
git init
git add privacy.html terms.html
git commit -m "Add legal documents"

# Create repo on GitHub: Monitor-legal
git remote add origin https://github.com/YOUR-USERNAME/Monitor-legal.git
git push -u origin main

# Enable GitHub Pages in repo settings
# Set custom domain: Monitor.app
# Update DNS with GitHub Pages IPs
```

**URLs will be**:
- `https://Monitor.app/privacy.html`
- `https://Monitor.app/terms.html`

---

## Comparison

| Feature | S3 + CloudFront | GitHub Pages |
|---------|----------------|--------------|
| **Cost** | ~$0.50-1/month | FREE |
| **Setup Time** | 30-45 min | 15-20 min |
| **AWS Integration** | Yes (same stack) | No |
| **Custom URLs** | `/privacy`, `/terms` | `/privacy.html`, `/terms.html` |
| **Maintenance** | Very low | Very low |
| **SSL** | Free (ACM) | Free (GitHub) |
| **CDN** | Yes (CloudFront) | Yes (GitHub) |

---

## What I Recommend

**For you (indie dev, already using AWS):**

→ **Use S3 + CloudFront**

**Reasons**:
- You're already in AWS (Lambda, DynamoDB, API Gateway)
- All infrastructure in one place
- Professional setup
- Full control
- Clean URLs (`/privacy` not `/privacy.html`)
- Less than a cup of coffee per month

**When to use GitHub Pages**:
- You want absolutely zero cost
- You're comfortable with GitHub
- You don't mind `.html` in URLs
- You want git-based deployments

---

## Files You Have

- ✅ `/Users/japacheco/ios-development/Monitor/web/privacy.html` (ready to upload)
- ✅ `/Users/japacheco/ios-development/Monitor/web/terms.html` (ready to upload)
- ✅ `DEPLOYMENT_GUIDE.md` (detailed step-by-step instructions)
- ✅ `QUICK_START.md` (this file)

---

## Update Workflow (After Deployment)

When you need to update legal docs:

```bash
# 1. Edit privacy.html or terms.html
# 2. Upload to S3
aws s3 cp privacy.html s3://Monitor-app-legal-docs/privacy.html

# 3. Invalidate CloudFront cache (immediate update)
aws cloudfront create-invalidation \
  --distribution-id YOUR-DISTRIBUTION-ID \
  --paths "/privacy.html"
```

Or use AWS Console:
1. S3 → Upload new file (overwrites old)
2. CloudFront → Invalidations → Create invalidation

---

## Next Steps

1. **Choose your approach** (S3 + CloudFront recommended)
2. **Follow DEPLOYMENT_GUIDE.md** for detailed steps
3. **Test thoroughly** before App Store submission
4. **Update iOS app** with new URLs
5. **Submit to App Store**

---

## Questions to Answer First

Before you start, confirm:

1. **Where is Monitor.app registered?**
   - Route 53? → Easier DNS setup
   - Namecheap/Google/etc? → Manual DNS configuration

2. **Is Monitor.app already in use?**
   - If yes, what's currently hosted there?
   - Do you need to preserve existing content?

3. **Do you have AWS CLI configured?**
   - If yes, you can use automated deploy scripts
   - If no, you'll use AWS Console (works great too)

---

## Get Help

- **Detailed instructions**: See `DEPLOYMENT_GUIDE.md`
- **Troubleshooting**: See `DEPLOYMENT_GUIDE.md` → Troubleshooting section
- **AWS Docs**: https://docs.aws.amazon.com/

Good luck! 🚀
