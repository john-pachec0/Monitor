//
//  MealHistoryView.swift
//  Monitor
//
//  View for accessing all meal entries
//

import SwiftUI
import SwiftData

struct MealHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MealEntry.timestamp, order: .reverse) private var allEntries: [MealEntry]
    @Query private var settings: [UserSettings]

    private var userSettings: UserSettings? {
        settings.first
    }

    // Show all entries (can filter by date range later)
    private var recentEntries: [MealEntry] {
        // Show last 7 days for now
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return allEntries
        }
        return allEntries.filter { $0.timestamp >= weekAgo }
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if recentEntries.isEmpty {
                emptyState
            } else {
                entriesList
            }
        }
        .navigationTitle("Meal Journal")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "book")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.textTertiary)

            Text("No entries yet")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)

            Text("Your meal entries from the last 7 days will appear here.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
        }
    }

    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(recentEntries) { entry in
                    NavigationLink {
                        // TODO: Phase 2 - Implement meal entry detail/review view
                        Text("Meal detail view coming in Phase 2")
                            .font(Theme.Typography.body)
                    } label: {
                        MealEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteEntry(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    // MARK: - Actions

    private func deleteEntry(_ entry: MealEntry) {
        modelContext.delete(entry)
    }
}

#Preview {
    NavigationStack {
        MealHistoryView()
            .modelContainer(for: MealEntry.self, inMemory: true)
    }
}
