//
//  CaptureThoughtView.swift
//  Untwist
//
//  Quick capture screen for anxious thoughts
//

import SwiftUI
import SwiftData

struct CaptureThoughtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var settings: [UserSettings]

    @State private var thoughtText = ""
    @State private var anxietyRating: Double = 5.0
    @FocusState private var isTextFieldFocused: Bool
    @State private var error: ErrorWrapper?

    let onSaved: () -> Void

    private var userSettings: UserSettings? {
        settings.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.lg) {
                    // Instruction
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("What's on your mind?")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.text)

                        Text("Write down the anxious thought. We'll look at it together later.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Text input
                    ZStack(alignment: .topLeading) {
                        if thoughtText.isEmpty {
                            Text("e.g., \"I'm going to fail this presentation...\"")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textTertiary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $thoughtText)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .scrollContentBackground(.hidden)
                            .focused($isTextFieldFocused)
                    }
                    .frame(height: 200)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                    )

                    // Optional anxiety rating
                    if userSettings?.rateAnxietyAtCapture == true {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("How anxious do you feel right now? (Optional)")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)

                            VStack(spacing: Theme.Spacing.xs) {
                                Slider(value: $anxietyRating, in: 0...10, step: 1)
                                    .tint(Theme.Colors.primary)

                                HStack {
                                    Text("Calm")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textTertiary)
                                    Spacer()
                                    Text("\(Int(anxietyRating))")
                                        .font(Theme.Typography.title2)
                                        .foregroundColor(Theme.Colors.text)
                                        .bold()
                                    Spacer()
                                    Text("Anxious")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textTertiary)
                                }
                            }
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.secondaryBackground)
                            .cornerRadius(Theme.CornerRadius.sm)
                        }
                    }

                    // Save button
                    Button(action: saveThought) {
                        Text("Save Thought")
                            .frame(maxWidth: .infinity)
                            .primaryButtonStyle()
                    }
                    .disabled(thoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(thoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    
                    Spacer()
                }
                .padding(Theme.Spacing.md)
            }
            .navigationTitle("Capture Thought")
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
                // Auto-focus the text field quickly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
            .errorAlert(error: $error)
        }
    }
    
    // MARK: - Actions
    
    private func saveThought() {
        let trimmedText = thoughtText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let captureRating = userSettings?.rateAnxietyAtCapture == true ? Int(anxietyRating) : nil
        let thought = AnxiousThought(content: trimmedText, emotionAtCapture: captureRating)
        modelContext.insert(thought)

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
                message: "We couldn't save your thought. Please try again.",
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
    CaptureThoughtView(onSaved: {})
        .modelContainer(for: AnxiousThought.self, inMemory: true)
}
