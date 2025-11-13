# Untwist Legal Documents

Static HTML hosting for Privacy Policy and Terms of Service, required by Apple App Store.

## Files

- **`privacy.html`** - Privacy Policy (hosted at `https://untwist.app/privacy`)
- **`terms.html`** - Terms of Service (hosted at `https://untwist.app/terms`)
- **`deploy.sh`** - Deployment script for AWS S3 + CloudFront
- **`DEPLOYMENT_GUIDE.md`** - Comprehensive setup instructions (START HERE)
- **`QUICK_START.md`** - Quick reference guide

## Quick Reference

### First-Time Setup

1. Read `DEPLOYMENT_GUIDE.md` for complete setup instructions
2. Set up S3 bucket, CloudFront distribution, and DNS
3. Update `deploy.sh` with your bucket name and distribution ID

### Updating Documents

When you need to update the legal documents:

#### Option 1: Automated Deploy (Recommended)

```bash
cd /Users/japacheco/ios-development/Untwist/web
./deploy.sh
```

This will:
- Upload `privacy.html` and `terms.html` to S3
- Invalidate CloudFront cache (immediate update)

#### Option 2: AWS Console

1. Go to S3 Console
2. Navigate to your bucket
3. Upload new files (overwrites existing)
4. (Optional) Invalidate CloudFront cache for immediate updates

### Testing

After deployment, verify:
- https://untwist.app/privacy
- https://untwist.app/terms

Check:
- ✅ HTTPS works (padlock icon)
- ✅ Content is correct
- ✅ Mobile rendering looks good
- ✅ Dark mode support works

## Design Notes

The HTML files use:
- **Warm color palette** matching the Untwist app (`#E07856` primary)
- **Responsive design** (mobile-first)
- **Dark mode support** (automatic via `prefers-color-scheme`)
- **Clean typography** (Apple system fonts)
- **Fast loading** (no external dependencies, pure HTML/CSS)

## Markdown Source

Original markdown files (for editing):
- `/Users/japacheco/ios-development/Untwist/PRIVACY_POLICY.md`
- `/Users/japacheco/ios-development/Untwist/TERMS_OF_SERVICE.md`

If you update the markdown files, regenerate HTML with your preferred tool or ask Claude to update the HTML files.

## Cost

Hosting costs approximately **$0.50-1/month** with AWS S3 + CloudFront:
- S3 storage: ~$0.01/month
- S3 requests: ~$0.01/month
- CloudFront: ~$0.50/month (first 1TB free)
- Route 53 (if used): $0.50/month

## Support

For issues:
1. Check `DEPLOYMENT_GUIDE.md` → Troubleshooting section
2. Review AWS CloudWatch logs
3. Contact AWS Support (if you have a support plan)

## License

Copyright © 2025 John Pacheco. All rights reserved.
