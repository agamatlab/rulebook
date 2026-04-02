# Fastlane Match Setup Guide

## What You'll Be Asked and How to Respond

When you run `bundle exec fastlane match appstore`, here's what you'll be prompted for:

### 1. Git URL for Certificates Repository
**Question:** "URL to the git repo containing all the certificates"
**Answer:** `https://github.com/agamatlab/rulebook-certificates`

This is the private repository we already created for storing your certificates.

### 2. Passphrase for Encrypting Certificates
**Question:** "Passphrase for Git Repo"
**Answer:** Create a strong passphrase (you'll need to remember this!)

**Example:** `RuleBook2026SecurePass!`

**IMPORTANT:** 
- Write this down somewhere safe
- You'll need it every time you run match
- Don't share it with anyone
- Store it in a password manager

### 3. Apple ID
**Question:** "Apple ID Username"
**Answer:** `aghamatlabakberzade@gmail.com`

This is already configured in your Appfile, so it might not ask.

### 4. App Store Connect Password
**Question:** "Password for Apple ID"
**Answer:** Your Apple ID password

**Alternative:** Use App Store Connect API Key (recommended)

### 5. Two-Factor Authentication Code
**Question:** "Please enter the 6 digit code"
**Answer:** Enter the 6-digit code from your iPhone/trusted device

This will appear on your Apple devices when you authenticate.

## Complete Command Sequence

```bash
cd /Users/aghamatlabakbarzade/ms/swift/rulebook/rulebook
bundle exec fastlane match appstore
```

### Expected Flow:

```
[fastlane] 🚀 
[fastlane] URL to the git repo containing all the certificates
> https://github.com/agamatlab/rulebook-certificates

[fastlane] Passphrase for Git Repo (leave empty to skip):
> [Enter your secure passphrase]

[fastlane] Confirm passphrase:
> [Enter same passphrase again]

[fastlane] Please enter your Apple ID:
> aghamatlabakberzade@gmail.com

[fastlane] Please enter your password:
> [Your Apple ID password]

[fastlane] Two-factor authentication is enabled
[fastlane] Please enter the 6 digit code:
> [Code from your device]

[fastlane] Creating certificate and provisioning profile...
[fastlane] ✅ Successfully created certificates
```

## Quick Reference Card

Copy this for easy reference:

```
Git URL: https://github.com/agamatlab/rulebook-certificates
Passphrase: [CREATE A STRONG ONE - WRITE IT DOWN]
Apple ID: aghamatlabakberzade@gmail.com
Password: [Your Apple ID password]
2FA Code: [From your iPhone/device]
```

## Alternative: Use App Store Connect API Key (Recommended)

Instead of entering password every time, you can use an API key:

### Step 1: Create API Key
1. Go to https://appstoreconnect.apple.com
2. Click "Users and Access"
3. Click "Keys" tab
4. Click "+" to create new key
5. Name it "Fastlane RuleBook"
6. Select "Admin" or "App Manager" role
7. Click "Generate"
8. Download the .p8 file

### Step 2: Save API Key
```bash
# Save the downloaded file to fastlane directory
mv ~/Downloads/AuthKey_*.p8 /Users/aghamatlabakbarzade/ms/swift/rulebook/rulebook/fastlane/
```

### Step 3: Update Appfile
Add these lines to your Appfile:

```ruby
app_store_connect_api_key(
  key_id: "YOUR_KEY_ID",
  issuer_id: "YOUR_ISSUER_ID",
  key_filepath: "./fastlane/AuthKey_YOUR_KEY_ID.p8"
)
```

**Where to find these:**
- Key ID: Shown when you create the key (e.g., "ABC123XYZ")
- Issuer ID: At the top of the Keys page (UUID format)

## Troubleshooting

### If Git Authentication Fails
```bash
# Make sure you're authenticated with GitHub
gh auth status

# If not authenticated:
gh auth login
```

### If Certificate Creation Fails
- Make sure you have Admin role in Apple Developer account
- Check that Bundle ID (com.rulebook.app) exists in Apple Developer Portal
- Verify Team ID is correct: 3NFUYR892M

### If 2FA Code Doesn't Work
- Wait for new code (they expire quickly)
- Make sure you're entering it immediately
- Check that your Apple ID has 2FA enabled

## What Match Will Create

After successful run, match will:
1. Generate App Store distribution certificate
2. Create App Store provisioning profile
3. Encrypt and store them in GitHub repo
4. Install them on your Mac
5. Configure Xcode to use them

## Next Time You Run Match

You'll only need:
- Git URL (same)
- Passphrase (same one you created)

No Apple ID password needed if using API key!

## Security Notes

✅ DO:
- Use a strong, unique passphrase
- Store passphrase in password manager
- Keep API key file secure
- Use API key instead of password

❌ DON'T:
- Share your passphrase
- Commit API key to public repos
- Use simple passwords
- Share certificates manually

---

**Ready to run?**

```bash
cd /Users/aghamatlabakbarzade/ms/swift/rulebook/rulebook
bundle exec fastlane match appstore
```

Just answer the prompts with the information above!
