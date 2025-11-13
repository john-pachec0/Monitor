//
//  ArchiveView.swift
//  Untwist
//
//  Historical thoughts archive (older than today)
//  Automatically deletes thoughts older than 30 days
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AnxiousThought.timestamp, order: .reverse) private var allThoughts: [AnxiousThought]

    @State private var showingClearArchiveAlert = false

    // Filter to show only historical thoughts (before today)
    private var archivedThoughts: [AnxiousThought] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return allThoughts.filter { $0.timestamp < today }
    }

    // Group thoughts by date
    private var groupedThoughts: [Date: [AnxiousThought]] {
        Dictionary(grouping: archivedThoughts) { thought in
            Calendar.current.startOfDay(for: thought.timestamp)
        }
    }

    // Sorted date keys (most recent first)
    private var sortedDates: [Date] {
        groupedThoughts.keys.sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if archivedThoughts.isEmpty {
                    emptyState
                } else {
                    archiveList
                }
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !archivedThoughts.isEmpty {
                        Button {
                            showingClearArchiveAlert = true
                        } label: {
                            Text("Clear Archive")
                                .foregroundColor(.red)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
            }
            .alert("Clear Archive?", isPresented: $showingClearArchiveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Archive", role: .destructive) {
                    clearArchive()
                }
            } message: {
                Text("This will permanently delete all archived thoughts. This may impact the app's ability to recognize patterns in your thinking over time. Thoughts from today will not be affected.")
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "archivebox")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.textTertiary)

            Text("No archived thoughts")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)

            Text("Thoughts from previous days will appear here. They're automatically deleted after 30 days.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    private var archiveList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.lg, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section {
                        ForEach(groupedThoughts[date] ?? []) { thought in
                            NavigationLink {
                                if thought.isReviewed {
                                    ReviewedThoughtSummaryView(thought: thought)
                                } else {
                                    ReviewThoughtView(thought: thought)
                                }
                            } label: {
                                ArchiveThoughtCard(thought: thought)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteThought(thought)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        DateSectionHeader(date: date)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    // MARK: - Actions

    private func deleteThought(_ thought: AnxiousThought) {
        modelContext.delete(thought)
    }

    private func clearArchive() {
        // Delete all archived thoughts (older than today)
        archivedThoughts.forEach { thought in
            modelContext.delete(thought)
        }

        do {
            try modelContext.save()
        } catch {
            print("Error saving after clearing archive: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct DateSectionHeader: View {
    let date: Date

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private var relativeDate: String? {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        // Check if within last week
        if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day,
           daysAgo < 7 {
            return "\(daysAgo) days ago"
        }

        return nil
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                if let relative = relativeDate {
                    Text(relative)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)
                    Text(formattedDate)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                } else {
                    Text(formattedDate)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)
                }
            }
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(Theme.Colors.background)
    }
}

struct ArchiveThoughtCard: View {
    let thought: AnxiousThought

    private var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: thought.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                // Status indicator
                Image(systemName: thought.isReviewed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(thought.isReviewed ? Theme.Colors.primary : Theme.Colors.textTertiary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(thought.content)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)
                        .lineLimit(2)

                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "clock")
                            .font(Theme.Typography.caption)
                        Text(timeStamp)
                            .font(Theme.Typography.caption)

                        if thought.isReviewed {
                            Text("•")
                                .font(Theme.Typography.caption)
                            Text("Reviewed")
                                .font(Theme.Typography.caption)
                        }
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .cardStyle()
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: AnxiousThought.self, inMemory: true)
}
