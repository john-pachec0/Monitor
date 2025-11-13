import SwiftUI

struct ContextStep: View {
    @Binding var emotionsBefore: String
    @Binding var emotionsAfter: String
    @Binding var comments: String
    let onBack: () -> Void
    let onSave: () -> Void

    @FocusState private var focusedField: Field?

    enum Field {
        case before, after, comments
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Progress
            ProgressBar(currentStep: 3, totalSteps: 3)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Title
                    Text("Context & Feelings")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Understanding your emotions helps identify patterns")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)

                    // Emotions before
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Label("How were you feeling before eating?", systemImage: "brain.head.profile")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        Text("Consider your emotions, thoughts, and physical sensations")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Anxious about meeting, stomach growling, tired", text: $emotionsBefore, axis: .vertical)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .before)
                    }

                    // Emotions after
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Label("How did you feel after eating?", systemImage: "brain.head.profile")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        Text("Note any changes in mood, thoughts, or physical feelings")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Satisfied, less anxious, full", text: $emotionsAfter, axis: .vertical)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .after)
                    }

                    // Additional context
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Label("Any other context?", systemImage: "note.text")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        Text("Events, situations, or anything else relevant")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Ate with friends, watching TV, after argument", text: $comments, axis: .vertical)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .lineLimit(4...8)
                            .focused($focusedField, equals: .comments)
                    }

                    // Tips
                    InfoCard(
                        icon: "lightbulb.fill",
                        title: "Tracking Tips",
                        description: "You don't need to fill everything out. Even brief notes can help you notice patterns over time. Be honest and kind to yourself."
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }

            // Navigation buttons
            HStack(spacing: Theme.Spacing.sm) {
                // Back button
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Theme.Colors.primary, lineWidth: 1)
                    )
                }

                // Save button (primary)
                Button(action: onSave) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Entry")
                    }
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .fill(Theme.Colors.primary)
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.sm)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}