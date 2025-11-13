//
//  WorryBoxView.swift
//  Untwist
//
//  View for accessing all captured worries
//  Hidden from main screen, accessible via toolbar button
//

import SwiftUI
import SwiftData

struct WorryBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AnxiousThought.timestamp, order: .forward) private var allThoughts: [AnxiousThought]
    @Query private var settings: [UserSettings]

    private var userSettings: UserSettings? {
        settings.first
    }

    // Filter to show only today's thoughts for clean slate experience
    private var todaysThoughts: [AnxiousThought] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return allThoughts.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if todaysThoughts.isEmpty {
                emptyState
            } else {
                thoughtsList
            }
        }
        .navigationTitle("Worry Box")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "box")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.textTertiary)

            Text("Your worry box is empty")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)

            Text("Captured worries will appear here, ready for you to review when the time is right.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()

            // Learn CTA
            learnCTA
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private var learnCTA: some View {
        NavigationLink(destination: LearnHomeView()) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Learn About Cognitive Distortions")
                        .font(Theme.Typography.headline)

                    Text("Understand the 13 thinking patterns")
                        .font(Theme.Typography.caption)
                        .opacity(0.9)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.7)
            }
            .foregroundColor(Theme.Colors.text)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .strokeBorder(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var thoughtsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                // Review Today button
                reviewTodayButton

                ForEach(todaysThoughts) { thought in
                    NavigationLink {
                        if thought.isReviewed {
                            ReviewedThoughtSummaryView(thought: thought)
                        } else {
                            ReviewThoughtView(thought: thought)
                        }
                    } label: {
                        WorryBoxThoughtCard(thought: thought)
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
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    private var reviewTodayButton: some View {
        Group {
            if !todaysThoughts.isEmpty {
                NavigationLink(destination: ChronologicalReviewView()) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Review Today's Thoughts")
                                .font(Theme.Typography.headline)
                                .foregroundColor(.white)

                            Text("\(todaysThoughts.count) \(todaysThoughts.count == 1 ? "thought" : "thoughts") from today")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(Theme.Spacing.md)
                    .background(
                        LinearGradient(
                            colors: [Theme.Colors.primary, Theme.Colors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Theme.CornerRadius.md)
                    .shadow(
                        color: Theme.Shadows.card.color,
                        radius: Theme.Shadows.card.radius,
                        x: Theme.Shadows.card.x,
                        y: Theme.Shadows.card.y
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review all thoughts")
                .accessibilityHint("Starts guided review of today's \(todaysThoughts.count) \(todaysThoughts.count == 1 ? "thought" : "thoughts")")
            }
        }
    }

    // MARK: - Actions

    private func deleteThought(_ thought: AnxiousThought) {
        modelContext.delete(thought)
    }
}

#Preview {
    NavigationStack {
        WorryBoxView()
            .modelContainer(for: AnxiousThought.self, inMemory: true)
    }
}
