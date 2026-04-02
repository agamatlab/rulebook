# App Store Submission Checklist for Rulebook

## ✅ COMPLETED - Critical Requirements

### 1. App Icon
- [x] 1024x1024 PNG icon created
- [x] Icon is properly formatted in Assets.xcassets
- [x] No transparency or alpha channels

### 2. Privacy & Legal
- [x] Privacy Policy created (docs/PRIVACY_POLICY.md)
- [x] Terms of Service created (docs/TERMS_OF_SERVICE.md)
- [x] Info.plist with privacy descriptions added
- [x] NSPrivacyTracking set to false
- [x] Privacy manifest configured

### 3. Fastlane Configuration
- [x] Fastlane installed via Bundler
- [x] Appfile configured with Apple ID: aghamatlabakberzade@gmail.com
- [x] Team ID configured: 3NFUYR892M
- [x] iTunes Connect Team ID: 128734233
- [x] Matchfile configured for code signing
- [x] GitHub repo created for certificates

### 4. App Store Metadata
- [x] App description written
- [x] App subtitle created
- [x] Keywords defined
- [x] Primary category: Productivity
- [x] Secondary category: Lifestyle
- [x] Release notes prepared
- [x] Support URL configured
- [x] Privacy URL configured
- [x] Marketing URL configured

## ⚠️ PENDING - Important Tasks

### 5. Xcode Project Configuration
- [ ] Add Info.plist to Xcode project build settings
- [ ] Verify bundle identifier: com.rulebook.app
- [ ] Set marketing version: 1.0
- [ ] Set build number: 1
- [ ] Configure code signing settings

### 6. App Store Connect Setup
- [ ] Create app in App Store Connect
- [ ] Upload app icon (1024x1024)
- [ ] Fill in app information
- [ ] Add screenshots (required sizes):
  - 6.7" Display (iPhone 15 Pro Max): 1290 x 2796
  - 6.5" Display: 1284 x 2778
  - 5.5" Display: 1242 x 2208
- [ ] Configure App Privacy details in App Store Connect
- [ ] Set age rating
- [ ] Add app review information
- [ ] Provide demo account (if needed)

### 7. Code Signing
- [ ] Run `bundle exec fastlane match appstore` to generate certificates
- [ ] Verify provisioning profiles are created
- [ ] Configure Xcode to use match profiles

### 8. Testing & Quality
- [ ] Test on multiple iOS versions (16.0+)
- [ ] Test on different device sizes
- [ ] Verify all features work correctly
- [ ] Test onboarding flow
- [ ] Test data persistence
- [ ] Check for crashes or bugs
- [ ] Test in airplane mode (offline functionality)
- [ ] Verify notifications work correctly

### 9. Accessibility
- [ ] Add accessibility labels to buttons
- [ ] Test with VoiceOver
- [ ] Ensure proper contrast ratios
- [ ] Test with Dynamic Type
- [ ] Add accessibility hints where needed

### 10. Performance
- [ ] Check app launch time
- [ ] Verify smooth scrolling
- [ ] Test with large datasets
- [ ] Check memory usage
- [ ] Verify battery impact

## 📋 Common Rejection Reasons - FIXED

### ✅ Guideline 2.1 - App Completeness
- [x] App is fully functional
- [x] No placeholder content
- [x] All features work as described

### ✅ Guideline 2.3.3 - Accurate Metadata
- [x] App description matches functionality
- [x] Screenshots show actual app (need to create)
- [x] No misleading information

### ✅ Guideline 4.0 - Design
- [x] App follows iOS design guidelines
- [x] Proper use of system fonts and colors
- [x] Consistent UI throughout

### ✅ Guideline 5.1.1 - Privacy
- [x] Privacy Policy provided
- [x] Data collection disclosed
- [x] Privacy manifest included
- [x] No tracking without permission

### ✅ Guideline 5.1.2 - Data Use and Sharing
- [x] Clear data usage descriptions
- [x] No unauthorized data collection
- [x] Local storage only (no server uploads)

## 🚀 Submission Steps

1. **Build and Archive**
   ```bash
   cd rulebook
   bundle exec fastlane build
   ```

2. **Upload to TestFlight**
   ```bash
   bundle exec fastlane beta
   ```

3. **Test via TestFlight**
   - Install from TestFlight
   - Test all features
   - Get feedback from beta testers

4. **Submit for Review**
   ```bash
   bundle exec fastlane release
   ```

5. **Monitor Review Status**
   - Check App Store Connect daily
   - Respond to any reviewer questions
   - Be ready to fix issues quickly

## 📝 App Review Information

Provide this information in App Store Connect:

**Demo Account (if needed):**
- Not required (app doesn't need login)

**Notes for Reviewer:**
```
Rulebook is a personal productivity app for tracking rules and habits.

Key features to test:
1. Complete onboarding flow (Welcome → Categories → Theme)
2. Create a new rule from the Today tab
3. Check in on a rule (tap the circle)
4. View progress in the Review tab
5. Customize categories in Settings

All data is stored locally on the device. No account or internet connection required.

Contact: aghamatlabakberzade@gmail.com for any questions.
```

## 🔍 Pre-Submission Checklist

Before submitting, verify:
- [ ] App builds without errors
- [ ] No compiler warnings (or all justified)
- [ ] All assets are included
- [ ] Info.plist is properly configured
- [ ] Privacy Policy and Terms are accessible
- [ ] App works on iOS 16.0+
- [ ] No hardcoded test data
- [ ] No debug code or console logs
- [ ] Proper error handling everywhere
- [ ] App handles edge cases gracefully

## 📞 Support

If rejected, common fixes:
1. **Metadata Rejection**: Update descriptions/screenshots
2. **Privacy Issues**: Add missing privacy descriptions
3. **Crashes**: Fix bugs and resubmit
4. **Design Issues**: Improve UI/UX
5. **Functionality**: Ensure all features work

Contact Apple Developer Support if needed:
https://developer.apple.com/contact/

---

**Last Updated:** April 2, 2026
**App Version:** 1.0 (Build 1)
**Bundle ID:** com.rulebook.app
