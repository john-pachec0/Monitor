//
//  LearnHomeView.swift
//  Untwist
//
//  Learning toolkit main screen
//

import SwiftUI

struct LearnHomeView: View {
    // Group distortions by category
    private let categorizedDistortions: [(category: String, distortions: [CognitiveDistortion])] = [
        ("About Your Thinking", [.allOrNothing, .overgeneralization, .mentalFilter, .emotionalReasoning]),
        ("About Others & Yourself", [.mindReading, .personalization, .labeling, .blaming]),
        ("About the Future", [.fortuneTelling, .catastrophizing]),
        ("Minimizing the Good", [.disqualifyingPositive, .minimization]),
        ("Rigid Rules", [.shouldStatements])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // CBT Introduction Hero Card
                    cbtIntroductionHeroCard

                    // Header
                    headerSection

                    // Categorized distortions
                    ForEach(categorizedDistortions, id: \.category) { categoryGroup in
                        categorySection(
                            category: categoryGroup.category,
                            distortions: categoryGroup.distortions
                        )
                    }

                    // Bottom spacer
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Subviews

    private var cbtIntroductionHeroCard: some View {
        NavigationLink(destination: CBTIntroductionView()) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.md) {
                    // Icon
                    Image(systemName: CBTIntroduction.content.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        // "Start Here" badge
                        Text("START HERE")
                            .font(Theme.Typography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Theme.Colors.primary.opacity(0.15))
                            .cornerRadius(Theme.CornerRadius.sm)

                        Text(CBTIntroduction.content.title)
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.text)
                    }

                    Spacer()

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }

                // Description
                Text(CBTIntroduction.content.subtitle)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                    .fixedSize(horizontal: false, vertical: true)

                // Reading time
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(Theme.Typography.caption)
                    Text("\(CBTIntroduction.content.readingTimeMinutes) min read")
                        .font(Theme.Typography.caption)
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [
                        Theme.Colors.primary.opacity(0.15),
                        Theme.Colors.primaryLight.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .strokeBorder(Theme.Colors.primary.opacity(0.3), lineWidth: 2)
            )
            .shadow(
                color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.Colors.primary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("The 13 Patterns")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Common cognitive distortions")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()
            }

            Text("These are the 13 most common anxious thinking patterns. Tap any distortion to learn how to recognize and reframe it with real examples.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color,
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }

    private func categorySection(category: String, distortions: [CognitiveDistortion]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Category header
            Text(category)
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
                .padding(.horizontal, Theme.Spacing.xs)

            // Distortion cards
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(distortions, id: \.id) { distortion in
                    NavigationLink(destination: DistortionDetailView(distortion: distortion)) {
                        distortionCard(distortion)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func distortionCard(_ distortion: CognitiveDistortion) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon
            Image(systemName: distortion.icon)
                .font(.system(size: 28))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 44, height: 44)

            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(distortion.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.text)

                Text(distortion.snippet)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color.opacity(0.5),
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }
}

#Preview {
    LearnHomeView()
}
