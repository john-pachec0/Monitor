//
//  ReviewedThoughtSummaryView.swift
//  Untwist
//
//  Read-only summary view for already-reviewed thoughts
//  Shows reframed thought, anxiety transformation with abstract symbols, and de-emphasized original worry
//

import SwiftUI
import SwiftData

// MARK: - Custom Shapes for Anxiety Symbols

/// Two straight flat lines for low anxiety (1-3)
struct CalmLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // First straight line (upper) - more separation
            path.move(to: CGPoint(x: 0, y: height * 0.3))
            path.addLine(to: CGPoint(x: width, y: height * 0.3))

            // Second straight line (lower) - more separation
            path.move(to: CGPoint(x: 0, y: height * 0.7))
            path.addLine(to: CGPoint(x: width, y: height * 0.7))
        }
    }
}

/// Two even sine waves for medium anxiety (4-6)
struct UnsettledWavesShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // Draw 2 even sine waves with more separation
            for yOffset in [height * 0.3, height * 0.7] {
                path.move(to: CGPoint(x: 0, y: yOffset))

                let wavelength = width / 2.5
                let amplitude = height * 0.12

                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / wavelength
                    let sine = sin(relativeX * 2 * .pi)
                    let y = yOffset + (sine * amplitude)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

/// Two even sawtooth waves for high anxiety (7-10)
struct JaggedWavesShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // Draw 2 even sawtooth waves with more separation
            for yOffset in [height * 0.3, height * 0.7] {
                path.move(to: CGPoint(x: 0, y: yOffset))

                let segments = 12
                let amplitude = height * 0.15

                for i in 1...segments {
                    let x = (Double(i) / Double(segments)) * width
                    // Alternate up and down for even sawtooth effect
                    let direction: Double = i % 2 == 0 ? 1 : -1
                    let y = yOffset + (direction * amplitude)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Interpolate between two colors
    func interpolate(to color: Color, amount: Double) -> Color {
        let amount = max(0, min(1, amount))

        // Convert to RGB components (simplified)
        // Note: This is a simplified version. For production, you might want to use UIColor/NSColor
        return Color(
            red: self.components.red + (color.components.red - self.components.red) * amount,
            green: self.components.green + (color.components.green - self.components.green) * amount,
            blue: self.components.blue + (color.components.blue - self.components.blue) * amount
        )
    }

    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }

        return (Double(r), Double(g), Double(b), Double(o))
    }
}

// MARK: - Main Summary View

struct ReviewedThoughtSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var thought: AnxiousThought

    @State private var showingEditMode = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Reframed thought (prominent)
                reframedThoughtCard

                // Anxiety transformation graphic
                anxietyTransformationView

                // Distortions
                if !thought.distortions.isEmpty {
                    distortionChips
                }

                // Review info
                reviewInfoText

                // Original worry (de-emphasized)
                originalWorryCard

                Spacer(minLength: 100)
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle("Review Summary")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            editButton
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.background)
        }
        .sheet(isPresented: $showingEditMode) {
            NavigationStack {
                ReviewThoughtView(thought: thought)
            }
        }
    }

    // MARK: - Subviews

    private var reframedThoughtCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Reframed Thought")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            Text(thought.reframe ?? "")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color,
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }

    private var anxietyTransformationView: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Before anxiety symbol
            VStack(spacing: Theme.Spacing.xs) {
                anxietySymbol(for: thought.emotionBefore ?? 5)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .frame(width: 80, height: 80)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                anxietyColor(for: thought.emotionBefore ?? 5),
                                anxietyColor(for: thought.emotionBefore ?? 5).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("\(thought.emotionBefore ?? 5)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()

            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Theme.Colors.textSecondary)

            Spacer()

            // After anxiety symbol
            VStack(spacing: Theme.Spacing.xs) {
                anxietySymbol(for: thought.emotionAfter ?? 5)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .frame(width: 80, height: 80)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                anxietyColor(for: thought.emotionAfter ?? 5),
                                anxietyColor(for: thought.emotionAfter ?? 5).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("\(thought.emotionAfter ?? 5)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color,
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }

    private var distortionChips: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Patterns Identified")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            FlowLayout(spacing: Theme.Spacing.xs) {
                ForEach(thought.distortions) { distortion in
                    Text(distortion.displayName)
                        .font(Theme.Typography.caption)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Colors.secondaryBackground)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color,
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }

    private var reviewInfoText: some View {
        Group {
            if let reviewedAt = thought.reviewedAt {
                Text("Reviewed \(reviewedAt, style: .date) at \(reviewedAt, style: .time)")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
    }

    private var originalWorryCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Original thought:")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textTertiary)
                .textCase(.uppercase)

            Text(thought.content)
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var editButton: some View {
        Button {
            showingEditMode = true
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "pencil")
                Text("Edit Review")
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    // MARK: - Helper Functions

    /// Get appropriate anxiety symbol shape based on level
    private func anxietySymbol(for level: Int) -> some Shape {
        let level = max(1, min(10, level))

        if level <= 3 {
            return AnyShape(CalmLinesShape())
        } else if level <= 6 {
            return AnyShape(UnsettledWavesShape())
        } else {
            return AnyShape(JaggedWavesShape())
        }
    }

    /// Get color for anxiety level with gradient
    private func anxietyColor(for level: Int) -> Color {
        let level = max(1, min(10, level))

        if level <= 3 {
            // Low anxiety (1-3): Green to light green
            let t = Double(level - 1) / 2.0
            return Color.green.interpolate(to: Color.green.opacity(0.6), amount: t)
        } else if level <= 6 {
            // Medium anxiety (4-6): Greenyellow to yellow
            let t = Double(level - 4) / 2.0
            return Color(red: 0.68, green: 0.85, blue: 0.3).interpolate(to: Color.yellow, amount: t)
        } else {
            // High anxiety (7-10): Light orange to deep orange
            let t = Double(level - 7) / 3.0
            return Color.orange.opacity(0.7).interpolate(to: Color.orange, amount: t)
        }
    }
}

// MARK: - Type-erased Shape

struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - FlowLayout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth, currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReviewedThoughtSummaryView(
            thought: AnxiousThought(
                content: "I'm going to fail this presentation and everyone will think I'm incompetent",
                isReviewed: true,
                reviewedAt: Date(),
                distortions: [.catastrophizing, .fortuneTelling, .mindReading],
                reframe: "I've prepared well and even if I make some mistakes, that's normal. My colleagues are supportive and understand that presentations can be challenging.",
                emotionBefore: 8,
                emotionAfter: 4
            )
        )
    }
    .modelContainer(for: AnxiousThought.self, inMemory: true)
}
