# Architecture & Code Structure

## Overview

Untwist uses a **clean, layered architecture** optimized for iOS 17+ with SwiftUI and SwiftData.

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (SwiftUI Views + ViewModels)     │
├─────────────────────────────────────┤
│          Domain Layer               │
│    (Models + Business Logic)        │
├─────────────────────────────────────┤
│           Data Layer                │
│         (SwiftData)                 │
└─────────────────────────────────────┘
```

## Layer Breakdown

### 1. Presentation Layer (Views)

**Location**: `Features/`

Each feature is self-contained:
- **Home**: List of thoughts, quick capture access
- **Capture**: Fast thought input
- **Review**: Guided CBT review process

**Principles**:
- Views are dumb (minimal logic)
- Use `@Query` for SwiftData queries
- Use `@State` for local UI state
- Use `@Bindable` for model binding (iOS 17+)

**Example Pattern**:
```swift
struct HomeView: View {
    @Query var thoughts: [AnxiousThought] // SwiftData query
    @State private var showingCapture = false // UI state
    
    var body: some View {
        // View code
    }
}
```

### 2. Domain Layer (Models)

**Location**: `Models/`

**AnxiousThought.swift**
- Core domain model
- SwiftData `@Model` macro for persistence
- Business logic properties (isReviewed, distortions, etc.)

**CognitiveDistortion enum**
- All 5 distortion types
- Display names, descriptions, examples
- Used for selection and education

**Why This Structure**:
- Domain models are independent of UI
- Easy to test business logic
- Can be reused in widgets, extensions, etc.

### 3. Data Layer (SwiftData)

**Location**: `UntwistApp.swift` (model container setup)

**How It Works**:
```swift
.modelContainer(for: [AnxiousThought.self])
```
- SwiftData automatically creates database
- Stores at: `~/Library/Application Support/[bundle-id]/`
- Encrypted with device encryption
- Automatic iCloud sync (if enabled in capabilities)

**Queries**:
```swift
@Query(sort: \AnxiousThought.timestamp, order: .reverse) 
private var thoughts: [AnxiousThought]
```
- Declarative queries in views
- Automatically updates when data changes
- No manual refresh needed

### 4. Core Layer (Shared)

**Location**: `Core/`

**Theme.swift**
- Centralized design system
- Colors, typography, spacing
- View modifiers for consistent styling

**Why Centralized**:
- Single source of truth for design
- Easy to update globally
- Consistent user experience

---

## Data Flow

### Capturing a Thought

```
User types text
     ↓
CaptureThoughtView
     ↓
Creates AnxiousThought model
     ↓
modelContext.insert(thought)
     ↓
SwiftData saves automatically
     ↓
@Query in HomeView updates
     ↓
Thought appears in list
```

### Reviewing a Thought

```
User taps thought
     ↓
NavigationLink passes thought to ReviewThoughtView
     ↓
@Bindable var thought: AnxiousThought
     ↓
User edits properties (distortions, reframe, etc.)
     ↓
Changes automatically persisted by SwiftData
     ↓
On complete: thought.isReviewed = true
     ↓
HomeView updates (checkmark appears)
```

**Key Insight**: SwiftData's `@Bindable` macro means any changes to the model are immediately persisted. No manual save() call needed!

---

## State Management Strategy

### Local UI State: `@State`
Used for: UI-only state that doesn't need persistence

```swift
@State private var showingCapture = false
@State private var currentStep: ReviewStep = .readThought
```

### Model Binding: `@Bindable` (iOS 17+)
Used for: Direct binding to SwiftData models

```swift
@Bindable var thought: AnxiousThought

// In view:
TextEditor(text: $thought.reframe) // Auto-persisted!
```

### Data Queries: `@Query`
Used for: Fetching data from SwiftData

```swift
@Query(sort: \AnxiousThought.timestamp, order: .reverse) 
private var thoughts: [AnxiousThought]
```

### Environment: `@Environment`
Used for: Dependency injection (model context, dismiss action)

```swift
@Environment(\.modelContext) private var modelContext
@Environment(\.dismiss) private var dismiss
```

---

## Why This Architecture?

### Advantages

✅ **Simple**: No complex MVVM boilerplate
✅ **Modern**: Uses iOS 17+ features (SwiftData, @Observable)
✅ **Reactive**: UI updates automatically with data
✅ **Testable**: Models are plain Swift, easy to test
✅ **Maintainable**: Clear separation of concerns
✅ **Performant**: SwiftData is optimized by Apple

### Tradeoffs

⚠️ **iOS 17+ only**: Can't support older iOS versions
⚠️ **Less control**: SwiftData abstracts persistence details
⚠️ **No ViewModel layer**: Business logic in views (okay for MVP)

---

## Design Patterns Used

### 1. Repository Pattern (Implicit)
SwiftData acts as repository:
- Queries are repositories
- modelContext is unit of work
- No need for explicit repository classes (yet)

### 2. Composition Over Inheritance
Views are composed of smaller views:
```swift
// HomeView contains:
- statusCard
- emptyState  
- thoughtsList
- ThoughtCard component
```

### 3. Single Responsibility
Each view has one job:
- HomeView: Show thoughts
- CaptureThoughtView: Capture input
- ReviewThoughtView: Guide review process

### 4. Dependency Injection
SwiftUI's environment for dependencies:
```swift
@Environment(\.modelContext) // Injected by SwiftUI
```

---

## Code Style & Conventions

### Naming
- Views: `SomethingView`
- Models: Plain nouns (`AnxiousThought`, not `AnxiousThoughtModel`)
- Enums: PascalCase with descriptive names
- Properties: camelCase

### File Organization
```
Feature/
├── FeatureView.swift (main view)
└── FeatureComponents.swift (if needed)
```

### Comments
```swift
// MARK: - Section Name    (for organizing)
// TODO: Future feature     (for backlog)
// FIXME: Known issue       (for bugs)
```

### SwiftUI Best Practices
```swift
// ✅ Good: Extract complex views
var statusCard: some View { ... }

// ❌ Bad: Everything in body
var body: some View {
    // 200 lines of code
}
```

---

## Testing Strategy (Future)

### Unit Tests
Test models and business logic:
```swift
func testThoughtReviewMarksAsComplete() {
    let thought = AnxiousThought(content: "Test")
    thought.isReviewed = true
    XCTAssertTrue(thought.isReviewed)
}
```

### UI Tests (Minimal)
Test critical user flows:
- Capture → Review → Complete
- Navigation works
- Data persists

### Manual Testing
Most testing is manual for MVP:
- Different thought lengths
- Edge cases (empty states, etc.)
- Real device testing (performance)

---

## Performance Considerations

### LazyVStack in Lists
```swift
LazyVStack { 
    ForEach(thoughts) { thought in ... }
}
// Only renders visible items
```

### Query Optimization
```swift
@Query(sort: \AnxiousThought.timestamp, order: .reverse)
// Sorted in database, not in memory
```

### Avoiding Re-renders
SwiftUI is smart, but:
- Use `@State` sparingly
- Extract subviews to prevent re-renders
- Profile with Instruments if slow

---

## Privacy & Security

### Local-Only Data
```swift
// No network code at all
// No URLSession
// No API calls
// Just local SwiftData
```

### Device Encryption
- SwiftData uses iOS encryption automatically
- Data encrypted at rest
- Protected by device passcode/Face ID

### Future: App Lock
```swift
// Add in Phase 2:
import LocalAuthentication

// Require Face ID to open app
// Or custom passcode screen
```

---

## Extension Points (For Phase 2)

### 1. Pattern Detection
```swift
// Add to AnxiousThought:
var embedding: [Float]? // Vector representation

// Add service:
class ThoughtMatcher {
    func findSimilar(to thought: AnxiousThought) -> [AnxiousThought]
}
```

### 2. Insights
```swift
// Add model:
@Model
class WeeklyInsight {
    var weekStart: Date
    var thoughtCount: Int
    var mostCommonDistortion: CognitiveDistortion?
    // etc.
}

// Add view:
InsightsView()
```

### 3. Settings
```swift
// Add model:
@Model
class UserSettings {
    var preferredReviewTime: Date
    var notificationsEnabled: Bool
    var requiresPasscode: Bool
}

// Add view:
SettingsView()
```

### 4. Notifications
```swift
import UserNotifications

class NotificationService {
    func scheduleReviewReminder(at time: Date)
    func cancelAllNotifications()
}
```

---

## Common Patterns Cheatsheet

### Creating & Saving
```swift
let thought = AnxiousThought(content: "...")
modelContext.insert(thought)
// Auto-saved!
```

### Querying
```swift
@Query(
    filter: #Predicate<AnxiousThought> { $0.isReviewed == false },
    sort: \AnxiousThought.timestamp,
    order: .reverse
)
var unreviewedThoughts: [AnxiousThought]
```

### Updating
```swift
thought.isReviewed = true
// Auto-saved! No modelContext.save() needed
```

### Deleting
```swift
modelContext.delete(thought)
```

### Navigation
```swift
NavigationLink(destination: DetailView(item: item)) {
    Text("Tap me")
}
```

### Sheets
```swift
.sheet(isPresented: $showingSheet) {
    SheetContentView()
}
```

---

## Resources

### Apple Documentation
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [@Observable](https://developer.apple.com/documentation/observation)

### Community Resources
- [Hacking with Swift - SwiftData](https://www.hackingwithswift.com/quick-start/swiftdata)
- [SwiftUI Lab](https://swiftui-lab.com)

---

**This architecture is intentionally simple for MVP. As the app grows, we can refactor to add ViewModels, repositories, or other patterns as needed.**
