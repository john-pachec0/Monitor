//
//  WorryBoxThoughtCard.swift
//  Untwist
//
//  Card component for displaying thoughts in the worry box
//  Shows worry text for unreviewed, reframe text for reviewed
//

import SwiftUI

struct WorryBoxThoughtCard: View {
    let thought: AnxiousThought

    private var truncatedText: String {
        let text = thought.isReviewed ? (thought.reframe ?? thought.content) : thought.content
        return text.prefix(100) + (text.count > 100 ? "..." : "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    // Display different text based on review status
                    if thought.isReviewed, let reframe = thought.reframe, !reframe.isEmpty {
                        // Show reframe for reviewed thoughts
                        Text(reframe)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .lineLimit(3)

                        Text("Reframed thought")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.success)
                            .padding(.top, Theme.Spacing.xs)
                    } else {
                        // Show original worry for unreviewed thoughts
                        Text(thought.content)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .lineLimit(3)
                    }
                }

                Spacer()

                // Status indicator
                if !thought.isReviewed {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                }
            }

            // Timestamp and review status
            HStack {
                Text(thought.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                if thought.isReviewed {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Reviewed")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(Theme.Colors.success)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Thought: \(truncatedText)")
        .accessibilityValue(thought.isReviewed ? "Reviewed" : "Not reviewed yet")
        .accessibilityHint("Tap to \(thought.isReviewed ? "view summary" : "review")")
    }
}
