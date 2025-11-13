//
//  FeedbackView.swift
//  Monitor
//
//  View for submitting feedback to developers
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var feedbackText = ""
    @State private var selectedType: FeedbackType = .generalFeedback
    @State private var includeDiagnostic = false
    @State private var isSending = false
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isTextEditorFocused: Bool

    private let diagnosticInfo = DiagnosticInfo.current()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Introduction
                        introductionSection

                        // Feedback type picker
                        feedbackTypePicker

                        // Feedback text editor
                        feedbackEditor

                        // Diagnostic info toggle
                        diagnosticToggle

                        // Diagnostic info details (when enabled)
                        if includeDiagnostic {
                            diagnosticInfoSection
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                sendButton
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.background)
            }
            .onAppear {
                isTextEditorFocused = true
            }
            .confirmationDialog(
                "Send Feedback?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Send", role: .destructive) {
                    Task {
                        await sendFeedback()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(confirmationMessage)
            }
            .alert("Feedback Sent!", isPresented: $showingSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We appreciate you taking the time to help improve Monitor.")
            }
            .alert("Error Sending Feedback", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Subviews

    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("We'd love to hear from you")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Text("Share bugs, feature ideas, or general thoughts about the app.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }

    private var feedbackTypePicker: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Type")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            Picker("Feedback Type", selection: $selectedType) {
                ForEach(FeedbackType.allCases) { type in
                    Text(type.shortDisplayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var feedbackEditor: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Your Feedback")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                if feedbackText.isEmpty {
                    Text("Share your thoughts here...")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $feedbackText)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                    .scrollContentBackground(.hidden)
                    .focused($isTextEditorFocused)
            }
            .frame(minHeight: 150)
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var diagnosticToggle: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Toggle(isOn: $includeDiagnostic) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Include diagnostic info")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)

                    Text("Helps us understand technical issues")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .tint(Theme.Colors.primary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var diagnosticInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Diagnostic Info")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            Text("The following information will be included:")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textSecondary)

            Text(diagnosticInfo.formattedDescription)
                .font(Theme.Typography.footnote.monospaced())
                .foregroundColor(Theme.Colors.text)
                .padding(Theme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.sm)
        }
    }

    private var sendButton: some View {
        Button {
            showingConfirmation = true
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(isSending ? "Sending..." : "Send Feedback")
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, Theme.Spacing.md)
            .background(canSend ? Theme.Colors.primary : Theme.Colors.textTertiary)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .disabled(!canSend || isSending)
    }

    // MARK: - Computed Properties

    private var canSend: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var confirmationMessage: String {
        var message = "This will send the following to our server:\n\n"
        message += "• Your feedback message\n"
        message += "• Feedback type: \(selectedType.displayName)\n"

        if includeDiagnostic {
            message += "• Diagnostic info (app version, iOS version, device, locale)\n"
        }

        message += "\nYour thoughts and personal data remain private and local to your device."

        return message
    }

    // MARK: - Actions

    private func sendFeedback() async {
        isSending = true

        let result = await FeedbackService.shared.sendFeedback(
            feedbackText: feedbackText,
            type: selectedType,
            includeDiagnostic: includeDiagnostic
        )

        isSending = false

        switch result {
        case .success:
            showingSuccess = true
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    FeedbackView()
}
