//
//  MealHistoryView.swift
//  Monitor
//
//  Enhanced timeline view with filtering and export
//

import SwiftUI
import SwiftData

struct MealHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MealEntry.timestamp, order: .reverse) private var allEntries: [MealEntry]
    @Query private var settings: [UserSettings]

    @State private var showingExport = false
    @State private var selectedEntry: MealEntry?
    @State private var dateFilter = DateFilter.lastWeek
    @State private var mealTypeFilter: MealType?
    @State private var showOnlyWithBehaviors = false

    enum DateFilter: String, CaseIterable {
        case today = "Today"
        case lastWeek = "Last 7 Days"
        case lastMonth = "Last 30 Days"
        case all = "All Entries"

        var dateRange: ClosedRange<Date>? {
            let calendar = Calendar.current
            let now = Date()

            switch self {
            case .today:
                let start = calendar.startOfDay(for: now)
                return start...now
            case .lastWeek:
                guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return nil }
                return start...now
            case .lastMonth:
                guard let start = calendar.date(byAdding: .day, value: -30, to: now) else { return nil }
                return start...now
            case .all:
                return nil
            }
        }
    }

    private var userSettings: UserSettings? {
        settings.first
    }

    private var filteredEntries: [MealEntry] {
        var result = Array(allEntries)

        // Date filter
        if let range = dateFilter.dateRange {
            result = result.filter { range.contains($0.timestamp) }
        }

        // Meal type filter
        if let mealType = mealTypeFilter {
            result = result.filter { $0.mealType == mealType }
        }

        // Behavior filter
        if showOnlyWithBehaviors {
            result = result.filter { entry in
                entry.vomited ||
                entry.laxativesAmount > 0 ||
                entry.diureticsAmount > 0 ||
                entry.exerciseDuration != nil
            }
        }

        return result
    }

    // Group entries by date
    private var groupedEntries: [(Date, [MealEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter controls - always visible
            filterControls
                .padding(.top, Theme.Spacing.sm)

            // Content area
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    entriesList
                }
            }
        }
        .background(Theme.Colors.background)
        .navigationTitle("Meal Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingExport = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showingExport) {
            ExportView()
        }
        .sheet(item: $selectedEntry) { entry in
            MealEntryDetailView(entry: entry)
        }
    }

    // MARK: - Subviews

    private var filterControls: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Date filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(DateFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: dateFilter == filter,
                            action: { dateFilter = filter }
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }

            // Additional filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    // Meal type filters
                    FilterChip(
                        title: "All Meals",
                        isSelected: mealTypeFilter == nil,
                        action: { mealTypeFilter = nil }
                    )

                    ForEach(MealType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.displayName,
                            isSelected: mealTypeFilter == type,
                            action: { mealTypeFilter = type }
                        )
                    }

                    // Behavior filter
                    FilterChip(
                        title: "With Behaviors",
                        isSelected: showOnlyWithBehaviors,
                        systemImage: "exclamationmark.triangle",
                        action: { showOnlyWithBehaviors.toggle() }
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
        .background(Theme.Colors.background)
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "book")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.textTertiary)

            Text("No entries found")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)

            Text(emptyStateMessage)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
        }
    }

    private var emptyStateMessage: String {
        if showOnlyWithBehaviors {
            return "No entries with tracked behaviors in this time period."
        } else if mealTypeFilter != nil {
            return "No \(mealTypeFilter!.displayName.lowercased()) entries in this time period."
        } else {
            switch dateFilter {
            case .today:
                return "No entries logged today."
            case .lastWeek:
                return "No entries from the last 7 days."
            case .lastMonth:
                return "No entries from the last 30 days."
            case .all:
                return "Start logging meals to see them here."
            }
        }
    }

    private var entriesList: some View {
        ScrollView {
            // Entries grouped by date
            LazyVStack(spacing: Theme.Spacing.lg) {
                ForEach(groupedEntries, id: \.0) { date, entries in
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        // Date header
                        Text(formatDateHeader(date))
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.horizontal, Theme.Spacing.md)

                        // Entries for this date
                        ForEach(entries) { entry in
                            Button(action: { selectedEntry = entry }) {
                                MealEntryCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, Theme.Spacing.md)
                            .contextMenu {
                                Button(action: { selectedEntry = entry }) {
                                    Label("View Details", systemImage: "eye")
                                }

                                Button(action: { deleteEntry(entry) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    // MARK: - Actions

    private func deleteEntry(_ entry: MealEntry) {
        modelContext.delete(entry)
    }

    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }
                Text(title)
                    .font(Theme.Typography.caption)
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.text)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.Colors.primary : Theme.Colors.cardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MealHistoryView()
            .modelContainer(for: MealEntry.self, inMemory: true)
    }
}
