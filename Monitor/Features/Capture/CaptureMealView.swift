//
//  CaptureMealView.swift
//  Monitor
//
//  Enhanced multi-step meal capture with clinical-grade tracking
//

import SwiftUI
import SwiftData
import PhotosUI

struct CaptureMealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var settings: [UserSettings]

    // Step tracking
    @State private var currentStep = 1

    // Basic info (Step 1)
    @State private var foodAndDrink = ""
    @State private var mealType: MealType = .morning
    @State private var timestamp = Date()
    @State private var location = ""
    @State private var photoData: Data?

    // Behaviors (Step 2)
    @State private var believedExcessive = false
    @State private var vomited = false
    @State private var laxativesAmount = 0
    @State private var diureticsAmount = 0
    @State private var exercised = false
    @State private var exerciseDuration: Int?
    @State private var exerciseIntensity: ExerciseIntensity?

    // Context (Step 3)
    @State private var emotionsBefore = ""
    @State private var emotionsDuring = ""
    @State private var emotionsAfter = ""
    @State private var thoughtsAndFeelings = ""

    @State private var error: ErrorWrapper?

    let onSaved: () -> Void
    let existingEntry: MealEntry?

    init(onSaved: @escaping () -> Void, existingEntry: MealEntry? = nil) {
        self.onSaved = onSaved
        self.existingEntry = existingEntry
    }

    private var userSettings: UserSettings? {
        settings.first
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $currentStep) {
                // Step 1: Basic Entry
                BasicEntryStep(
                    foodAndDrink: $foodAndDrink,
                    mealType: $mealType,
                    timestamp: $timestamp,
                    location: $location,
                    photo: $photoData,
                    onContinue: {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                )
                .tag(1)

                // Step 2: Behavior Tracking
                BehaviorTrackingStep(
                    believedExcessive: Binding(
                        get: { self.believedExcessive ? true : nil },
                        set: { self.believedExcessive = $0 ?? false }
                    ),
                    vomited: $vomited,
                    laxativesCount: Binding(
                        get: { laxativesAmount > 0 ? laxativesAmount : nil },
                        set: { laxativesAmount = $0 ?? 0 }
                    ),
                    diureticsCount: Binding(
                        get: { diureticsAmount > 0 ? diureticsAmount : nil },
                        set: { diureticsAmount = $0 ?? 0 }
                    ),
                    exerciseDuration: $exerciseDuration,
                    exerciseIntensity: $exerciseIntensity,
                    onBack: {
                        withAnimation {
                            currentStep = 1
                        }
                    },
                    onContinue: {
                        withAnimation {
                            currentStep = 3
                        }
                    }
                )
                .tag(2)

                // Step 3: Context & Emotions
                ContextStep(
                    emotionsBefore: $emotionsBefore,
                    emotionsDuring: $emotionsDuring,
                    emotionsAfter: $emotionsAfter,
                    comments: $thoughtsAndFeelings,
                    onBack: {
                        withAnimation {
                            currentStep = 2
                        }
                    },
                    onSave: saveMealEntry
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .onAppear {
                loadExistingEntry()
            }
            .errorAlert(error: $error)
        }
    }

    // MARK: - Actions

    private func loadExistingEntry() {
        guard let entry = existingEntry else { return }

        // Load basic info
        foodAndDrink = entry.foodAndDrink
        mealType = entry.mealType
        timestamp = entry.timestamp
        location = entry.location
        photoData = entry.imageData

        // Load behaviors
        believedExcessive = entry.believedExcessive
        vomited = entry.vomited
        laxativesAmount = entry.laxativesAmount
        diureticsAmount = entry.diureticsAmount
        exercised = entry.exercised
        exerciseDuration = entry.exerciseDuration
        exerciseIntensity = entry.exerciseIntensity

        // Load context
        emotionsBefore = entry.emotionsBefore ?? ""
        emotionsDuring = entry.emotionsDuring ?? ""
        emotionsAfter = entry.emotionsAfter ?? ""
        thoughtsAndFeelings = entry.thoughtsAndFeelings ?? ""
    }

    private func saveMealEntry() {
        let trimmedText = foodAndDrink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Create or update entry
        let entry: MealEntry
        if let existingEntry = existingEntry {
            entry = existingEntry
            // Update existing
            entry.foodAndDrink = trimmedText
            entry.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.imageData = photoData
            entry.mealType = mealType
            entry.timestamp = timestamp
            entry.believedExcessive = believedExcessive
            entry.vomited = vomited
            entry.laxativesAmount = laxativesAmount
            entry.diureticsAmount = diureticsAmount
            entry.exercised = exercised
            entry.exerciseDuration = exerciseDuration
            entry.exerciseIntensity = exerciseIntensity
            entry.emotionsBefore = emotionsBefore.isEmpty ? nil : emotionsBefore
            entry.emotionsDuring = emotionsDuring.isEmpty ? nil : emotionsDuring
            entry.emotionsAfter = emotionsAfter.isEmpty ? nil : emotionsAfter
            entry.thoughtsAndFeelings = thoughtsAndFeelings.isEmpty ? nil : thoughtsAndFeelings
        } else {
            entry = MealEntry(
                foodAndDrink: trimmedText,
                location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                imageData: photoData
            )
            // Set additional properties
            entry.mealType = mealType
            entry.timestamp = timestamp
            entry.believedExcessive = believedExcessive
            entry.vomited = vomited
            entry.laxativesAmount = laxativesAmount
            entry.diureticsAmount = diureticsAmount
            entry.exercised = exercised
            entry.exerciseDuration = exerciseDuration
            entry.exerciseIntensity = exerciseIntensity
            entry.emotionsBefore = emotionsBefore.isEmpty ? nil : emotionsBefore
            entry.emotionsDuring = emotionsDuring.isEmpty ? nil : emotionsDuring
            entry.emotionsAfter = emotionsAfter.isEmpty ? nil : emotionsAfter
            entry.thoughtsAndFeelings = thoughtsAndFeelings.isEmpty ? nil : thoughtsAndFeelings
            modelContext.insert(entry)
        }

        // Explicitly save to ensure persistence before dismissing
        do {
            try modelContext.save()

            // Success haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Trigger parent toast and dismiss immediately
            onSaved()
            dismiss()
        } catch {
            // Error haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            // Show error to user with retry option
            self.error = ErrorWrapper(
                message: "We couldn't save your meal entry. Please try again.",
                retryAction: { [weak modelContext] in
                    // Retry the save operation
                    try? modelContext?.save()
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    CaptureMealView(onSaved: {})
        .modelContainer(for: MealEntry.self, inMemory: true)
}
