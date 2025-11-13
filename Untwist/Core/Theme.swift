//
//  Theme.swift
//  Untwist
//
//  Design system: warm colors, typography, spacing
//

import SwiftUI

enum Theme {
    // MARK: - Colors (Adaptive Warm Palette)

    enum Colors {
        // Primary warm tones
        static let primary = Color(
            light: Color(red: 0.82, green: 0.52, blue: 0.38), // Warm terracotta
            dark: Color(red: 0.90, green: 0.62, blue: 0.48)   // Lighter terracotta for dark mode
        )
        static let primaryLight = Color(
            light: Color(red: 0.95, green: 0.85, blue: 0.78), // Light peach
            dark: Color(red: 0.40, green: 0.30, blue: 0.25)   // Dark peach
        )
        static let primaryDark = Color(
            light: Color(red: 0.65, green: 0.35, blue: 0.25), // Deep terracotta
            dark: Color(red: 0.95, green: 0.70, blue: 0.58)   // Bright terracotta
        )

        // Backgrounds
        static let background = Color(
            light: Color(red: 0.98, green: 0.97, blue: 0.95), // Warm white
            dark: Color(red: 0.12, green: 0.11, blue: 0.10)   // Warm black
        )
        static let cardBackground = Color(
            light: Color.white,
            dark: Color(red: 0.18, green: 0.17, blue: 0.16)   // Dark card
        )
        static let secondaryBackground = Color(
            light: Color(red: 0.96, green: 0.94, blue: 0.90), // Warm gray
            dark: Color(red: 0.22, green: 0.21, blue: 0.20)   // Darker gray
        )

        // Text
        static let text = Color(
            light: Color(red: 0.20, green: 0.18, blue: 0.17), // Warm black
            dark: Color(red: 0.95, green: 0.94, blue: 0.92)   // Warm white
        )
        static let textSecondary = Color(
            light: Color(red: 0.55, green: 0.52, blue: 0.50), // Warm gray
            dark: Color(red: 0.70, green: 0.68, blue: 0.65)   // Light warm gray
        )
        static let textTertiary = Color(
            light: Color(red: 0.70, green: 0.68, blue: 0.65), // Light warm gray
            dark: Color(red: 0.50, green: 0.48, blue: 0.45)   // Medium gray
        )

        // Semantic colors
        static let success = Color(
            light: Color(red: 0.60, green: 0.72, blue: 0.60), // Muted green
            dark: Color(red: 0.70, green: 0.85, blue: 0.70)   // Brighter green
        )
        static let warning = Color(
            light: Color(red: 0.90, green: 0.75, blue: 0.45), // Warm yellow
            dark: Color(red: 0.95, green: 0.82, blue: 0.55)   // Brighter yellow
        )
        static let error = Color(
            light: Color(red: 0.85, green: 0.45, blue: 0.40), // Muted red
            dark: Color(red: 0.95, green: 0.55, blue: 0.50)   // Brighter red
        )

        // Distortion colors (subtle, differentiated)
        static let distortion1 = Color(
            light: Color(red: 0.85, green: 0.70, blue: 0.75), // Dusty rose
            dark: Color(red: 0.60, green: 0.45, blue: 0.50)   // Dark rose
        )
        static let distortion2 = Color(
            light: Color(red: 0.75, green: 0.75, blue: 0.85), // Lavender
            dark: Color(red: 0.50, green: 0.50, blue: 0.65)   // Dark lavender
        )
        static let distortion3 = Color(
            light: Color(red: 0.75, green: 0.85, blue: 0.80), // Sage
            dark: Color(red: 0.50, green: 0.60, blue: 0.55)   // Dark sage
        )
        static let distortion4 = Color(
            light: Color(red: 0.90, green: 0.85, blue: 0.70), // Warm sand
            dark: Color(red: 0.60, green: 0.55, blue: 0.45)   // Dark sand
        )
        static let distortion5 = Color(
            light: Color(red: 0.80, green: 0.80, blue: 0.75), // Warm taupe
            dark: Color(red: 0.55, green: 0.55, blue: 0.50)   // Dark taupe
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
