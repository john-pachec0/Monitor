# Untwist - CBT Thought Reframing App

A minimal vertical slice implementation of a CBT-based iOS app for capturing and untwisting anxious thoughts.

Based on David Burns' "Feeling Good" framework - untwist cognitive distortions and find balanced perspectives.

## What's Built (MVP)

✅ **Core Flow Working:**
1. Capture anxious thoughts (text input)
2. Review thoughts with guided CBT process
3. Identify cognitive distortions
4. Create reframes
5. Track emotion changes before/after
6. View thought history

## Project Structure

```
Untwist/
├── UntwistApp.swift                 # App entry point
├── Models/
│   └── AnxiousThought.swift        # Core data model + cognitive distortions
├── Core/
│   └── Theme.swift                 # Warm color palette, typography, spacing
├── Features/
│   ├── Home/
│   │   └── HomeView.swift          # Main screen with thought list
│   ├── Capture/
│   │   └── CaptureThoughtView.swift # Quick thought capture
│   └── Review/
│       └── ReviewThoughtView.swift  # Guided CBT review session
```

## Tech Stack

- **iOS 17+** (SwiftUI + SwiftData)
- **SwiftData** for local-first persistence
- **@Observable** for state management
- **No third-party dependencies**

## Setup Instructions

### 1. Create Xcode Project
```
1. Open Xcode
2. Create New Project → iOS → App
3. Product Name: Untwist
4. Interface: SwiftUI
5. Storage: SwiftData (IMPORTANT!)
6. Language: Swift
```

### 2. Add Files
Copy the files from the Untwist/ directory into your Xcode project, maintaining the folder structure.

### 3. File Organization in Xcode
Organize files into groups matching the folder structure:
- Models/
- Core/
- Features/Home/
- Features/Capture/
- Features/Review/

### 4. Update UntwistApp.swift
Replace the default app file with our UntwistApp.swift

### 5. Build and Run
- Select iPhone 15 Pro simulator (or any iOS 17+ device)
- Cmd+R to build and run

## Testing the Flow

### First Launch:
1. You'll see empty state with "Welcome to Untwist"
2. Tap "Capture Your First Thought" or the + button

### Capture a Thought:
1. Type an anxious thought (e.g., "I'm going to fail this presentation")
2. Tap "Save Thought"
3. Returns to home - you'll see 1 unreviewed thought

### Review the Thought:
1. Tap the thought card
2. Walk through the guided review:
   - **Step 1**: Read your thought
   - **Step 2**: Rate anxiety (1-10 slider)
   - **Step 3**: Select distortions (optional, tap info icons for details)
   - **Step 4**: Write a reframe
   - **Step 5**: Rate anxiety again
   - **Step 6**: See completion screen
3. Tap "Done" to return home

### View History:
- Home screen shows all thoughts
- Green checkmark = reviewed
- Orange dot = needs review
- Tap any thought to review/edit

## What Works

✅ Thought capture (fast, < 5 seconds)
✅ Guided review with 5-step process
✅ 5 cognitive distortions with descriptions + examples
✅ Reframe editor
✅ Emotion tracking (before/after comparison)
✅ Thought history (all in one list)
✅ Local persistence (data survives app restart)
✅ Warm, supportive design aesthetic

## What's NOT Built Yet (Intentionally)

❌ Pattern detection
❌ Similar thought matching
❌ Weekly insights
❌ Notifications for review time
❌ Export functionality
❌ Settings screen
❌ Onboarding flow
❌ Voice input
❌ Widget
❌ iPad optimization

## Design Philosophy

### Privacy-First
- All data stored locally (SwiftData)
- No network calls
- No analytics
- No user accounts

### Warm & Supportive
- Warm color palette (terracotta, peach, warm neutrals)
- Rounded fonts (San Francisco Rounded)
- Encouraging copy, never judgmental
- "Let's look at this together" tone

### Fast Capture
- Minimal friction to capture thoughts
- Auto-focus text field
- No required fields except the thought itself
- Sheet presentation (easy to dismiss)

### Guided Process
- Step-by-step review (not overwhelming)
- Progress bar shows where you are
- Can go back if needed
- Educational (explains distortions)

## Next Steps (Phase 2)

Once this feels right:
1. **Pattern Recognition**: Show similar past thoughts
2. **Suggested Reframes**: ML-powered suggestions based on your history
3. **Weekly Insights**: "You're catastrophizing less this week"
4. **Scheduled Review Time**: Optional daily notification
5. **Onboarding**: Brief intro to CBT concepts
6. **Settings**: Customize review time, notifications, etc.

## Known Issues / TODOs

- [ ] Add haptic feedback on actions
- [ ] Improve empty state for distortions (when none selected)
- [ ] Add confirmation before leaving unsaved reframe
- [ ] Better keyboard handling in reframe editor
- [ ] Accessibility audit (VoiceOver labels)
- [ ] Dynamic Type support testing
- [ ] Dark mode testing/refinement

## Design Decisions

**Why SwiftData?**
- Modern, SwiftUI-native
- Local-first by default (privacy)
- Automatic persistence
- Easy to query and filter

**Why no backend?**
- MVP doesn't need it
- Privacy concerns with mental health data
- Simpler architecture
- Faster to build

**Why 5 distortions not 10?**
- Reduce cognitive load for beginners
- These 5 are most common
- Can add more later
- Easier to understand and remember

**Why step-by-step review?**
- Less overwhelming than one big form
- Teaches the process gradually
- Clear progress indication
- Easier to maintain focus

## Contribution Notes

When adding features:
1. Maintain warm, supportive tone in all copy
2. Keep capture flow FAST (< 5 seconds)
3. Privacy-first (local data only)
4. Accessibility (VoiceOver, Dynamic Type)
5. Test with real anxious thoughts (they're often long!)

## Resources

- David Burns' "Feeling Good" (CBT framework we're using)
- Cognitive Distortions: https://psychcentral.com/lib/cognitive-distortions-negative-thinking
- iOS Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

---

**Status**: ✅ Vertical Slice Complete - Ready for Testing & Feedback
