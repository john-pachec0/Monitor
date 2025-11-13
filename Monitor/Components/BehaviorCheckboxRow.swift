import SwiftUI

struct BehaviorCheckboxRow: View {
    let label: String
    let icon: String?
    @Binding var isChecked: Bool
    @Binding var amount: Int?
    let showAmount: Bool
    let amountLabel: String?
    let unit: String?

    init(
        label: String,
        icon: String? = nil,
        isChecked: Binding<Bool>,
        amount: Binding<Int?> = .constant(nil),
        showAmount: Bool = false,
        amountLabel: String? = nil,
        unit: String? = nil
    ) {
        self.label = label
        self.icon = icon
        self._isChecked = isChecked
        self._amount = amount
        self.showAmount = showAmount
        self.amountLabel = amountLabel
        self.unit = unit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.sm) {
                // Checkbox
                Button(action: { isChecked.toggle() }) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .font(.system(size: 22))
                            .foregroundColor(isChecked ? Theme.Colors.primary : Theme.Colors.textSecondary)

                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }

                        Text(label)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                    }
                }

                Spacer()
            }

            // Amount field (if applicable)
            if showAmount && isChecked {
                HStack(spacing: Theme.Spacing.sm) {
                    if let amountLabel = amountLabel {
                        Text(amountLabel)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                    Picker("", selection: Binding(
                        get: { amount ?? 1 },
                        set: { amount = $0 }
                    )) {
                        ForEach(1...20, id: \.self) { num in
                            Text("\(num)")
                                .tag(num)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.Colors.primary)

                    if let unit = unit {
                        Text(unit)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(.leading, 30)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isChecked)
    }
}