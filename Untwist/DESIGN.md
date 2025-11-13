# Design Reference - Warm Aesthetic

## Color Palette

### Primary Colors (Warm Terracotta)
```
Primary:       #D18562  rgb(209, 133, 98)  ← Main brand color
Primary Light: #F2D9C7  rgb(242, 217, 199) ← Backgrounds, highlights  
Primary Dark:  #A65940  rgb(166, 89, 64)   ← Pressed states, emphasis
```

**Usage**: Buttons, accents, focus states, progress indicators

### Background Colors (Warm Neutrals)
```
Background:           #FAF8F2  rgb(250, 248, 242) ← Main screen background
Card Background:      #FFFFFF  rgb(255, 255, 255) ← Cards, inputs
Secondary Background: #F5F0E6  rgb(245, 240, 230) ← Subtle sections
```

**Usage**: Layered backgrounds for depth

### Text Colors (Warm Grays)
```
Text Primary:   #332E2B  rgb(51, 46, 43)    ← Headlines, body text
Text Secondary: #8C8480  rgb(140, 132, 128) ← Descriptions, labels
Text Tertiary:  #B3ADA6  rgb(179, 173, 166) ← Placeholders, hints
```

**Usage**: Hierarchy of importance

### Semantic Colors (Muted)
```
Success: #9AB89A  rgb(154, 184, 154) ← Reviewed checkmarks
Warning: #E6BF73  rgb(230, 191, 115) ← Warnings (if needed)
Error:   #D97366  rgb(217, 115, 102) ← Errors (rare)
```

**Usage**: Status indicators

### Distortion Colors (Subtle Differentiation)
```
Distortion 1: #D9B3BF  rgb(217, 179, 191) ← Dusty rose
Distortion 2: #BFBFD9  rgb(191, 191, 217) ← Lavender
Distortion 3: #BFD9CC  rgb(191, 217, 204) ← Sage
Distortion 4: #E6D9B3  rgb(230, 217, 179) ← Warm sand
Distortion 5: #CCCCBF  rgb(204, 204, 191) ← Warm taupe
```

**Usage**: Future feature - color-code distortion types in insights

---

## Typography

### System Font: SF Rounded
- **Feel**: Friendly, approachable, modern
- **Why**: Softer than default SF Pro, less clinical

### Sizes & Weights
```
Large Title:  34pt, Bold    ← Big moments (empty state)
Title:        28pt, Semibold ← Screen titles
Title 2:      22pt, Semibold ← Section headers  
Title 3:      20pt, Semibold ← Card headers
Headline:     17pt, Semibold ← Buttons, emphasis
Body:         17pt, Regular  ← Main content
Callout:      16pt, Regular  ← Secondary content
Subheadline:  15pt, Regular  ← Descriptions
Footnote:     13pt, Regular  ← Meta info (timestamps)
Caption:      12pt, Regular  ← Tiny labels
```

---

## Spacing System

```
XS:  4pt   ← Tight spacing (icon + label)
SM:  8pt   ← Close elements
MD:  16pt  ← Standard padding (most common)
LG:  24pt  ← Section spacing
XL:  32pt  ← Major sections
XXL: 48pt  ← Large gaps (empty states)
```

**Usage**:
- Padding inside cards: MD (16pt)
- Space between cards: MD (16pt)  
- Screen edges: MD (16pt)
- Between major sections: LG (24pt)

---

## Corner Radius

```
SM: 8pt   ← Small elements (tags, badges)
MD: 12pt  ← Cards, buttons (most common)
LG: 16pt  ← Large cards
XL: 24pt  ← Modals, sheets
```

**Philosophy**: Rounded for warmth, but not overly rounded (avoiding toy-like feel)

---

## Shadows (Subtle)

### Card Shadow
```
Color:  Black @ 8% opacity
Radius: 8pt
Offset: (0, 2)
```
**Effect**: Gentle elevation, not harsh

### Button Shadow  
```
Color:  Black @ 12% opacity
Radius: 4pt
Offset: (0, 2)
```
**Effect**: Slight depth for tactility

---

## Component Examples

### Primary Button
```
Background: Primary (#D18562)
Text: White, Headline weight
Padding: 16pt horizontal, 16pt vertical
Corner Radius: 12pt
Shadow: Button shadow
```

**States**:
- Normal: Full color
- Pressed: Primary Dark (#A65940)
- Disabled: 50% opacity

### Card
```
Background: Card Background (White)
Corner Radius: 12pt
Shadow: Card shadow
Padding: 16pt
```

### Status Badge
```
"Reviewed":
  Icon: checkmark.circle.fill
  Color: Success green
  Font: Caption

"Unreviewed":
  Icon: circle (filled)
  Color: Primary
  Size: 8pt (small dot)
```

---

## Screen-Specific Design

### Home Screen

**Status Card** (if unreviewed thoughts exist):
```
┌─────────────────────────────────────┐
│ 💡  2 thoughts to review            │ ← Icon + headline
│     Take a moment to reframe...     │ ← Subheadline, secondary text
└─────────────────────────────────────┘
Background: White card
Padding: 16pt
Icon: Primary color, title2 size
```

**Thought Card**:
```
┌─────────────────────────────────────┐
│ I'm going to fail...           [●]  │ ← Body text + indicator
│ Nov 6, 2:30 PM            Reviewed  │ ← Caption + status
└─────────────────────────────────────┘
Background: White card
Padding: 16pt
Status: Success green or Primary dot
```

**Empty State**:
```
Center-aligned:
- Brain icon (64pt, tertiary gray)
- "Welcome to Clarity" (Title 2)
- Description (Body, secondary text)
- Primary button
```

### Capture Screen

**Text Input**:
```
Background: White
Border: 1pt, tertiary gray @ 20% opacity
Corner Radius: 12pt
Padding: 8pt inside
Height: 200pt
Placeholder: Tertiary gray, italic example text
```

### Review Screen

**Progress Bar**:
```
5 segments:
- Completed: Primary color (filled capsule)
- Remaining: Tertiary gray @ 30% (filled capsule)
Height: 4pt
Spacing: 4pt between segments
```

**Emotion Slider**:
```
Number display: 64pt, Bold, Primary color
Slider: Primary tint
Labels: Caption, secondary text
Extremes: "Calm" | "Very Anxious"
```

**Distortion Card** (unselected):
```
Background: White
Border: 1pt, tertiary gray @ 20%
Icon: circle (outline), tertiary gray
```

**Distortion Card** (selected):
```
Background: Primary @ 10% opacity
Border: 2pt, Primary
Icon: checkmark.circle.fill, Primary
```

---

## Accessibility

### Minimum Touch Targets
```
Buttons: 44pt × 44pt (minimum)
Tap areas: Extend beyond visual bounds if needed
```

### Color Contrast
All text meets WCAG AA:
- Primary on white: 3.5:1 (AA for large text)
- Text primary on white: 15:1 (AAA)
- Text secondary on white: 4.8:1 (AA)

### Dynamic Type
All text uses:
```swift
.font(Theme.Typography.body) // Scales with user settings
```

### VoiceOver
All interactive elements need labels:
```swift
.accessibilityLabel("Capture new thought")
.accessibilityHint("Opens text input screen")
```

---

## Animation Principles

### Timing
```
Quick: 0.2s  ← Button presses, toggles
Normal: 0.3s ← Sheet presentations, navigation
Slow: 0.4s   ← Large state changes
```

### Easing
```
Default: .easeInOut ← Most animations
Spring: .spring(response: 0.3) ← Bouncy interactions
```

**Philosophy**: Subtle animations that guide attention, not distract

---

## Icon Usage

### SF Symbols
All icons from Apple's SF Symbols:
- `brain.head.profile` - Empty state
- `lightbulb.fill` - Status card (insights)
- `plus.circle.fill` - Add button
- `checkmark.circle.fill` - Completed status
- `circle` - Unreviewed indicator
- `info.circle` - More information
- `arrow.left` - Back navigation

**Weights**: Regular or Semibold (match text weight)

---

## Dark Mode (Future)

For Phase 2, dark mode colors:
```
Background: #1C1917 (warm black)
Card: #292524 (lighter warm black)
Text: #FAFAF9 (warm white)
Primary: Lighter terracotta #E6A280
```

Currently: Light mode only for MVP

---

## Design Philosophy

### Warm Over Cool
- Warm grays (brown undertones) vs. cool grays (blue undertones)
- Terracotta primary vs. blue/purple
- Cream backgrounds vs. stark white

**Why**: Warm colors feel more supportive, less clinical. This is therapy-adjacent, not medical software.

### Soft Over Sharp
- Rounded corners (12pt most common)
- Subtle shadows (8% opacity)
- Rounded fonts (SF Rounded)

**Why**: Softer aesthetics feel less intimidating. We're working with anxiety - hard edges increase stress.

### Simple Over Complex
- Limited color palette (5 core colors)
- Generous white space
- Clear hierarchy

**Why**: Anxious minds appreciate simplicity. Reduce cognitive load.

### Supportive Over Judgmental
- Success green (not harsh red for "failure")
- "Reviewed" not "Completed" (less pressure)
- Dots not exclamation marks (gentle reminders)

**Why**: Tone extends to visual design. No shame, only support.

---

## Comparison to Other Apps

### vs. Apple Health
- **Similarity**: Clean, spacious, rounded
- **Difference**: Warmer palette (we use terracotta, not blue)

### vs. Calm/Headspace
- **Similarity**: Soft, approachable
- **Difference**: Less playful, more grounded (not a game)

### vs. Claude.ai
- **Similarity**: Warm neutrals, friendly rounded type
- **Difference**: Less orange, more muted (mental health context)

**Note**: Untwist's warm palette was inspired by supportive, approachable interfaces like Claude, but tailored specifically for the mental health space with more muted, grounding tones.

---

## Future Design Directions

### Phase 2 Additions
- Dark mode (warm, not stark)
- Haptic feedback (gentle rumbles)
- Micro-animations (celebrate progress)
- Illustrations (warm, abstract, inclusive)

### Design System Expansion
- More semantic colors (info, caution)
- Component library (reusable parts)
- Larger type scale (accessibility)
- Increased spacing scale (iPad)

---

**This warm aesthetic differentiates Untwist from clinical anxiety apps while maintaining professionalism and credibility. The name itself - "Untwist" - directly references David Burns' concept of "twisted thinking," making the brand authentic to the CBT framework.**
