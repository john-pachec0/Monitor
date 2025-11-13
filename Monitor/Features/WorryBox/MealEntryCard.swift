//
//  MealEntryCard.swift
//  Monitor
//
//  Enhanced card component for displaying meal entries with clinical indicators
//

import SwiftUI

struct MealEntryCard: View {
    let entry: MealEntry

    private var truncatedFood: String {
        let text = entry.foodAndDrink
        return text.prefix(80) + (text.count > 80 ? "..." : "")
    }

    private var mealTypeIcon: String {
        entry.mealType.icon
    }

    private var mealTypeColor: Color {
        switch entry.mealType {
        case .morning:
            return .orange
        case .midday:
            return .yellow
        case .afternoon:
            return .cyan
        case .evening:
            return .indigo
        case .night:
            return .purple
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            // Left side: Meal type icon
            VStack {
                ZStack {
                    Circle()
                        .fill(mealTypeColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: mealTypeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(mealTypeColor)
                }

                // Photo indicator
                if entry.imageData != nil {
                    Image(systemName: "camera.fill")
                        .font(.caption2)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            // Main content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                // Time and meal type
                HStack(spacing: Theme.Spacing.xs) {
                    Text(entry.mealType.displayName)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.text)
                        .fontWeight(.semibold)

                    Text("•")
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text(formatTime(entry.timestamp))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)

                    Spacer()

                    // Believed excessive indicator (Equip standard notation)
                    if entry.believedExcessive == true {
                        Text("*")
                            .font(Theme.Typography.headline)
                            .foregroundColor(.orange)
                    }
                }

                // Food description
                Text(entry.foodAndDrink)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Location badge
                if !entry.location.isEmpty {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(entry.location)
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }

                // Behavior indicators
                if hasBehaviors() {
                    HStack(spacing: Theme.Spacing.xs) {
                        if entry.vomited {
                            BehaviorBadge(text: "V", color: .red)
                        }
                        if entry.laxativesAmount > 0 {
                            BehaviorBadge(text: "L(\(entry.laxativesAmount))", color: .orange)
                        }
                        if entry.diureticsAmount > 0 {
                            BehaviorBadge(text: "D(\(entry.diureticsAmount))", color: .blue)
                        }
                        if let exercise = entry.exerciseDuration {
                            BehaviorBadge(text: "E(\(exercise)m)", color: .green)
                        }
                    }
                }
            }

            // Right side: Photo thumbnail
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.Colors.textTertiary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Theme.Colors.textTertiary.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription())
        .accessibilityHint("Tap to view full details")
    }

    // MARK: - Helper Functions

    private func hasBehaviors() -> Bool {
        entry.vomited ||
        entry.laxativesAmount > 0 ||
        entry.diureticsAmount > 0 ||
        entry.exerciseDuration != nil
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func accessibilityDescription() -> String {
        var description = "\(entry.mealType.displayName) at \(formatTime(entry.timestamp)): \(truncatedFood)"

        if entry.believedExcessive == true {
            description += ". Believed excessive"
        }

        if hasBehaviors() {
            description += ". Has tracked behaviors"
        }

        return description
    }
}

// MARK: - Supporting Views

struct BehaviorBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .cornerRadius(4)
    }
}
