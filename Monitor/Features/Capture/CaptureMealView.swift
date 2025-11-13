//
//  CaptureMealView.swift
//  Monitor
//
//  Quick capture screen for logging meals
//

import SwiftUI
import SwiftData
import PhotosUI

struct CaptureMealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var settings: [UserSettings]

    @State private var mealText = ""
    @State private var location = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @FocusState private var isTextFieldFocused: Bool
    @State private var error: ErrorWrapper?

    let onSaved: () -> Void

    private var userSettings: UserSettings? {
        settings.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Instruction
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("What did you eat or drink?")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.text)

                        Text("Log your meal quickly and without judgment.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Meal text input
                    ZStack(alignment: .topLeading) {
                        if mealText.isEmpty {
                            Text("e.g., \"Oatmeal with berries, coffee\"")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textTertiary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $mealText)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .scrollContentBackground(.hidden)
                            .focused($isTextFieldFocused)
                    }
                    .frame(height: 120)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                    )

                    // Location input
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Location (Optional)")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Home, Restaurant, Work", text: $location)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                    .stroke(Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Photo picker
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Photo (Optional)")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: photoData == nil ? "camera" : "checkmark.circle.fill")
                                    .font(.title3)
                                Text(photoData == nil ? "Add Photo" : "Photo Added")
                                    .font(Theme.Typography.body)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(photoData == nil ? Theme.Colors.primary : Theme.Colors.success)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                    .stroke(Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .onChange(of: selectedPhoto) { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    photoData = data
                                }
                            }
                        }

                        // Show thumbnail if photo selected
                        if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 150)
                                .cornerRadius(Theme.CornerRadius.md)
                        }
                    }

                    // Save button
                    Button(action: saveThought) {
                        Text("Save Meal")
                            .frame(maxWidth: .infinity)
                            .primaryButtonStyle()
                    }
                    .disabled(mealText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(mealText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

                    Spacer()
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
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
        let trimmedText = mealText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let entry = MealEntry(
            foodAndDrink: trimmedText,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: photoData
        )
        modelContext.insert(entry)

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
