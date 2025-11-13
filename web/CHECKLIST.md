# Deployment Checklist

Use this checklist to track your progress when setting up static document hosting.

---

## Pre-Deployment

- [ ] Review `privacy.html` in browser
- [ ] Review `terms.html` in browser
- [ ] Verify content accuracy (dates, contact info, etc.)
- [ ] Test mobile rendering (Safari on iPhone)
- [ ] Test dark mode (System Preferences → Appearance → Dark)
- [ ] Confirm domain ownership (`Monitor.app`)
- [ ] Know where domain is registered (Route 53, Namecheap, etc.)
- [ ] AWS account access confirmed
- [ ] AWS CLI installed (optional, run: `aws --version`)

---

## AWS Setup (S3 + CloudFront)

### Phase 1: S3 Bucket (5 minutes)

- [ ] Log into AWS Console
- [ ] Navigate to S3 service
- [ ] Create new bucket: `Monitor-app-legal-docs`
- [ ] Region: `us-east-1` (Virginia)
- [ ] Uncheck "Block all public access"
- [ ] Upload `privacy.html`
- [ ] Upload `terms.html`
- [ ] Add bucket policy for public read access
- [ ] Test S3 Object URLs (click files, copy URLs, open in browser)

**S3 URLs should work**:
- `https://Monitor-app-legal-docs.s3.amazonaws.com/privacy.html`
- `https://Monitor-app-legal-docs.s3.amazonaws.com/terms.html`

### Phase 2: SSL Certificate (5 minutes + wait)

- [ ] Navigate to AWS Certificate Manager (ACM)
- [ ] **IMPORTANT**: Confirm region is `us-east-1`
- [ ] Request public certificate
- [ ] Add domain: `Monitor.app`
- [ ] Add wildcard: `*.Monitor.app`
- [ ] Choose DNS validation
- [ ] Create DNS validation records (auto or manual)
- [ ] Wait for certificate status: "Issued" (5-30 minutes)

**Certificate ARN** (save for CloudFront): `arn:aws:acm:us-east-1:...`

### Phase 3: CloudFront Distribution (10 minutes + wait)

- [ ] Navigate to CloudFront service
- [ ] Click "Create distribution"
- [ ] Origin domain: Select S3 bucket from dropdown
- [ ] Origin access: "Public"
- [ ] Viewer protocol policy: "Redirect HTTP to HTTPS"
- [ ] Allowed HTTP methods: "GET, HEAD"
- [ ] Cache policy: "CachingOptimized"
- [ ] Alternate domain names (CNAMEs): `Monitor.app`
- [ ] Custom SSL certificate: Select your ACM certificate
- [ ] Click "Create distribution"
- [ ] Wait for status: "Enabled" (5-15 minutes)

**CloudFront Domain** (save for DNS): `d1234abcdef.cloudfront.net`

### Phase 4: URL Routing (5 minutes)

- [ ] Navigate to CloudFront → Functions
- [ ] Click "Create function"
- [ ] Name: `url-rewrite-legal-docs`
- [ ] Runtime: CloudFront Functions
- [ ] Paste function code (from `DEPLOYMENT_GUIDE.md` Phase 4)
- [ ] Click "Save changes"
- [ ] Click "Publish" tab → "Publish function"
- [ ] Click "Associate" tab → "Add association"
- [ ] Select your distribution
- [ ] Event type: "Viewer request"
- [ ] Cache behavior: "Default (*)"
- [ ] Click "Add association"

### Phase 5: DNS Configuration (5 minutes + wait)

#### If using Route 53:
- [ ] Navigate to Route 53 → Hosted zones
- [ ] Select `Monitor.app`
- [ ] Click "Create record"
- [ ] Record name: (empty for root domain)
- [ ] Record type: A
- [ ] Toggle "Alias" ON
- [ ] Route traffic to: "Alias to CloudFront distribution"
- [ ] Select your distribution
- [ ] Click "Create records"

#### If using another registrar:
- [ ] Log into domain registrar
- [ ] Find DNS settings for `Monitor.app`
- [ ] Add CNAME or A record pointing to CloudFront domain
- [ ] Wait for DNS propagation (5-60 minutes)

**Check DNS propagation**: `dig Monitor.app` or https://dnschecker.org

### Phase 6: Testing (5 minutes)

- [ ] Open: `https://Monitor.app/privacy`
- [ ] Verify: HTTPS padlock icon present
- [ ] Verify: Content loads correctly
- [ ] Verify: No certificate warnings
- [ ] Open: `https://Monitor.app/terms`
- [ ] Verify: HTTPS padlock icon present
- [ ] Verify: Content loads correctly
- [ ] Test on mobile device (iPhone Safari)
- [ ] Test dark mode (iOS Settings → Display → Dark)
- [ ] Test both portrait and landscape orientations

---

## Deployment Script Setup (Optional)

- [ ] Open `deploy.sh` in text editor
- [ ] Update `BUCKET_NAME` with your bucket name
- [ ] Update `DISTRIBUTION_ID` with your CloudFront distribution ID
- [ ] Save file
- [ ] Test deployment: `./deploy.sh`
- [ ] Verify files uploaded successfully
- [ ] Verify CloudFront invalidation created

---

## iOS App Updates

- [ ] Open Monitor Xcode project
- [ ] Update Privacy Policy URL to: `https://Monitor.app/privacy`
- [ ] Update Terms of Service URL to: `https://Monitor.app/terms`
- [ ] Test links in iOS app (Simulator)
- [ ] Test links on physical device
- [ ] Verify URLs open correctly in Safari
- [ ] Build app for release

---

## App Store Connect

- [ ] Log into App Store Connect
- [ ] Navigate to your app
- [ ] Go to "App Information" section
- [ ] Update "Privacy Policy URL": `https://Monitor.app/privacy`
- [ ] Update "Terms of Service URL": `https://Monitor.app/terms` (if applicable)
- [ ] Save changes
- [ ] Test URLs from App Store Connect (click to verify)

---

## Post-Deployment Verification

### Functional Testing
- [ ] Privacy page loads on desktop (Chrome, Safari, Firefox)
- [ ] Terms page loads on desktop (Chrome, Safari, Firefox)
- [ ] Privacy page loads on mobile (iOS Safari, Chrome)
- [ ] Terms page loads on mobile (iOS Safari, Chrome)
- [ ] HTTPS works (no warnings)
- [ ] Dark mode works automatically
- [ ] Responsive layout works (resize browser)
- [ ] Links within documents work (privacy ↔ terms)

### Performance Testing
- [ ] Page loads in <2 seconds
- [ ] No console errors (F12 Developer Tools)
- [ ] Images/fonts load correctly (if any)
- [ ] Scrolling is smooth

### Compliance Verification
- [ ] Privacy Policy URL is publicly accessible
- [ ] Terms of Service URL is publicly accessible
- [ ] No authentication required to view pages
- [ ] Content matches App Store requirements
- [ ] Contact email is correct and monitored
- [ ] Last Updated date is accurate

---

## Ongoing Maintenance

### Monthly
- [ ] Check AWS billing (should be ~$0.50-1/month)
- [ ] Verify URLs still work (quick spot check)

### When Updating Documents
- [ ] Edit `privacy.html` or `terms.html` locally
- [ ] Review changes in browser
- [ ] Run `./deploy.sh` to upload
- [ ] Verify changes live on `Monitor.app`
- [ ] Test on mobile device
- [ ] Update "Last Updated" date in app (if needed)

### Annually
- [ ] Review Privacy Policy for accuracy
- [ ] Review Terms of Service for accuracy
- [ ] Check for regulatory changes (GDPR, CCPA, etc.)
- [ ] Verify contact information is current
- [ ] Review AWS costs and optimize if needed

---

## Troubleshooting

If something doesn't work, check:

- [ ] S3 bucket policy allows public read
- [ ] CloudFront distribution status is "Enabled"
- [ ] ACM certificate status is "Issued"
- [ ] ACM certificate is in `us-east-1` region
- [ ] DNS records are correct (A or CNAME)
- [ ] DNS has propagated (wait up to 48 hours)
- [ ] CloudFront Function is published and associated
- [ ] Browser cache cleared (hard refresh: Cmd+Shift+R)

See `DEPLOYMENT_GUIDE.md` → Troubleshooting section for detailed help.

---

## Rollback Plan (If Needed)

If something goes wrong:

1. **S3 Issue**: Re-upload files from `/Users/japacheco/ios-development/Monitor/web/`
2. **CloudFront Issue**: Delete and recreate distribution
3. **DNS Issue**: Revert DNS records to previous values
4. **Certificate Issue**: Request new certificate, update CloudFront

**Backup Contact**: Keep AWS Support phone number handy if you have support plan.

---

## Success Criteria

You're done when:

✅ `https://Monitor.app/privacy` loads correctly
✅ `https://Monitor.app/terms` loads correctly
✅ HTTPS works (padlock icon)
✅ Mobile rendering is perfect
✅ Dark mode works
✅ Links work from iOS app
✅ App Store Connect URLs are updated
✅ AWS billing is as expected (~$0.50-1/month)

---

## Notes

**Time Required**: 30-45 minutes for first-time setup
**Cost**: ~$0.50-1/month
**Maintenance**: Near-zero (update files as needed)

**Questions?** See `DEPLOYMENT_GUIDE.md` or ask for help!

---

*Last Updated: November 10, 2025*
