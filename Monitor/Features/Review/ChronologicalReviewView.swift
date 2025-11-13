//
//  ChronologicalReviewView.swift
//  Monitor
//
//  Chronological meal entry review - to be redesigned in Phase 2
//

import SwiftUI
import SwiftData

// TODO: Phase 2 - Redesign chronological review for meal entries
// This is currently stubbed to prevent compilation errors

struct ChronologicalReviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Chronological Review")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Coming in Phase 2")
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
    ChronologicalReviewView()
}
