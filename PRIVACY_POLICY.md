# Privacy Policy for Untwist

**Last Updated:** November 10, 2025
**Effective Date:** November 10, 2025

## Our Privacy Commitment

Untwist is built with your privacy as the foundation. This isn't just a policy—it's how we designed the app from the ground up. Your thoughts, feelings, and mental health data belong to you, and only you.

## Information We Do NOT Collect

We want to be crystal clear about what we don't do:

- ❌ **No account creation** - You don't create an account or sign in
- ❌ **No cloud storage** - Your data never leaves your device
- ❌ **No tracking** - We don't track what you do in the app
- ❌ **No analytics** - We don't collect usage statistics or behavior data
- ❌ **No advertising** - No ad networks, no ad tracking, no third parties
- ❌ **No personal information** - We don't collect your name, email, or contact info
- ❌ **No location data** - We don't access your location
- ❌ **No identifiers** - No device IDs, advertising IDs, or user tracking
- ❌ **No cookies or web beacons** - The app doesn't use any tracking technology

## How Your Data is Stored

**All data stays on your device.** Here's what that means:

### SwiftData Local Storage
- Your anxious thoughts, reframes, and reviews are stored using Apple's SwiftData framework
- This data is stored in a local database on your iPhone
- The database is encrypted at rest using iOS's built-in device encryption
- This data is included in your iCloud Backup or iTunes Backup (if you have those enabled)
- If you delete the app, all data is permanently deleted

### User Settings
- Your preferences (worry time, notification settings) are stored locally
- Settings persist across app launches but never leave your device

### No Server, No Cloud
- Untwist does not have a backend server for user data
- There is no cloud sync, no server-side storage, no remote access
- Your data cannot be accessed by us, law enforcement, or anyone else
- We cannot recover your data if you lose your device

## The One Exception: Optional Feedback

The only time data leaves your device is when **you explicitly choose** to send us feedback.

### Feedback API (Opt-In Only)
If you navigate to Settings → Send Feedback and submit feedback, here's what we collect:

**What We Collect:**
- Your feedback message (bug report, feature request, or general feedback)
- Device information (iPhone model, iOS version, app version, locale)
- Timestamp of when feedback was sent

**What We DON'T Collect:**
- Your thoughts, reframes, or any mental health data
- Your name, email, or any contact information
- Your location or IP address (not collected by us; AWS infrastructure may log IPs for security purposes but we don't access this data)
- Any tracking identifiers

**How We Use Feedback:**
- To fix bugs you report
- To consider feature requests
- To improve the app based on your suggestions
- Feedback is stored in a secure AWS database (DynamoDB)
- Feedback is not shared with third parties
- We may quote anonymous feedback in marketing materials (e.g., "A user suggested...")

**Feedback is Completely Optional:**
- You never have to send feedback to use Untwist
- The app works perfectly without ever contacting our servers
- There's no penalty or limitation if you never send feedback

## Ko-fi Donations (Optional)

Untwist is free to use, now and always. We accept voluntary donations via Ko-fi to support development.

### What Ko-fi Is
We use Ko-fi (ko-fi.com) to accept voluntary donations:
- **Completely optional** - All app features are free whether you donate or not
- **No special features** - Donors receive no additional functionality or perks
- **Third-party processed** - Ko-fi handles all payment processing, not us

### What We Collect Through Ko-fi
When you choose to donate via Ko-fi:
- **Ko-fi collects:** Your name (if provided), email, payment information, donation amount
- **We receive:** Your Ko-fi username, donation amount, and optional message
- **We do NOT receive:** Your payment card details, billing address, or personal information

### Ko-fi's Privacy
Ko-fi donations are subject to Ko-fi's Privacy Policy: https://ko-fi.com/home/privacy

Your payment information is never shared with us or stored by Untwist. Ko-fi uses Stripe and PayPal for secure payment processing.

### How We Use Donation Information
- We never sell or share donor information
- We never contact you for marketing purposes
- Donation data is stored separately from app usage (they're not linked to your device or thoughts)

### Your Rights
- Request deletion of your donation information: contact us at john@untwist.app
- Ko-fi may retain transaction records for legal/tax compliance purposes
- You can donate anonymously through Ko-fi's settings

## Notifications (Local Only)

If you enable notifications:
- Notifications are scheduled locally on your device using iOS's UserNotifications framework
- No data is sent to Apple or any server to deliver notifications
- You can disable notifications anytime in Settings
- Notification content is generated on your device

## Data Security

While we don't collect data, we still take security seriously:

### On-Device Security
- All data is encrypted at rest using iOS Data Protection (hardware encryption)
- If you have a passcode or Face ID/Touch ID enabled, your data is further protected
- Data is sandboxed within the app—other apps cannot access it
- Memory is cleared when the app closes

### API Security (Feedback Only)
- Feedback is sent over HTTPS (encrypted in transit)
- API uses authentication keys and rate limiting
- DynamoDB database is encrypted at rest with AWS KMS
- API Gateway has usage plans and throttling to prevent abuse

### No Breach Risk
- Since we don't collect your mental health data, it cannot be breached
- There are no user accounts to compromise
- There are no passwords to leak
- Your data stays with you, under your control

## Your Rights

### Access
- You have full access to all your data within the app
- Navigate to Settings → Archive to see all captured thoughts
- You can review any thought at any time

### Deletion
- Delete individual thoughts: Swipe left on any thought in the Archive
- Delete all data: Uninstall the app (Settings → General → iPhone Storage → Untwist → Delete App)
- Once deleted, data cannot be recovered (we don't have backups)

### Export (Coming in v1.1)
- We're adding the ability to export all your data as JSON
- You'll be able to save it, print it, or import it back later
- This is your data—you should be able to take it with you

### Portability
- Your data is stored in open formats (SwiftData/SQLite)
- Technically savvy users can access the database file in backups
- We'll provide official export tools in a future update

## Children's Privacy

Untwist is designed for general audiences and does not knowingly collect information from children under 13. However, since we don't collect any personal information at all, children can safely use the app with parental supervision.

If you are a parent and believe your child has used the feedback feature, please contact us and we'll delete any feedback data.

## Third-Party Services

**We use NO third-party services in the app itself.** No analytics, no crash reporting, no ad networks, nothing.

The only third-party infrastructure we use is AWS for the optional feedback API:
- **AWS API Gateway** - Routes feedback to our Lambda function
- **AWS Lambda** - Processes feedback submissions
- **AWS DynamoDB** - Stores feedback data
- **AWS KMS** - Encrypts feedback data at rest

AWS may collect metadata like IP addresses and timestamps in their logs, but we don't access or use this data. AWS's infrastructure is HIPAA, SOC 2, and ISO 27001 compliant.

## Changes to This Policy

If we update this privacy policy:
- We'll update the "Last Updated" date at the top
- We'll notify you within the app (if the change is material)
- Continued use of the app means you accept the updated policy
- You can always review this policy at [URL where you'll host it]

We will never:
- Change the fundamental privacy-first nature of Untwist
- Start collecting personal data or mental health data
- Introduce tracking or analytics without your explicit consent
- Sell or share your data with third parties

## Data Processing Location

- **Your mental health data:** Stays on your iPhone (wherever you are)
- **Optional feedback:** Stored in AWS us-east-1 (Virginia, USA)

## Legal Basis (GDPR Compliance)

While Untwist doesn't collect personal data, here's our legal basis if it did:

- **Legitimate Interest:** Processing feedback to improve the app
- **Consent:** You explicitly send feedback by tapping "Submit"
- **Contract:** N/A (no account, no contract)
- **Legal Obligation:** N/A (we have no legal obligation to collect data)

Since we don't collect personal data, most GDPR requirements don't apply. However, we follow GDPR principles anyway:
- **Data minimization** - We collect nothing unless you send feedback
- **Purpose limitation** - Feedback is only used to improve the app
- **Storage limitation** - Feedback is kept only as long as it's useful
- **Transparency** - This policy clearly explains everything

## California Privacy Rights (CCPA)

Under the California Consumer Privacy Act (CCPA):

**Categories of Personal Information We Collect:** None (except optional feedback metadata)

**Do Not Sell:** We do not sell personal information. We never have, and we never will.

**Your CCPA Rights:**
- Right to know what data we have (answer: none, unless you sent feedback)
- Right to delete (answer: delete the app, or contact us about feedback)
- Right to opt-out of sale (answer: we don't sell anything)

## Contact Us

If you have questions about this privacy policy or your data:

**Developer:** John Pacheco
**Location:** New Bedford, MA
**Email:** john@untwist.app
**Response Time:** We aim to respond within 48 hours

For feedback data deletion requests, please include:
- The approximate date you sent feedback
- The type of feedback (bug/feature/general)
- Any details that help us identify your submission

## Disclaimer

Untwist is not a medical device, clinical tool, or therapy replacement. It's a personal journaling and thought reframing tool based on cognitive behavioral therapy techniques.

If you're experiencing a mental health crisis, please contact:
- **988 Suicide & Crisis Lifeline:** Call or text 988 (US)
- **Crisis Text Line:** Text HOME to 741741 (US)
- **International:** Find resources at https://findahelpline.com

---

## Summary (TL;DR)

**What makes Untwist different:**
- ✅ Your data never leaves your device (except optional feedback)
- ✅ No accounts, no cloud, no tracking
- ✅ We can't access your thoughts—even if we wanted to
- ✅ Open about the one exception (feedback API)
- ✅ You're in complete control

**Our promise:**
Your mental health data belongs to you, and only you. Period.

---

**Questions?** Email us at john@untwist.app. We're real humans who care about your privacy.

**Last Updated:** November 10, 2025
**Version:** 1.0
