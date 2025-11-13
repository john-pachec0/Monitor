# Untwist App Store Launch Plan

**Version:** 1.0
**Created:** 2025-11-10
**Target Launch:** 4-5 weeks from start
**Status:** Pre-Launch Development

---

## Executive Summary

Untwist is **remarkably close to App Store launch**. The core CBT functionality is solid, privacy architecture is genuine, and UX is thoughtful. With focused effort on critical items, the app can be submission-ready in 4-5 weeks.

**Current State:**
- ✅ All 13 cognitive distortions with quality educational content
- ✅ Complete feature set (Capture, Review, Worry Box, Learn, Settings)
- ✅ SwiftData persistence working correctly
- ✅ Privacy-first architecture (no analytics, no tracking, all local)
- ✅ Feedback API infrastructure deployed
- ✅ Warm, supportive UX throughout

**Key Blockers:**
1. Privacy policy document (required for submission)
2. App Store screenshots (required for submission)
3. Debug features must be removed
4. User-requested UX improvements (see Priority Fixes below)

**Estimated Effort:** 4-5 weeks with focused development

---

## Priority Fixes (Pre-Launch)

These are user-identified improvements that should be completed before other launch tasks:

### 1. Remove David Burns / "Feeling Good" References
**Priority:** HIGH | **Effort:** 1 hour | **Risk:** Low

**Why:** App is not directly affiliated with David Burns; reference should be generic CBT

**Files to Modify:**

#### File 1: [`Untwist/Features/Onboarding/OnboardingView.swift`](Untwist/Features/Onboarding/OnboardingView.swift#L112-L120)
**Lines 112-120** (WelcomePage)

**Current:**
```swift
VStack(spacing: Theme.Spacing.xs) {
    Text("Based on David Burns'")
        .font(Theme.Typography.subheadline)
        .foregroundColor(Theme.Colors.textSecondary)

    Text("\"Feeling Good\"")
        .font(Theme.Typography.headline)
        .foregroundColor(Theme.Colors.primary)
        .italic()
}
```

**Replace with:**
```swift
Text("Evidence-based CBT techniques")
    .font(Theme.Typography.subheadline)
    .foregroundColor(Theme.Colors.textSecondary)
```

---

#### File 2: [`Untwist/Features/Settings/SettingsView.swift`](Untwist/Features/Settings/SettingsView.swift#L116-L122)
**Lines 116-122** (About section)

**Current:**
```swift
HStack {
    Text("Based on")
    Spacer()
    Text("\"Feeling Good\" by David Burns")
        .foregroundColor(Theme.Colors.textSecondary)
        .multilineTextAlignment(.trailing)
}
```

**Replace with:**
```swift
HStack {
    Text("Framework")
    Spacer()
    Text("Cognitive Behavioral Therapy")
        .foregroundColor(Theme.Colors.textSecondary)
        .multilineTextAlignment(.trailing)
}
```

**Additional Documentation Files** (optional cleanup):
- `README.md` line 5, 207
- `DESIGN.md` line 393
- `REBRAND.md` lines 30, 109, 119, 161, 263
- Other markdown files (internal reference only)

---

### 2. Deprecate Swipe Card Learning System
**Priority:** HIGH | **Effort:** 3-4 hours | **Risk:** Medium

**Why:** Users skip through cards too quickly; interrupts review flow; learning distortions abstractly during worry review is ineffective

**Current Behavior:**
- First 3 thought reviews show "Start Learning Cards" button
- Full-screen Tinder-style swipe interface for all 13 distortions
- Users swipe left (skip) or right (select)
- Takes ~30 seconds to rush through
- Provides "Use Quick List Instead" escape hatch

**Replacement Strategy:**
- **Always use compact distortion list** (already implemented as "fast mode")
- Remove learning mode state and UI
- Keep intelligent distortion ordering (orders by similarity to past thoughts)
- Keep info buttons on each distortion for quick reference
- Learn section remains available for dedicated education

**Files to Modify/Delete:**

#### DELETE: [`Untwist/Features/Review/DistortionLearningCardView.swift`](Untwist/Features/Review/DistortionLearningCardView.swift)
**Lines 1-353** - Entire swipe card UI component
- Remove from project

#### DELETE: [`Untwist/Features/Review/DistortionCardContent.swift`](Untwist/Features/Review/DistortionCardContent.swift)
**Lines 1-162** - Card content with swipe instructions
- Remove from project

#### DELETE: [`Untwist/Features/Review/DistortionLearningViewModel.swift`](Untwist/Features/Review/DistortionLearningViewModel.swift)
**Lines 1-99** - Card stack state management
- Remove from project

#### MODIFY: [`Untwist/Features/Review/ReviewThoughtView.swift`](Untwist/Features/Review/ReviewThoughtView.swift)
**Changes needed:**
1. **Line 25:** Remove `@State private var showLearningMode = false`
2. **Lines 65-67:** Remove `shouldUseLearningMode` computed property
3. **Lines 247-300:** Remove entire learning mode UI block:
   - "Learning Mode Available" section
   - "Start Learning Cards" button
   - "Use Quick List Instead" button
   - `.fullScreenCover` for learning cards
4. **Line 261:** Remove swipe reference text
5. **Lines 303-378:** Keep compact distortion list (this becomes the only mode)
6. Update logic to always show compact list, never learning mode

**Result:**
- ReviewThoughtView always shows compact, intelligent distortion list
- No more swipe interruption
- Cleaner, faster review flow
- Learning section remains for dedicated education

#### CLEANUP: `Untwist.xcodeproj/project.pbxproj`
- Remove file references for deleted files (may auto-update with Tuist)

---

## Week-by-Week Implementation Plan

### Week 1: Priority Fixes + Critical Cleanup
**Focus:** User-requested changes + production readiness

**Tasks:**
1. ✅ Remove David Burns references (1 hour)
   - OnboardingView.swift
   - SettingsView.swift
   - Optional: documentation files

2. ✅ Deprecate swipe card system (3-4 hours)
   - Delete 3 files
   - Refactor ReviewThoughtView.swift
   - Test review flow thoroughly
   - Verify compact list works well

3. ✅ Remove debug features (2 hours)
   - HomeView.swift debug menu (lines 156-188, 203-204)
   - Remove triple-tap handler
   - Test build in Release configuration

4. ✅ Configure production build settings (1 hour)
   - Verify DEBUG preprocessor flags
   - Check all `#if DEBUG` blocks
   - Ensure release builds have no debug code

5. ✅ Verify feedback API production config (1 hour)
   - Test feedback submission end-to-end
   - Verify Secrets.xcconfig properly configured
   - Confirm API key works

**Deliverables:**
- Clean codebase without debug features
- Simplified review flow (no swipe cards)
- Generic CBT branding (no David Burns)
- Working feedback API

---

### Week 2: Legal Requirements + App Store Assets
**Focus:** App Store submission blockers

**Tasks:**
1. ✅ Create Privacy Policy (1-2 days) - **BLOCKER**
   - Write comprehensive privacy policy
   - Cover: no data collection, local storage, feedback API, notifications
   - Hosting: GitHub Pages, personal website, or simple hosting
   - Get URL for App Store Connect

2. ✅ Create Terms of Service / Disclaimer (4 hours)
   - Mental health app disclaimers
   - Based on existing onboarding language
   - "Not a substitute for therapy"
   - Crisis resources reference
   - Host alongside privacy policy

3. ✅ Add privacy links to Settings (30 min)
   - Settings → About section
   - "Privacy Policy" row (opens URL)
   - "Terms of Service" row (opens URL)

4. ✅ Create App Store Screenshots (1 day) - **BLOCKER**
   - 6.7" (iPhone 15 Pro Max)
   - 5.5" (iPhone 8 Plus) if needed
   - Screenshots needed:
     - Home screen (clean, centered message)
     - Capture flow (text input)
     - Review process (distortion selection)
     - Worry Box view (thoughts listed)
     - Learn section (distortion cards)
     - Privacy/security focus screen
   - Use iOS Simulator, clean data, light & dark modes

5. ✅ Write App Store Metadata (4 hours) - **BLOCKER**
   - App name: "Untwist - CBT Thought Journal"
   - Subtitle: "Privacy-first anxiety relief"
   - Description (4000 char max):
     - Privacy-first CBT for anxious thoughts
     - No account, no tracking, all local
     - 13 cognitive distortions
     - Guided reframing process
     - Evidence-based techniques
   - Keywords: CBT, anxiety, cognitive distortions, thought journal, worry journal, mental health, therapy, reframing, privacy
   - Promotional text (170 chars)
   - What's New (4000 chars for future updates)

6. ✅ Verify app icons complete (30 min)
   - Check Assets.xcassets for all required sizes
   - Verify high quality (no pixelation)

**Deliverables:**
- Privacy policy live at URL
- Terms of service live at URL
- Settings links functional
- All screenshots ready
- App Store metadata written
- Icons verified

---

### Week 3: Testing & Quality Assurance
**Focus:** Find and fix bugs before submission

**Tasks:**
1. ✅ Complete manual test pass (2-3 days) - **CRITICAL**
   - Delete app, fresh install
   - Complete onboarding flow
   - Capture first thought
   - Review thought with new compact list (no swipe cards)
   - Add to worry box
   - Review at scheduled time
   - Check all settings (worry time, notifications)
   - Test notifications (schedule, receive, tap to open)
   - Test dark mode consistency throughout app
   - Test landscape orientation (if supported)
   - Test on physical device (not just simulator)
   - Test app backgrounding/foreground transitions
   - Test with no thoughts (empty states)
   - Archive older thoughts
   - Visit Learn section, read distortion details
   - Submit feedback (verify API works)
   - Test with various iPhone sizes

2. ✅ VoiceOver accessibility audit (1 day)
   - Test entire app with VoiceOver enabled
   - Add accessibility labels where needed
   - Verify navigation flow makes sense
   - Test form inputs (capture, review)
   - Test buttons and icons
   - Verify distortion cards readable

3. ✅ Dynamic Type testing (4 hours)
   - Test with largest accessibility text sizes
   - Verify layouts don't break
   - Fix any truncation or overlap issues

4. ✅ Dark mode verification (2 hours)
   - Check every screen in dark mode
   - Verify Theme.Colors used consistently
   - Check for any hardcoded colors
   - Verify contrast ratios (WCAG standards)

5. ✅ Error handling improvements (4 hours)
   - Notification permission denied → show helpful message
   - SwiftData errors → graceful degradation
   - Feedback API failure → already has error handling (verify)
   - Network unavailable → inform user (feedback only)

6. ✅ Fix critical bugs found during testing
   - Track in separate document/issues
   - Prioritize crashes and data loss
   - Defer minor UI glitches to post-launch

**Deliverables:**
- Comprehensive test report
- All critical bugs fixed
- Accessibility compliant
- Dark mode consistent
- Error handling robust

---

### Week 4: UX Polish + Performance
**Focus:** Professional polish and optimization

**Tasks:**
1. ✅ Animation polish (1 day)
   - Review completion celebration (subtle confetti or check animation)
   - Thought card entrance animations in Worry Box
   - Smooth transitions between screens
   - Loading state animations

2. ✅ Loading states verification (2 hours)
   - Feedback submission already has ProgressView ✅
   - Verify all async operations have feedback
   - Check archive loading
   - Check Learn section loading

3. ✅ Empty state verification (2 hours)
   - Worry Box when empty ✅ (already good)
   - Archive when empty (verify)
   - Learn section (should never be empty)
   - No thoughts today (verify helpful message)

4. ✅ Notification content improvement (1 hour)
   - Multiple message variations
   - More warm, encouraging tone
   - Current: "Time to review and reframe your captured thoughts"
   - Options:
     - "Your worry time is here. Ready to review?"
     - "Let's look at today's worries together"
     - "Time to give your thoughts some attention"
   - Rotate messages for variety

5. ✅ Performance profiling (1 day)
   - Use Instruments to check:
     - Memory leaks
     - Launch time
     - SwiftData query performance
     - Pattern matching performance
     - Scroll performance in large lists
   - Optimize any bottlenecks found

6. ✅ Code cleanup (4 hours)
   - Remove unused code
   - Remove commented-out code
   - Add inline documentation for complex logic
   - Verify no TODOs or FIXMEs remain

**Deliverables:**
- Smooth animations throughout
- Fast, responsive app
- No memory leaks
- Clean codebase

---

### Week 5: Final Verification + Submission
**Focus:** Last checks and App Store submission

**Tasks:**
1. ✅ TestFlight beta (optional, 2-3 days)
   - Upload build to App Store Connect
   - Invite 5-10 beta testers (friends, family)
   - Get feedback on real devices
   - Fix any critical issues found

2. ✅ Final QA pass (1 day)
   - Repeat critical test scenarios
   - Verify all Week 1-4 items complete
   - Double-check privacy policy links work
   - Verify feedback API works
   - Test on multiple iOS versions (17.0+)
   - Test on multiple device sizes

3. ✅ App Store submission preparation (4 hours)
   - Upload final build to App Store Connect
   - Fill in all metadata
   - Upload screenshots (all required sizes)
   - Add privacy policy URL
   - Set up App Store Connect account info
   - Choose pricing (free)
   - Select categories (Health & Fitness, Medical)
   - Set age rating (4+ or 9+ likely)
   - Add support URL (feedback page or email)

4. ✅ Submit for review
   - Click "Submit for Review"
   - Respond to any initial automated feedback
   - Wait 24-48 hours for review

5. ✅ Monitor review process
   - Check App Store Connect daily
   - Respond quickly to any questions from Apple
   - Be prepared to make changes if rejected

**Deliverables:**
- App submitted to App Store
- Waiting for approval
- Ready to launch

---

## Critical Launch Checklist

### Production Readiness
- [ ] Debug menu removed (HomeView.swift)
- [ ] All `#if DEBUG` blocks verified
- [ ] Release build configuration tested
- [ ] No development code in production
- [ ] Secrets.xcconfig properly configured
- [ ] Feedback API tested and working

### Legal & Compliance
- [ ] Privacy policy written and hosted
- [ ] Privacy policy URL added to Settings
- [ ] Terms of service written and hosted
- [ ] Terms URL added to Settings
- [ ] Mental health disclaimers in onboarding
- [ ] App Store privacy declarations filled

### App Store Assets
- [ ] App name decided
- [ ] App description written (4000 chars max)
- [ ] Keywords selected
- [ ] Promotional text written (170 chars)
- [ ] Screenshots created (6.7" required, 5.5" if needed)
- [ ] App icons verified (all sizes)
- [ ] Support URL provided
- [ ] Category selected (Health & Fitness)
- [ ] Age rating determined

### Testing & Quality
- [ ] Fresh install onboarding tested
- [ ] Complete user flow tested (Capture → Review → Worry Box)
- [ ] Settings persistence verified
- [ ] Notifications work correctly
- [ ] Dark mode consistent throughout
- [ ] VoiceOver accessible
- [ ] Dynamic Type supported
- [ ] Physical device tested
- [ ] Multiple iPhone sizes tested
- [ ] No critical bugs remain

### UX Polish
- [ ] David Burns references removed
- [ ] Swipe card system deprecated
- [ ] Review flow uses compact list only
- [ ] Animations smooth
- [ ] Loading states present
- [ ] Empty states helpful
- [ ] Error handling graceful
- [ ] No UI glitches

---

## High Priority (Pre-Launch Nice-to-Have)

These items significantly improve the user experience but aren't strict blockers:

### Data Management
**Export Data Feature** - 2 days
- Allow users to export thoughts as JSON or text
- Reinforces privacy commitment
- User control over their data
- Location: Settings → Data → Export Data
- Implementation: Document picker, JSON encoding

**Why important:** Privacy-first apps should allow data export. Shows you respect user's data ownership.

### Accessibility
**Complete VoiceOver audit** - Already in Week 3
**Dynamic Type support** - Already in Week 3

### Archive Enhancement
**Archive polish** - 1 day
- Currently basic list view
- Add grouping by week/month
- Add search/filter
- Add basic stats (total thoughts, anxiety reduction)
- Better empty state

**Why important:** Users who stick with the app will accumulate thoughts; archive should be useful for reflection.

---

## Medium Priority (Post-Launch v1.1)

These can wait until after initial launch:

### Feature Completeness
**Pattern Detection UI** - 2 days
- ThoughtAnalyzer already detects similar thoughts
- Show in UI: "Similar to thoughts from [date]"
- Reference past successful reframes
- Reinforces that worry patterns are common

**CBT Introduction Section** - 1 day
- Educational content about CBT methodology
- Model exists (CBTIntroduction.swift) but not integrated
- Add to Learn section or as optional tutorial

**Import Data** - 2 days
- Counterpart to Export Data
- Allow device migration
- JSON import with validation

### Technical Quality
**Unit Tests** - 1 week
- ThoughtAnalyzer keyword extraction
- ThoughtAnalyzer similarity detection
- SwiftData model operations
- Date/time calculations for scheduling

**UI Tests** - 1 week
- Onboarding → Capture → Review → Worry Box flow
- Settings changes persistence
- Notification scheduling

**Performance Optimization** - Ongoing
- Profile with Instruments regularly
- Optimize SwiftData queries if needed
- Monitor memory usage
- Reduce launch time

### Settings Expansion
**Capture Settings** - 2 hours
- Expand "Rate anxiety at capture" option
- Make it optional vs required
- Custom rating scale (1-5 vs 1-10)

---

## Post-Launch Roadmap

### Version 1.1 (1-2 months post-launch)
**Focus:** User feedback + data management

**Features:**
- Export/Import data
- Archive enhancements (search, stats, grouping)
- Pattern detection UI integration
- Unit test coverage
- Bug fixes from user feedback

**Goals:**
- Respond to App Store reviews
- Fix any crashes reported
- Improve based on feedback

---

### Version 1.2 (3-4 months post-launch)
**Focus:** Insights and analytics (all local)

**Features:**
- Personal insights dashboard
  - Anxiety trend graphs (over time)
  - Most common distortions identified
  - Review completion rate
  - Worry patterns by time/context
- Reframe library
  - Save favorite reframes
  - Quick reference for similar situations
- Performance optimizations
- Code documentation

**Goals:**
- Help users see their progress
- Provide motivation through insights
- All processing remains local

---

### Version 2.0 (6+ months post-launch)
**Focus:** Platform expansion and integration

**Features:**
- Apple Watch companion app
  - Quick thought capture on wrist
  - Review reminders
  - Complication showing worry time
- Health app integration
  - Log "Mindful Minutes" after review sessions
  - Export anxiety ratings to Health
- Siri Shortcuts support
  - "Capture a worry"
  - "Review my thoughts"
- Advanced analytics
  - ML-powered pattern recognition (on-device)
  - Personalized distortion suggestions
  - Reframe effectiveness tracking

**Goals:**
- Deeper iOS ecosystem integration
- More convenient capture
- Advanced insights while maintaining privacy

---

### Future Considerations (12+ months)
**Explore carefully:**

**Gamification** (with caution)
- Streaks and achievements
- Must be encouraging, not shame-inducing
- Examples: "7 days of worry time", "10 thoughts reframed"
- Risk: Can backfire with mental health apps

**Community Features** (privacy-first)
- Anonymous pattern sharing (opt-in)
- Aggregated insights from community
- No personal data shared
- Complex privacy engineering required

**Professional Integration**
- Therapist dashboard (separate app?)
- Allow patients to share progress with therapist (opt-in)
- Export reports for therapy sessions
- HIPAA considerations

---

## Risk Assessment

### HIGH RISK - Address Immediately

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| Debug features in production | App Store rejection | Remove all debug UI and code | Week 1 |
| No privacy policy | Cannot submit to App Store | Create and host privacy policy | Week 2 |
| Missing screenshots | Cannot submit to App Store | Create all required sizes | Week 2 |
| David Burns reference | Potential legal/branding issue | Remove references, use generic CBT | Week 1 |
| Swipe cards frustrate users | Poor reviews, low retention | Deprecate swipe system | Week 1 |

### MEDIUM RISK - Monitor

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| Critical bugs undiscovered | Poor user experience, crashes | Comprehensive testing in Week 3 | Week 3 |
| Poor App Store screenshots | Low conversion rate | High-quality, compelling screenshots | Week 2 |
| Accessibility issues | Negative reviews, violations | VoiceOver and Dynamic Type testing | Week 3 |
| Performance problems at scale | User frustration | Profile with Instruments | Week 4 |
| Notification permission denied | Core feature unavailable | Graceful handling, explain value | Week 3 |

### LOW RISK - Not Urgent

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| Limited test coverage | Future regressions | Add tests post-launch | Post-launch |
| No data export | User complaints | Add in v1.1 | Post-launch |
| Archive features limited | Power users disappointed | Enhance in v1.2 | Post-launch |

---

## Success Criteria

### Pre-Launch Success
- ✅ All critical checklist items complete
- ✅ App successfully submitted to App Store
- ✅ No critical bugs in submitted build
- ✅ Privacy policy live and accessible
- ✅ Screenshots compelling and accurate

### Launch Success (First 30 Days)
- 🎯 App approved by Apple (within 1-2 weeks)
- 🎯 Zero critical crashes (crash-free rate > 99%)
- 🎯 Average rating ≥ 4.0 stars
- 🎯 50+ downloads from organic search
- 🎯 5+ reviews mentioning privacy or CBT effectiveness
- 🎯 No negative reviews about removed swipe cards

### Growth Success (First 90 Days)
- 🎯 200+ total downloads
- 🎯 Average rating ≥ 4.5 stars
- 🎯 20+ reviews
- 🎯 Retention: 40%+ users open app 3+ times in first week
- 🎯 No App Store review violations
- 🎯 Feature requests informing v1.1 roadmap

---

## Launch Day Checklist

When Apple approves the app:

### Before Making Live
- [ ] Double-check all metadata is correct
- [ ] Verify screenshots look good
- [ ] Privacy policy URL working
- [ ] Support email/URL working
- [ ] Test feedback API one more time

### Launch Actions
- [ ] Set app to "Ready for Sale" in App Store Connect
- [ ] Monitor for immediate crash reports
- [ ] Check reviews daily (first week)
- [ ] Respond to user feedback promptly
- [ ] Share on social media (if desired)
- [ ] Post to relevant communities (r/cbt, mental health forums)
- [ ] Ask friends/family for reviews (honest ones!)

### Post-Launch Monitoring (First Week)
- [ ] Daily crash rate check (should be < 1%)
- [ ] Daily review monitoring
- [ ] Daily feedback form checks (admin dashboard)
- [ ] Response to any critical issues within 24 hours
- [ ] Begin collecting feature requests for v1.1

---

## Notes & Decisions

### Design Decisions Made
1. **Removed swipe cards** - Users rushed through them; better to show compact list
2. **Removed David Burns reference** - App is generic CBT, not affiliated
3. **Privacy-first architecture** - No analytics, tracking, or accounts
4. **Warm color palette** - Terracotta, peach, calm neutrals
5. **Local notifications only** - Optional, user-controlled scheduling

### Technical Decisions Made
1. **SwiftUI + SwiftData** - Modern iOS development, iOS 17+
2. **No cloud sync** - Privacy commitment, simpler architecture
3. **Feedback via API** - Only outbound user data (optional)
4. **Pattern matching local** - ThoughtAnalyzer processes on-device
5. **Tuist for project management** - Auto-detects new files

### Business Decisions Made
1. **Free app** - No in-app purchases, no ads, no monetization (for now)
2. **No user accounts** - Privacy, simplicity
3. **Health & Fitness category** - Primary category for discovery
4. **4+ age rating** - Appropriate for general use (verify with Apple)

### Open Questions
- [ ] Should we add in-app purchases later? (Pro version with insights?)
- [ ] Should we create a landing page / website?
- [ ] Should we do PR outreach to mental health publications?
- [ ] Should we apply for "App Store Feature" consideration?
- [ ] Should we integrate with HealthKit in v2.0?

---

## Resources & Links

### Development
- **Project:** `/Users/japacheco/ios-development/Untwist`
- **Tuist Config:** `Project.swift`
- **Secrets:** `Secrets.xcconfig` (not in git)
- **Feedback API:** `https://api.untwist.app`
- **Admin Dashboard:** `admin-dashboard.html`

### Documentation
- **Architecture:** `ARCHITECTURE.md`
- **Setup:** `README.md`
- **Secrets Setup:** `SETUP_SECRETS.md`

### App Store Connect
- **Developer Account:** [Apple Developer Portal](https://developer.apple.com)
- **App Store Connect:** [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

### Testing
- **TestFlight:** Via App Store Connect
- **Simulator:** iPhone 15 Pro Max (6.7"), iPhone 8 Plus (5.5")
- **Physical Device:** Test before submission

### Support
- **Feedback Form:** In-app Settings → Send Feedback
- **Admin Dashboard:** View feedback submissions
- **GitHub Issues:** Track bugs and feature requests (if public repo)

---

## Appendix: Detailed File Change List

### Week 1: Priority Fixes

**Remove David Burns References:**
1. `Untwist/Features/Onboarding/OnboardingView.swift:112-120`
2. `Untwist/Features/Settings/SettingsView.swift:116-122`

**Deprecate Swipe Cards:**
1. DELETE: `Untwist/Features/Review/DistortionLearningCardView.swift`
2. DELETE: `Untwist/Features/Review/DistortionCardContent.swift`
3. DELETE: `Untwist/Features/Review/DistortionLearningViewModel.swift`
4. MODIFY: `Untwist/Features/Review/ReviewThoughtView.swift:25,65-67,247-300`

**Remove Debug Features:**
1. `Untwist/Features/Home/HomeView.swift:156-188,203-204`

### Week 2: Legal + Assets

**Add Privacy Links:**
1. `Untwist/Features/Settings/SettingsView.swift` (add two new rows in About section)

**Assets to Create:**
- Privacy policy document (host externally)
- Terms of service document (host externally)
- 6.7" screenshots (6-8 images)
- 5.5" screenshots (6-8 images, if needed)
- App Store description text
- App Store keywords list
- App Store promotional text

### Week 3-5: Testing + Polish

**Files to Test Thoroughly:**
- All features end-to-end
- All settings persistence
- All navigation flows
- All accessibility labels
- All color themes (light/dark)

**Performance to Profile:**
- Launch time
- SwiftData queries
- Pattern matching
- Scroll performance
- Memory usage

---

## Contact & Support

**Developer:** John Pacheco
**Email:** [Your support email]
**Feedback API:** https://api.untwist.app

---

**Last Updated:** 2025-11-10
**Next Review:** After Week 1 completion
**Status:** Ready to begin Week 1 implementation

---

*This document is a living plan. Update status, add notes, and track progress as you work through each week. Good luck with the launch! 🚀*
