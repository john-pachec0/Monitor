//
//  IntensityPicker.swift
//  Monitor
//
//  Exercise intensity and duration picker components
//  Redesigned with calming teal palette and compact layout
//

import SwiftUI

// MARK: - Intensity Picker

struct IntensityPicker: View {
    @Binding var selectedIntensity: ExerciseIntensity

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Intensity")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)

            // Segmented picker style with icons
            HStack(spacing: 0) {
                ForEach(ExerciseIntensity.allCases) { intensity in
                    IntensitySegment(
                        intensity: intensity,
                        isSelected: selectedIntensity == intensity,
                        isFirst: intensity == .low,
                        isLast: intensity == .extreme,
                        action: { selectedIntensity = intensity }
                    )
                }
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }
}

// MARK: - Intensity Segment

private struct IntensitySegment: View {
    let intensity: ExerciseIntensity
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let action: () -> Void

    private var icon: String {
        switch intensity {
        case .low:
            return "tortoise.fill"
        case .moderate:
            return "figure.walk"
        case .high:
            return "figure.run"
        case .extreme:
            return "bolt.fill"
        }
    }

    private var intensityLevel: Int {
        switch intensity {
        case .low: return 1
        case .moderate: return 2
        case .high: return 3
        case .extreme: return 4
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with intensity-based opacity
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(foregroundColor)

                // Label
                Text(intensity.displayName)
                    .font(Theme.Typography.caption)
                    .foregroundColor(foregroundColor)

                // Intensity dots
                HStack(spacing: 2) {
                    ForEach(1...4, id: \.self) { level in
                        Circle()
                            .fill(level <= intensityLevel ? Theme.Colors.primary : Theme.Colors.textTertiary)
                            .frame(width: 4, height: 4)
                            .opacity(isSelected ? 1.0 : 0.4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else {
            return Theme.Colors.text
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Theme.Colors.primary
        } else {
            return .clear
        }
    }

    private var cornerRadius: CGFloat {
        // Only round the outer corners
        if isFirst || isLast {
            return Theme.CornerRadius.sm - 2
        }
        return 0
    }
}

// MARK: - Exercise Duration Picker

struct ExerciseDurationPicker: View {
    @Binding var duration: Int

    // Common duration presets
    private let quickOptions = [15, 30, 45, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Duration")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)

            VStack(spacing: Theme.Spacing.sm) {
                // Quick select buttons
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(quickOptions, id: \.self) { minutes in
                        QuickDurationButton(
                            minutes: minutes,
                            isSelected: duration == minutes,
                            action: { duration = minutes }
                        )
                    }
                }

                // Custom duration adjuster - centered layout
                HStack(spacing: Theme.Spacing.md) {
                    // Decrement button
                    Button(action: {
                        if duration > 5 {
                            duration = max(5, duration - 5)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(duration > 5 ? Theme.Colors.primary : Theme.Colors.textTertiary)
                    }
                    .disabled(duration <= 5)

                    // Duration display with label
                    HStack(spacing: 6) {
                        Text("\(duration)")
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.Colors.text)
                            .frame(minWidth: 50, alignment: .trailing)

                        Text("min")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(width: 30, alignment: .leading)
                    }
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                            .fill(Theme.Colors.primaryLight)
                    )

                    // Increment button
                    Button(action: {
                        duration = min(180, duration + 5)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(duration < 180 ? Theme.Colors.primary : Theme.Colors.textTertiary)
                    }
                    .disabled(duration >= 180)
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.sm)
            }
        }
    }
}

// MARK: - Quick Duration Button

private struct QuickDurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(minutes)")
                    .font(Theme.Typography.headline)
                    .foregroundColor(foregroundColor)

                Text("min")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundColor(foregroundColor.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        isSelected ? .white : Theme.Colors.primary
    }

    private var backgroundColor: Color {
        isSelected ? Theme.Colors.primary : Theme.Colors.primaryLight
    }

    private var borderColor: Color {
        isSelected ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.2)
    }
}

// MARK: - Previews

#if DEBUG
struct IntensityPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Duration Picker
            ExerciseDurationPicker(duration: .constant(30))
                .padding()

            Divider()

            // Intensity Picker
            IntensityPicker(selectedIntensity: .constant(.moderate))
                .padding()
        }
        .background(Theme.Colors.background)
        .previewDisplayName("Light Mode")

        VStack(spacing: Theme.Spacing.xl) {
            // Duration Picker
            ExerciseDurationPicker(duration: .constant(45))
                .padding()

            Divider()

            // Intensity Picker
            IntensityPicker(selectedIntensity: .constant(.high))
                .padding()
        }
        .background(Theme.Colors.background)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif
