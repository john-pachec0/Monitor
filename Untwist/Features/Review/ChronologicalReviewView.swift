//
//  ChronologicalReviewView.swift
//  Untwist
//
//  Guided chronological review of today's thoughts
//

import SwiftUI
import SwiftData

struct ChronologicalReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allThoughts: [AnxiousThought]
    @State private var currentIndex = 0
    @State private var showingReview = false
    @State private var showCompletion = false

    private var todaysThoughts: [AnxiousThought] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return allThoughts
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .sorted { $0.timestamp < $1.timestamp } // Ascending (earliest first)
    }

    private var currentThought: AnxiousThought? {
        guard currentIndex < todaysThoughts.count else { return nil }
        return todaysThoughts[currentIndex]
    }

    private var unreviewedThoughts: [AnxiousThought] {
        todaysThoughts.filter { !$0.isReviewed }
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if showCompletion {
                CompletionView(thoughtCount: todaysThoughts.count)
            } else if todaysThoughts.isEmpty {
                NoThoughtsView()
            } else {
                VStack(spacing: Theme.Spacing.xl) {
                    Spacer()

                    // Progress indicator
                    VStack(spacing: Theme.Spacing.md) {
                        Text("Today's Review")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.text)

                        Text("Thought \(currentIndex + 1) of \(todaysThoughts.count)")
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.Colors.textSecondary)

                        // Progress bar
                        ProgressView(value: Double(currentIndex + 1), total: Double(todaysThoughts.count))
                            .tint(Theme.Colors.primary)
                            .padding(.horizontal, Theme.Spacing.xl)
                    }

                    Spacer()

                    // Thought preview
                    if let thought = currentThought {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Captured at \(thought.timestamp, format: .dateTime.hour().minute())")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textTertiary)

                            Text(thought.content)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)
                                .lineLimit(4)
                                .padding(Theme.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.Colors.cardBackground)
                                .cornerRadius(Theme.CornerRadius.md)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: Theme.Spacing.md) {
                        if let thought = currentThought {
                            Button {
                                showingReview = true
                            } label: {
                                Text(thought.isReviewed ? "Review Again" : "Review This Thought")
                                    .frame(maxWidth: .infinity)
                                    .primaryButtonStyle()
                            }
                            .padding(.horizontal, Theme.Spacing.md)

                            if currentIndex < todaysThoughts.count - 1 {
                                Button("Skip to Next") {
                                    advanceToNext()
                                }
                                .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }

                        Button("Exit Review") {
                            dismiss()
                        }
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(.bottom, Theme.Spacing.md)
                    }
                }
                .padding(.top, Theme.Spacing.xl)
            }
        }
        .navigationTitle("Today's Review")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") {
                    dismiss()
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .sheet(isPresented: $showingReview) {
            if let thought = currentThought {
                NavigationStack {
                    ReviewThoughtView(thought: thought)
                }
            }
        }
        .onChange(of: showingReview) { oldValue, newValue in
            if !newValue && oldValue {
                // Sheet was dismissed
                checkProgress()
            }
        }
    }

    private func advanceToNext() {
        if currentIndex + 1 < todaysThoughts.count {
            currentIndex += 1
        } else {
            showCompletion = true
        }
    }

    private func checkProgress() {
        // Check if all thoughts have been reviewed
        if unreviewedThoughts.isEmpty && !todaysThoughts.isEmpty {
            showCompletion = true
        } else {
            // Auto-advance to next unreviewed thought if current is reviewed
            if let currentThought = currentThought, currentThought.isReviewed {
                advanceToNext()
            }
        }
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let thoughtCount: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)

                Text("All Done!")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.text)

                Text("You've reviewed all \(thoughtCount) \(thoughtCount == 1 ? "thought" : "thoughts") from today. Great work!")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Finish")
                        .frame(maxWidth: .infinity)
                        .primaryButtonStyle()
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle("Review Complete")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - No Thoughts View

struct NoThoughtsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "sun.max")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.Colors.textTertiary)

                Text("No Thoughts Today")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.text)

                Text("You haven't captured any thoughts today. Enjoy your clear mind!")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)

                Spacer()
            }
            .padding(.top, Theme.Spacing.xxl)
        }
        .navigationTitle("Today's Review")
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

#Preview {
    NavigationStack {
        ChronologicalReviewView()
            .modelContainer(for: AnxiousThought.self, inMemory: true)
    }
}
