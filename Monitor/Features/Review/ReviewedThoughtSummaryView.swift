//
//  ReviewedThoughtSummaryView.swift
//  Monitor
//
//  Summary view for reviewed meal entries - to be redesigned in Phase 2
//

import SwiftUI
import SwiftData

// TODO: Phase 2 - Redesign reviewed summary for meal entries
// This is currently stubbed to prevent compilation errors

struct ReviewedThoughtSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Entry Summary")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Coming in Phase 2")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Summary")
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
    ReviewedThoughtSummaryView()
}
