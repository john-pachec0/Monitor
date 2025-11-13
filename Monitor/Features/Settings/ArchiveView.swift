//
//  ArchiveView.swift
//  Monitor
//
//  Historical meal entries archive (older than configured days)
//  To be redesigned in Phase 2
//

import SwiftUI
import SwiftData

// TODO: Phase 2 - Redesign archive for meal entries
// This is currently stubbed to prevent compilation errors

struct ArchiveView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Archive Coming Soon")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("The archive feature will be redesigned in Phase 2 to support meal entry history.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    ArchiveView()
}
