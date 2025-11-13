# Self-Monitoring Tool - Implementation Guide

## Overview
This document maps the Equip Self-Monitoring Tool standard to our Monitor app implementation.

## Source Reference
Based on: `Self-Monitoring Tool_7 Day.pdf.pdf` (Equip, published 9/6/2024)

---

## Standard Self-Monitoring Tool Format

### Tracked Columns:
1. **Time** - When eating occurred (AM/PM)
2. **Food and Drink Consumed** - What was eaten/drunk
3. **Place** - Location where eating occurred
4. **\*** - Asterisk flag for "believed excessive"
5. **V/L/D/E** - Eating disorder behaviors:
   - **V** = Vomit (purging)
   - **L** = Laxatives (include amount)
   - **D** = Diuretics (include amount)
   - **E** = Exercise
6. **Context and Comments** - Thoughts, feelings, related events

### Best Practices from Equip:
- ✅ **Record promptly** - Write down soon after consumption
- ✅ **Be thorough** - Record any noteworthy occurrences
- ✅ **Keep accessible** - Have tool available at all times
- ✅ **Distinguish meals vs snacks** - Use [brackets] for meals
- ✅ **Identify patterns** - Goal is to see patterns in thoughts, feelings, behaviors

---

## Our Implementation Alignment

### ✅ Current MealEntry Model (Complete Coverage)

| Standard Column | Our Implementation | Status |
|----------------|-------------------|---------|
| Time | `timestamp: Date` | ✅ Complete |
| Food & Drink | `foodAndDrink: String` | ✅ Complete |
| Place | `location: String` | ✅ Complete |
| \* (excessive) | `believedExcessive: Bool?` | ✅ Complete |
| V (vomit) | `vomited: Bool` | ✅ Complete |
| L (laxatives) | `laxativesAmount: Int` | ✅ Complete |
| D (diuretics) | `diureticsAmount: Int` | ✅ Complete |
| E (exercise) | `exercised: Bool`, `exerciseDuration`, `exerciseIntensity`, `exerciseType` | ✅ Enhanced |
| Context/Comments | `thoughtsAndFeelings: String`, `emotionsBefore`, `emotionsAfter` | ✅ Enhanced |

### ✨ Additional Features (Beyond Standard)

Our implementation includes enhancements beyond the paper tool:

1. **Photo Capture** (`imageData: Data?`)
   - Visual documentation of meals
   - Helpful for therapist review

2. **Meal Type Classification** (`mealType: MealType`)
   - Breakfast, Lunch, Dinner, Snack, Other
   - Better than just brackets for pattern analysis

3. **Exercise Details** (Enhanced tracking)
   - Duration in minutes
   - Intensity level (low, moderate, high, extreme)
   - Type description

4. **Emotional Tracking** (Enhanced)
   - Emotions before eating
   - Emotions after eating
   - Emotional intensity scale (1-10)

5. **Review System**
   - Mark entries as reviewed
   - Add review notes
   - Track flagged entries

6. **Digital Advantages**
   - Auto-timestamping
   - Searchable/filterable history
   - Pattern visualization potential
   - Easy PDF export for therapist sharing

---

## Implementation Priorities for Phase 2

### High Priority (Matches Standard Tool Exactly)

1. **Capture Flow Must Be Quick**
   - Emphasize "record promptly" messaging
   - Minimize required fields
   - Auto-populate time and suggest meal type
   - Optional photo (don't block on it)

2. **Believed Excessive Flag ("*")**
   - Make this prominent in capture UI
   - Clear question: "Did this feel excessive to you?"
   - Optional but easy to answer

3. **Behavior Tracking**
   - Simple checkboxes for V/L/D/E
   - If L or D checked, prompt for amount
   - If E checked, prompt for duration (optional: intensity/type)

4. **Meal vs Snack Visual Distinction**
   - In timeline: Show meals with brackets or different styling
   - In PDF export: Use [brackets] for meals like the paper form

### Medium Priority (Enhanced Features)

5. **PDF Export Format**
   - Should resemble the familiar paper tool layout
   - Columns: Time | Food/Drink | Place | * | V/L/D/E | Context
   - Include photos if present
   - Summary statistics at end

6. **Pattern Recognition**
   - Timeline filters by:
     - Meal type
     - Behaviors present
     - Time of day
     - Location
   - Visual indicators for concerning patterns

### Lower Priority (Nice to Have)

7. **Meal Planning**
   - Scheduled meal reminders
   - Compare planned vs actual

8. **Insights Dashboard**
   - Weekly summary
   - Behavior frequency trends
   - Most common locations/times

---

## UI/UX Principles from Standard Tool

### 1. Accessibility is Key
**Paper tool:** "Have your tool or tracker with you at all times"
**Digital advantage:** Phone is already always with you
**Implementation:** Quick capture from home screen widget (future), notifications

### 2. Minimal Friction
**Paper tool:** Simple columns, quick to fill
**Digital implementation:**
- Auto-populate time
- Smart defaults (meal type based on time)
- Optional fields clearly marked
- Save drafts automatically

### 3. Non-Judgmental Design
**Paper tool:** Clinical, objective terminology
**Digital implementation:**
- Use same terminology: "consumption" not "eating"
- "Believed excessive" matches their phrasing
- Supportive tone, never judging

### 4. Purpose is Pattern Recognition
**Paper tool:** "Identify patterns in thoughts, feelings, and behaviors"
**Digital advantage:**
- Filters and search
- Visual timeline
- Statistics and trends
- Exportable data

---

## Phase 2 Capture Flow Design

### Step 1: Quick Entry (Required)
```
┌─────────────────────────────────────┐
│ Log an Entry                        │
├─────────────────────────────────────┤
│ [Camera Icon] Add photo (optional)  │
│                                     │
│ What did you eat/drink?             │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Meal Type: [Breakfast ▾]            │
│ Time: 8:30 AM                       │
│ Place: Kitchen                      │
│                                     │
│          [Continue →]                │
└─────────────────────────────────────┘
```

### Step 2: Assessment (Optional but Encouraged)
```
┌─────────────────────────────────────┐
│ How did it feel?                    │
├─────────────────────────────────────┤
│ Did this feel excessive?            │
│ [ ] Yes  [ ] No  [ ] Unsure         │
│                                     │
│ Any behaviors to track?             │
│ [ ] Vomiting                        │
│ [ ] Laxatives (amount: ___)         │
│ [ ] Diuretics (amount: ___)         │
│ [ ] Exercise                        │
│                                     │
│ [← Back]           [Save]           │
└─────────────────────────────────────┘
```

### Step 3: Context (Optional)
```
┌─────────────────────────────────────┐
│ Thoughts & Feelings                 │
├─────────────────────────────────────┤
│ Before eating:                      │
│ ┌─────────────────────────────────┐ │
│ │ (Optional)                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ After eating:                       │
│ ┌─────────────────────────────────┐ │
│ │ (Optional)                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Context or events:                  │
│ ┌─────────────────────────────────┐ │
│ │ (Optional)                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [← Back]           [Save]           │
└─────────────────────────────────────┘
```

---

## PDF Export Format (Matches Standard Tool)

```
Self-Monitoring Log
Export Date: January 15, 2025
Care Team: Dr. Smith (therapist@example.com)

┌──────────────────────────────────────────────────────────────┐
│ Day: Monday                        Date: January 13, 2025     │
├─────┬────────────┬────────┬───┬──────┬─────────────────────┤
│Time │Food/Drink  │Place   │ * │V/L/D/E│Context & Comments   │
├─────┼────────────┼────────┼───┼──────┼─────────────────────┤
│8:30 │Oatmeal,    │Kitchen │   │      │Felt calm, ate with  │
│ AM  │coffee      │        │   │      │family               │
├─────┼────────────┼────────┼───┼──────┼─────────────────────┤
│12:30│Sandwich,   │Work    │ * │ V    │Felt anxious about   │
│ PM  │chips, soda │cafeteria│   │      │meeting. Purged after│
├─────┼────────────┼────────┼───┼──────┼─────────────────────┤
│6:00 │Salad,      │Home    │   │      │Ate mindfully, felt  │
│ PM  │chicken     │        │   │      │okay afterward       │
└─────┴────────────┴────────┴───┴──────┴─────────────────────┘

[Photos would be included inline or as appendix]

Summary for January 13, 2025:
- Total entries: 3 meals
- Entries marked as excessive: 1
- Behaviors: 1 purging episode
- Notes: Check in about anxiety triggers before lunch
```

---

## Key Terminology Alignment

| Avoid (Judgmental) | Use (Clinical/Supportive) |
|-------------------|--------------------------|
| "Binge" | "Consumption" or "Eating episode" |
| "Admit" | "Log" or "Record" |
| "Confess" | "Document" |
| "Bad food" | "Food and drink" (neutral) |
| "Failed" | "Experienced a behavior" |

---

## Success Metrics

The app successfully implements the Self-Monitoring Tool if:

1. ✅ All standard columns are captured (Time, Food, Place, *, V/L/D/E, Context)
2. ✅ Capture flow is fast (<60 seconds for basic entry)
3. ✅ Users can distinguish meals from snacks
4. ✅ Behavior tracking is clear and non-judgmental
5. ✅ PDF export matches familiar paper format
6. ✅ Data helps identify patterns (filters, search, timeline)
7. ✅ Privacy is maintained (local-only, secure)

---

## Future Enhancements (Post-Launch)

- **Widgets** - Quick log button from home screen
- **Apple Watch** - Log meals and behaviors from wrist
- **Siri Shortcuts** - Voice logging
- **Insights** - Weekly summaries and trend analysis
- **Meal Planning** - Compare planned vs actual intake
- **Care Team Sharing** - Secure PDF export automation
- **Reminders** - Time-based and context-based (location)

---

**Last Updated:** January 15, 2025
**Status:** Phase 1 Complete, Phase 2 Ready to Implement
