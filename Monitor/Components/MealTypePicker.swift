import SwiftUI

struct MealTypePicker: View {
    @Binding var selectedMealType: MealType

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Meal Type")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        MealTypeButton(
                            mealType: mealType,
                            isSelected: selectedMealType == mealType,
                            action: { selectedMealType = mealType }
                        )
                    }
                }
            }
        }
    }
}

struct MealTypeButton: View {
    let mealType: MealType
    let isSelected: Bool
    let action: () -> Void

    var color: Color {
        switch mealType {
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
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : Theme.Colors.cardBackground)
                        .frame(width: 60, height: 60)

                    Image(systemName: mealType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? color : Theme.Colors.textSecondary)
                }

                Text(mealType.displayName)
                    .font(Theme.Typography.caption)
                    .foregroundColor(isSelected ? Theme.Colors.text : Theme.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

// Extension for meal type suggestions
extension MealType {
    /// Suggest time period based on current time (auto-inferred, reduces decision fatigue)
    static func suggestedType(for date: Date = Date()) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<11:
            return .morning
        case 11..<15:
            return .midday
        case 15..<18:
            return .afternoon
        case 18..<22:
            return .evening
        default:
            return .night
        }
    }
}