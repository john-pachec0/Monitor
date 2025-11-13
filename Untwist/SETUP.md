# Setup Checklist & Screen Flow

## Pre-Build Checklist

Before you start, make sure you have:

- [ ] Xcode 15.0 or later
- [ ] macOS Sonoma or later
- [ ] iOS 17+ Simulator or device

## Project Setup Steps

### 1. Create Project in Xcode
```
File → New → Project
Choose: iOS → App
Settings:
  - Product Name: Untwist
  - Team: Your team
  - Organization Identifier: com.yourname.untwist
  - Interface: SwiftUI
  - Storage: SwiftData ⚠️ IMPORTANT!
  - Language: Swift
  - Include Tests: Yes (optional)
```

### 2. File Integration

Copy files from `/home/claude/Untwist/` to your Xcode project:

**Root Level:**
- [ ] UntwistApp.swift (replace default App file)
- [ ] README.md (for reference)

**Create Groups in Xcode (right-click project → New Group):**

**Models/** 
- [ ] AnxiousThought.swift

**Core/**
- [ ] Theme.swift

**Features/Home/**
- [ ] HomeView.swift

**Features/Capture/**
- [ ] CaptureThoughtView.swift

**Features/Review/**
- [ ] ReviewThoughtView.swift

### 3. Verify SwiftData Setup

In your project settings:
- [ ] Target → Signing & Capabilities
- [ ] Ensure "SwiftData" is enabled (should be automatic if you selected it during creation)

### 4. Build Settings

Minimum deployment target:
- [ ] Target → General → Minimum Deployments → iOS 17.0

### 5. First Build

- [ ] Select iPhone 15 Pro simulator
- [ ] Press Cmd+B to build
- [ ] Fix any import errors (all files should compile cleanly)
- [ ] Press Cmd+R to run

---

## Screen Flow Overview

### Home Screen (HomeView.swift)

```
┌─────────────────────────────────────┐
│  < Untwist                      [+] │ ← Navigation bar
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 💡 2 thoughts to review     │   │ ← Status card (if unreviewed)
│  │ Take a moment to reframe... │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ I'm going to fail this...   │ 🔴│ ← Unreviewed thought (red dot)
│  │ Nov 6, 2:30 PM              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Everyone will judge me...   │ ✓ │ ← Reviewed thought (checkmark)
│  │ Nov 5, 9:15 AM     Reviewed │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘

Empty State:
┌─────────────────────────────────────┐
│          🧠                          │
│    Welcome to Untwist               │
│                                     │
│  When an anxious thought arises,   │
│  capture it here...                │
│                                     │
│  [Capture Your First Thought]      │
└─────────────────────────────────────┘
```

**Interactions:**
- Tap [+] → Opens Capture Sheet
- Tap thought card → Opens Review Screen
- Pull to refresh (not implemented yet)

---

### Capture Screen (CaptureThoughtView.swift)

```
┌─────────────────────────────────────┐
│  Cancel  Capture Thought            │ ← Sheet presentation
├─────────────────────────────────────┤
│                                     │
│  What's on your mind?               │
│  Write down the anxious thought.    │
│  We'll look at it together later.   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ [Text input area]           │   │ ← Auto-focused
│  │                             │   │
│  │ e.g., "I'm going to fail    │   │
│  │ this presentation..."       │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Save Thought           │   │ ← Disabled if empty
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Interactions:**
- Type thought → Enable save button
- Tap "Save Thought" → Saves + dismisses
- Tap "Cancel" → Dismisses without saving

---

### Review Screen (ReviewThoughtView.swift)

**Step 1: Read Thought**
```
┌─────────────────────────────────────┐
│  < Back                             │
├─────────────────────────────────────┤
│  ▓▓▓▓▓░░░░░  Progress (1/5)         │ ← Progress bar
│                                     │
│       Your Thought                  │
│  Let's look at this together.       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ I'm going to fail this      │   │
│  │ presentation and everyone   │   │ ← Original thought
│  │ will think I'm incompetent. │   │
│  └─────────────────────────────┘   │
│                                     │
│  Take a moment to read this.        │
│  Notice how it makes you feel.      │
│                                     │
│         [Continue]                  │
└─────────────────────────────────────┘
```

**Step 2: Rate Emotion Before**
```
┌─────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓░░  Progress (2/5)         │
│                                     │
│      How Anxious?                   │
│  How anxious does this thought      │
│  make you feel?                     │
│                                     │
│          8                          │ ← Big number
│                                     │
│  ├─────●──────────┤                 │ ← Slider (1-10)
│  Calm        Very Anxious           │
│                                     │
│  [Back]      [Continue]             │
└─────────────────────────────────────┘
```

**Step 3: Identify Distortions**
```
┌─────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓░  Progress (3/5)       │
│                                     │
│    Notice Distortions               │
│  Do any of these thinking patterns  │
│  sound familiar?                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ✓ All-or-Nothing Thinking  ℹ│   │ ← Selected
│  │   Seeing things in black... │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ○ Catastrophizing          ℹ│   │ ← Not selected
│  │   Expecting the worst...    │   │
│  └─────────────────────────────┘   │
│                                     │
│  [... 3 more distortions]           │
│                                     │
│  Tap any that apply, or skip if     │
│  none fit                           │
│                                     │
│  [Back]      [Continue]             │
└─────────────────────────────────────┘
```

**Step 4: Create Reframe**
```
┌─────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░  Progress (4/5)    │
│                                     │
│       Reframe It                    │
│  What's a more balanced way to      │
│  see this situation?                │
│                                     │
│  Distortions you noticed:           │
│  • All-or-Nothing Thinking          │
│  • Catastrophizing                  │
│                                     │
│  Original thought:                  │
│  I'm going to fail this...          │
│                                     │
│  More balanced thought:             │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ [Text editor]               │   │ ← User writes reframe
│  │                             │   │
│  │ I might struggle with parts │   │
│  │ but I'm prepared and that's │   │
│  │ what matters...             │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Back]      [Continue]             │
└─────────────────────────────────────┘
```

**Step 5: Rate Emotion After**
```
┌─────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  Progress (5/5) │
│                                     │
│   How Do You Feel Now?              │
│  After reframing, how do you feel?  │
│                                     │
│          4                          │ ← Lower number!
│                                     │
│  ├────●──────────────┤              │
│  Calm        Very Anxious           │
│                                     │
│  [Back]      [Continue]             │
└─────────────────────────────────────┘
```

**Step 6: Complete**
```
┌─────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  Complete      │
│                                     │
│          ✓                          │ ← Big checkmark
│                                     │
│   Thought Reviewed!                 │
│                                     │
│  Your anxiety decreased by          │
│  4 points                           │ ← Improvement shown
│                                     │
│  You're building the skill of       │
│  noticing and reframing distorted   │
│  thoughts. Each time you practice,  │
│  it gets easier.                    │
│                                     │
│           [Done]                    │
└─────────────────────────────────────┘
```

---

## Distortion Info Sheet

When user taps ℹ️ on any distortion:

```
┌─────────────────────────────────────┐
│  Close                              │
├─────────────────────────────────────┤
│                                     │
│  All-or-Nothing Thinking            │
│                                     │
│  What it is:                        │
│  ┌─────────────────────────────┐   │
│  │ Seeing things in black and  │   │
│  │ white categories. If        │   │
│  │ something isn't perfect...  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Example:                           │
│  ┌─────────────────────────────┐   │
│  │ "I made one mistake in my   │   │
│  │ presentation, so the whole  │   │
│  │ thing was a disaster."      │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## Testing Scenarios

### Happy Path
1. Launch app → See empty state
2. Tap "Capture Your First Thought"
3. Type: "I'm terrible at my job"
4. Save
5. See thought in list with red dot
6. Tap thought
7. Go through all 5 review steps
8. Complete
9. Return to home → Thought now has green checkmark

### Edge Cases to Test
- [ ] Capture with very long thought (should scroll)
- [ ] Capture and immediately cancel
- [ ] Start review, tap Back multiple times
- [ ] Select multiple distortions
- [ ] Select no distortions
- [ ] Skip reframe (should not be possible - Continue disabled)
- [ ] Rotate device during review (should maintain state)
- [ ] Close app during review, reopen (thought should still be unreviewed)
- [ ] Review same thought multiple times (should show existing data)

### Data Persistence Tests
- [ ] Add 3 thoughts
- [ ] Force quit app (swipe up in app switcher)
- [ ] Relaunch → All 3 thoughts should still be there
- [ ] Review 1 thought
- [ ] Force quit again
- [ ] Relaunch → Should show 2 unreviewed, 1 reviewed

---

## Common Build Issues & Fixes

**Issue**: "Cannot find 'AnxiousThought' in scope"
- **Fix**: Make sure AnxiousThought.swift is added to your target (check File Inspector)

**Issue**: "Cannot find type 'Theme' in scope"  
- **Fix**: Make sure Theme.swift is added to your target

**Issue**: SwiftData errors
- **Fix**: Ensure you selected SwiftData when creating project. If not, add SwiftData framework manually in Target → Frameworks & Libraries

**Issue**: Preview crashes
- **Fix**: Previews use in-memory model container. They should work, but if not, run on simulator instead.

**Issue**: Keyboard covers text field
- **Fix**: SwiftUI handles this automatically, but if not, add `.scrollDismissesKeyboard(.interactively)` to ScrollView

---

## Next Actions After Testing

Once you've tested the vertical slice:

1. **Gather Feedback**
   - Does the flow feel right?
   - Is capture fast enough?
   - Is review too long or just right?
   - Does the tone feel supportive?

2. **Refine Based on Feel**
   - Adjust copy if needed
   - Tweak colors if too warm/not warm enough
   - Speed up or slow down animations

3. **Then Add**
   - Onboarding (brief intro to CBT)
   - Pattern detection (similar thoughts)
   - Weekly insights
   - Settings

---

**Ready to build? Follow the checklist above and you'll have a working app in ~15 minutes!**
