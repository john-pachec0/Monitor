import SwiftUI

struct BehaviorTrackingStep: View {
    @Binding var believedExcessive: Bool?
    @Binding var vomited: Bool
    @Binding var laxativesCount: Int?
    @Binding var diureticsCount: Int?
    @Binding var exerciseDuration: Int?
    @Binding var exerciseIntensity: ExerciseIntensity?
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSave: () -> Void

    @State private var showExerciseDetails = false
    @State private var hasInteracted = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Progress
            ProgressBar(currentStep: 2, totalSteps: 3)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Title
                    Text("Assessment")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    // Personal belief section (aligned with Equip clinical tracking)
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Did you believe this was excessive?")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)

                        Text("We're tracking your thoughts and feelings, not judging the food. This helps you and your care team understand patterns.")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        HStack(spacing: Theme.Spacing.sm) {
                            BeliefButton(
                                title: "Yes",
                                isSelected: believedExcessive == true,
                                color: .orange,
                                action: {
                                    believedExcessive = true
                                    hasInteracted = true
                                }
                            )

                            BeliefButton(
                                title: "No",
                                isSelected: believedExcessive == false,
                                color: Theme.Colors.success,
                                action: {
                                    believedExcessive = false
                                    hasInteracted = true
                                }
                            )

                            BeliefButton(
                                title: "Unsure",
                                isSelected: believedExcessive == nil && hasInteracted,
                                color: Theme.Colors.textSecondary,
                                action: {
                                    believedExcessive = nil
                                    hasInteracted = true
                                }
                            )
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)

                    // Behaviors section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Any behaviors to track?")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)

                        Text("This helps you and your care team understand patterns")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        VStack(spacing: Theme.Spacing.md) {
                            // Vomiting
                            BehaviorCheckboxRow(
                                label: "Vomiting",
                                icon: "exclamationmark.triangle",
                                isChecked: $vomited
                            )

                            Divider()

                            // Laxatives
                            BehaviorCheckboxRow(
                                label: "Laxatives",
                                icon: "pills",
                                isChecked: Binding(
                                    get: { laxativesCount != nil },
                                    set: { checked in
                                        laxativesCount = checked ? 1 : nil
                                    }
                                ),
                                amount: $laxativesCount,
                                showAmount: true,
                                amountLabel: "Quantity:",
                                unit: ""
                            )

                            Divider()

                            // Diuretics
                            BehaviorCheckboxRow(
                                label: "Diuretics",
                                icon: "drop.triangle",
                                isChecked: Binding(
                                    get: { diureticsCount != nil },
                                    set: { checked in
                                        diureticsCount = checked ? 1 : nil
                                    }
                                ),
                                amount: $diureticsCount,
                                showAmount: true,
                                amountLabel: "Quantity:",
                                unit: ""
                            )

                            Divider()

                            // Exercise
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                BehaviorCheckboxRow(
                                    label: "Exercise",
                                    icon: "figure.run",
                                    isChecked: Binding(
                                        get: { exerciseDuration != nil },
                                        set: { checked in
                                            if checked {
                                                exerciseDuration = 30
                                                exerciseIntensity = .moderate
                                                showExerciseDetails = true
                                            } else {
                                                exerciseDuration = nil
                                                exerciseIntensity = nil
                                                showExerciseDetails = false
                                            }
                                        }
                                    )
                                )

                                // Exercise details
                                if showExerciseDetails, exerciseDuration != nil {
                                    VStack(spacing: Theme.Spacing.md) {
                                        ExerciseDurationPicker(
                                            duration: Binding(
                                                get: { exerciseDuration ?? 30 },
                                                set: { exerciseDuration = $0 }
                                            )
                                        )

                                        IntensityPicker(
                                            selectedIntensity: Binding(
                                                get: { exerciseIntensity ?? .moderate },
                                                set: { exerciseIntensity = $0 }
                                            )
                                        )
                                    }
                                    .padding(.leading, 30)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
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

                // Save button
                Button(action: onSave) {
                    Text("Save")
                        .font(Theme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .fill(Theme.Colors.success)
                        )
                }

                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 6) {
                        Text("Continue")
                            .lineLimit(1)
                        Image(systemName: "arrow.right")
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
        .animation(.easeInOut(duration: 0.2), value: showExerciseDetails)
        .onAppear {
            // Set hasInteracted if we already have a value from editing
            if believedExcessive != nil || believedExcessive == false || believedExcessive == true {
                hasInteracted = true
            }
        }
    }
}

struct BeliefButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundColor(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}