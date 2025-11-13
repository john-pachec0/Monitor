import SwiftUI
import SwiftData

struct MealEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: MealEntry
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var error: ErrorWrapper?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Photo (if present)
                    if let imageData = entry.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(Theme.CornerRadius.md)
                            .padding(.horizontal, Theme.Spacing.md)
                    }

                    // Basic info section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        // Meal type and time
                        HStack(alignment: .top) {
                            MealTypeIcon(mealType: entry.mealType, size: 50)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(entry.mealType.displayName)
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Colors.text)

                                Text(formatDateTime(entry.timestamp))
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }

                            Spacer()

                            // Excessive indicator
                            if entry.believedExcessive == true {
                                Label("Felt excessive", systemImage: "exclamationmark.triangle.fill")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, Theme.Spacing.xs)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(Theme.CornerRadius.md)
                            }
                        }

                        Divider()

                        // Food and drink
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Label("Food & Drink", systemImage: "fork.knife")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)

                            Text(entry.foodAndDrink)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Location
                        if !entry.location.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Label("Location", systemImage: "location")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)

                                Text(entry.location)
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.text)
                            }
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                    .padding(.horizontal, Theme.Spacing.md)

                    // Behaviors section (if any)
                    if hasBehaviors() {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Label("Behaviors Tracked", systemImage: "list.clipboard")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                if entry.vomited {
                                    BehaviorRow(
                                        icon: "exclamationmark.triangle",
                                        text: "Vomiting",
                                        color: .red
                                    )
                                }

                                if entry.laxativesAmount > 0 {
                                    BehaviorRow(
                                        icon: "pills",
                                        text: "Laxatives: \(entry.laxativesAmount)",
                                        color: .orange
                                    )
                                }

                                if entry.diureticsAmount > 0 {
                                    BehaviorRow(
                                        icon: "drop.triangle",
                                        text: "Diuretics: \(entry.diureticsAmount)",
                                        color: .blue
                                    )
                                }

                                if let duration = entry.exerciseDuration,
                                   let intensity = entry.exerciseIntensity {
                                    BehaviorRow(
                                        icon: "figure.run",
                                        text: "Exercise: \(duration) min (\(intensity.rawValue))",
                                        color: intensityColor(intensity)
                                    )
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    // Emotions section (if any)
                    if hasEmotions() {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Label("Thoughts & Feelings", systemImage: "brain.head.profile")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                if let emotionsBefore = entry.emotionsBefore, !emotionsBefore.isEmpty {
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        Text("Before eating")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        Text(emotionsBefore)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.text)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }

                                if let emotionsAfter = entry.emotionsAfter, !emotionsAfter.isEmpty {
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        Text("After eating")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        Text(emotionsAfter)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.text)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    // Additional context
                    if let thoughtsAndFeelings = entry.thoughtsAndFeelings, !thoughtsAndFeelings.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Label("Additional Context", systemImage: "note.text")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)

                            Text(thoughtsAndFeelings)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    // Action buttons
                    HStack(spacing: Theme.Spacing.sm) {
                        Button(action: { showingEditView = true }) {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButtonStyle()

                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.red)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.lg)
                }
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .sheet(isPresented: $showingEditView) {
                CaptureMealView(
                    onSaved: {
                        // Entry will be updated automatically
                    },
                    existingEntry: entry
                )
            }
            .alert("Delete Entry?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteEntry()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .errorAlert(error: $error)
        }
    }

    // MARK: - Helper Functions

    private func hasBehaviors() -> Bool {
        entry.vomited ||
        entry.laxativesAmount > 0 ||
        entry.diureticsAmount > 0 ||
        entry.exerciseDuration != nil
    }

    private func hasEmotions() -> Bool {
        !(entry.emotionsBefore?.isEmpty ?? true) || !(entry.emotionsAfter?.isEmpty ?? true)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func intensityColor(_ intensity: ExerciseIntensity) -> Color {
        switch intensity {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .orange
        case .extreme:
            return .red
        }
    }

    private func deleteEntry() {
        modelContext.delete(entry)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            self.error = ErrorWrapper(
                message: "Failed to delete entry. Please try again."
            )
        }
    }
}

// MARK: - Supporting Views

struct BehaviorRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)

            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

struct MealTypeIcon: View {
    let mealType: MealType
    let size: CGFloat

    var color: Color {
        switch mealType {
        case .morning:
            return .orange
        case .midday:
            return .yellow
        case .afternoon:
            return .cyan
        case .evening:
            return .indigo
        case .night:
            return .purple
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: size, height: size)

            Image(systemName: mealType.icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(color)
        }
    }
}