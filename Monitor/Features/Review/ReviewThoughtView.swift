//
//  ReviewThoughtView.swift
//  Monitor
//
//  Meal entry review view - to be redesigned in Phase 2
//

import SwiftUI
import SwiftData

// TODO: Phase 2 - Redesign this view for meal entry review
// This is currently stubbed to prevent compilation errors
// Will implement meal entry review with:
// - Behavioral response tracking
// - Emotion reflection
// - Supportive guidance
// - Optional care team sharing

struct ReviewThoughtView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Under Construction")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Meal entry review will be redesigned in Phase 2 to support ED recovery patterns.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    ReviewThoughtView()
}
