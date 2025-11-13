//
//  MealEntryCard.swift
//  Monitor
//
//  Card component for displaying meal entries in the journal
//

import SwiftUI

struct MealEntryCard: View {
    let entry: MealEntry

    private var truncatedFood: String {
        let text = entry.foodAndDrink
        return text.prefix(80) + (text.count > 80 ? "..." : "")
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Meal type icon
            Image(systemName: entry.mealTypeIcon)
                .font(.title2)
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.primaryLight.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        // Meal type and time
                        HStack(spacing: Theme.Spacing.xs) {
                            Text(entry.mealTypeLabel)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.text)
                                .bold()

                            Text("•")
                                .foregroundColor(Theme.Colors.textTertiary)

                            Text(entry.formattedTime)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }

                        // Food/drink consumed
                        Text(entry.foodAndDrink)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .lineLimit(2)

                        // Show behavior summary if present
                        if let behaviorSummary = entry.behaviorSummary {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                Text(behaviorSummary)
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(Theme.Colors.warning)
                        }

                        // Show location if present
                        if !entry.location.isEmpty {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                Text(entry.location)
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    // Review status indicator
                    if !entry.isReviewed {
                        Circle()
                            .fill(Theme.Colors.primary)
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.mealTypeLabel) at \(entry.formattedTime): \(truncatedFood)")
        .accessibilityValue(entry.isReviewed ? "Reviewed" : "Not reviewed yet")
        .accessibilityHint("Tap to view details")
    }
}
