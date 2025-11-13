//
//  TooltipView.swift
//  Untwist
//
//  Onboarding tooltip component with arrow pointer
//

import SwiftUI

/// Arrow direction for tooltip pointer
enum TooltipArrowDirection {
    case up
    case down
    case left
    case right
}

/// Tooltip view for onboarding hints and feature discovery
struct TooltipView: View {
    let message: String
    let arrowDirection: TooltipArrowDirection
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .down {
                arrowShape
            }

            // Tooltip content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Theme.Colors.primary)

                    Text(message)
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }

                // Dismiss hint
                Text("Tap to dismiss")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.cardBackground)
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
            )

            if arrowDirection == .up {
                arrowShape
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPresented = false
            }
        }
    }

    private var arrowShape: some View {
        Triangle()
            .fill(Theme.Colors.cardBackground)
            .frame(width: 20, height: 10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: arrowDirection == .up ? -1 : 1)
    }
}

/// Triangle shape for tooltip arrow
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// View extension to easily add tooltip overlay
extension View {
    func tooltip(
        message: String,
        arrowDirection: TooltipArrowDirection,
        isPresented: Binding<Bool>,
        alignment: Alignment = .top
    ) -> some View {
        overlay(alignment: alignment) {
            if isPresented.wrappedValue {
                TooltipView(
                    message: message,
                    arrowDirection: arrowDirection,
                    isPresented: isPresented
                )
                .padding(Theme.Spacing.md)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
