# Setting Up API Secrets

This guide explains how to configure the feedback API key securely without committing secrets to version control.

## Quick Setup

1. **Copy the template file:**
   ```bash
   cp Secrets.xcconfig.template Secrets.xcconfig
   ```

2. **Get your API key from Terraform:**
   ```bash
   cd terraform
   terraform output -raw api_key
   ```

3. **Edit `Secrets.xcconfig` and paste your API key:**
   ```
   FEEDBACK_API_KEY = your-actual-api-key-here
   ```

4. **Configure Xcode project** (one-time setup):
   - Open `Untwist.xcodeproj` in Xcode
   - Select the Untwist project in the navigator
   - Select the "Untwist" target
   - Go to "Build Settings" tab
   - Search for "Info.plist Values"
   - Click the "+" button under "Info.plist Values"
   - Add key: `FEEDBACK_API_KEY`
   - Set value to: `$(FEEDBACK_API_KEY)`

   **Alternative (easier):**
   - Go to the project's "Info" tab
   - Click "Configurations"
   - For both Debug and Release configurations:
     - Expand the Untwist target
     - Select "Secrets" from the dropdown (or click "+" to add Secrets.xcconfig)

5. **Build and run** - The app will now use your API key!

## How It Works

```
Secrets.xcconfig (gitignored)
    ↓
Build Settings (FEEDBACK_API_KEY variable)
    ↓
Info.plist (at build time)
    ↓
Config.swift (reads from Bundle.main.infoDictionary)
    ↓
FeedbackService.swift (uses Config.feedbackAPIKey)
```

## Security Notes

✅ **Safe:**
- `Secrets.xcconfig` is gitignored and never committed
- API key is injected at build time, not stored in source code
- Template file (`.template`) can safely be committed

⚠️ **Important:**
- The API key will be embedded in the compiled app binary
- Anyone with access to the app can extract it with reverse engineering tools
- This is acceptable because:
  - Rate limiting protects against abuse (10 req/sec)
  - API Gateway usage plans limit monthly usage
  - The key only grants access to submit feedback, not read/delete data
  - This is standard for public mobile apps (like Firebase API keys)

🔒 **For Extra Security:**
If you need stronger protection, consider:
- Server-side rate limiting per device ID
- App signature verification in Lambda
- Moving sensitive operations to an authenticated backend

## Troubleshooting

### "API key not configured" warning in debug builds

This means `Secrets.xcconfig` hasn't been created or configured in Xcode.

**Fix:**
1. Ensure `Secrets.xcconfig` exists (copy from `.template`)
2. Add your actual API key to the file
3. Configure Xcode to use `Secrets.xcconfig` (see step 4 above)
4. Clean build folder (Shift+Cmd+K) and rebuild

### Can't find Secrets.xcconfig in Xcode

**Fix:**
1. Right-click on the Untwist project folder in Xcode
2. Select "Add Files to Untwist..."
3. Navigate to and select `Secrets.xcconfig`
4. Uncheck "Copy items if needed"
5. Click "Add"

### API key showing as empty string

**Fix:**
- Check that `FEEDBACK_API_KEY` is set in Build Settings → Info.plist Values
- Verify the xcconfig is selected in Project → Info → Configurations
- Clean and rebuild

## Team Setup

When onboarding new developers:

1. Share this document
2. They run: `cp Secrets.xcconfig.template Secrets.xcconfig`
3. You share the API key securely (not via git/email)
4. They paste it into their local `Secrets.xcconfig`
5. They configure Xcode (step 4 above)

Each developer has their own local `Secrets.xcconfig` that is never committed.

## Production Builds

For App Store releases:

1. Use a separate production API key (if desired)
2. Configure CI/CD to inject the key at build time
3. Store the production key in your CI/CD secrets manager (GitHub Actions, CircleCI, etc.)
4. Never commit production keys to version control

Example GitHub Actions:
```yaml
- name: Configure secrets
  run: |
    echo "FEEDBACK_API_KEY = ${{ secrets.FEEDBACK_API_KEY }}" > Secrets.xcconfig
```
