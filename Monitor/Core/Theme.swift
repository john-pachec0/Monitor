//
//  Theme.swift
//  Monitor
//
//  Design system: calming blue/green palette, typography, spacing
//

import SwiftUI

enum Theme {
    // MARK: - Colors (Adaptive Blue/Green Palette - Equip Inspired)

    enum Colors {
        // Primary calming teal tones
        static let primary = Color(
            light: Color(red: 0.25, green: 0.65, blue: 0.70), // Calming teal
            dark: Color(red: 0.35, green: 0.75, blue: 0.80)   // Lighter teal for dark mode
        )
        static let primaryLight = Color(
            light: Color(red: 0.85, green: 0.94, blue: 0.95), // Very light teal
            dark: Color(red: 0.20, green: 0.35, blue: 0.38)   // Dark teal
        )
        static let primaryDark = Color(
            light: Color(red: 0.18, green: 0.50, blue: 0.55), // Deep teal
            dark: Color(red: 0.45, green: 0.85, blue: 0.90)   // Bright teal
        )

        // Backgrounds
        static let background = Color(
            light: Color(red: 0.97, green: 0.98, blue: 0.98), // Clean white
            dark: Color(red: 0.11, green: 0.12, blue: 0.13)   // Clean dark
        )
        static let cardBackground = Color(
            light: Color.white,
            dark: Color(red: 0.16, green: 0.17, blue: 0.18)   // Dark card
        )
        static let secondaryBackground = Color(
            light: Color(red: 0.94, green: 0.96, blue: 0.97), // Light gray-blue
            dark: Color(red: 0.20, green: 0.21, blue: 0.22)   // Darker gray
        )

        // Text
        static let text = Color(
            light: Color(red: 0.15, green: 0.18, blue: 0.20), // Cool dark gray
            dark: Color(red: 0.92, green: 0.94, blue: 0.95)   // Cool white
        )
        static let textSecondary = Color(
            light: Color(red: 0.48, green: 0.52, blue: 0.55), // Medium gray
            dark: Color(red: 0.65, green: 0.68, blue: 0.70)   // Light gray
        )
        static let textTertiary = Color(
            light: Color(red: 0.65, green: 0.68, blue: 0.70), // Light gray
            dark: Color(red: 0.45, green: 0.48, blue: 0.50)   // Medium gray
        )

        // Semantic colors
        static let success = Color(
            light: Color(red: 0.35, green: 0.70, blue: 0.55), // Teal-green
            dark: Color(red: 0.45, green: 0.80, blue: 0.65)   // Brighter teal-green
        )
        static let warning = Color(
            light: Color(red: 0.85, green: 0.70, blue: 0.40), // Soft amber
            dark: Color(red: 0.90, green: 0.78, blue: 0.50)   // Brighter amber
        )
        static let error = Color(
            light: Color(red: 0.82, green: 0.40, blue: 0.38), // Soft coral
            dark: Color(red: 0.90, green: 0.50, blue: 0.48)   // Brighter coral
        )
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Shadows
    
    enum Shadows {
        static let card = Shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let button = Shadow(
            color: Color.black.opacity(0.12),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Adaptive Colors

extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - View Extensions for Theme

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadows.button.color,
                radius: Theme.Shadows.button.radius,
                x: Theme.Shadows.button.x,
                y: Theme.Shadows.button.y
            )
    }
}
