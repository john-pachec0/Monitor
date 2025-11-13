//
//  CBTIntroductionView.swift
//  Untwist
//
//  Introduction to CBT concepts and how the app works
//

import SwiftUI

struct CBTIntroductionView: View {
    @Environment(\.dismiss) private var dismiss
    private let introduction = CBTIntroduction.content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // Header
                headerSection

                // Sections
                ForEach(introduction.sections) { section in
                    sectionView(section)
                }

                // Call to action
                callToActionSection

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle("Understanding CBT")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: introduction.icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Foundation")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("~\(introduction.readingTimeMinutes) min read")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func sectionView(_ section: CBTIntroduction.Section) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section heading
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: iconForSection(section.id))
                    .foregroundColor(Theme.Colors.primary)
                Text(section.heading)
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            // Section body
            Text(markdownText(section.body))
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            // Visual metaphor (if applicable)
            if let metaphor = section.visualMetaphor {
                visualMetaphorView(metaphor)
            }
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

    private func visualMetaphorView(_ metaphor: CBTIntroduction.VisualMetaphor) -> some View {
        VStack(spacing: Theme.Spacing.sm) {
            switch metaphor {
            case .thoughtFeelingBehaviorCycle:
                thoughtFeelingBehaviorCycle
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    Theme.Colors.primary.opacity(0.1),
                    Theme.Colors.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var thoughtFeelingBehaviorCycle: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Situation
            cycleNode("Situation", icon: "exclamationmark.bubble", description: "Something happens")
            cycleArrow()

            // Thought
            cycleNode("Thought", icon: "brain.head.profile", description: "You interpret it")
            cycleArrow()

            // Feeling
            cycleNode("Feeling", icon: "heart.fill", description: "Emotion arises")
            cycleArrow()

            // Behavior
            cycleNode("Behavior", icon: "figure.walk", description: "You react")

            // Cycle back indicator
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
                Text("The cycle continues")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, Theme.Spacing.sm)
        }
    }

    private func cycleNode(_ label: String, icon: String, description: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.Colors.primary)

            Text(label)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.text)

            Text(description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private func cycleArrow() -> some View {
        Image(systemName: "arrow.down")
            .font(.title3)
            .foregroundColor(Theme.Colors.primary)
            .frame(height: 20)
    }

    private var callToActionSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Ready to begin?")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            Text("Now that you understand the foundation, let's explore the 13 cognitive distortions to learn how to recognize and reframe anxious thinking patterns.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                dismiss()
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Text("Explore The 13 Patterns")
                        .font(Theme.Typography.headline)
                    Image(systemName: "arrow.right")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.primary)
                .cornerRadius(Theme.CornerRadius.md)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Theme.Colors.primary.opacity(0.1),
                    Theme.Colors.primaryLight.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Helpers

    private func iconForSection(_ sectionId: String) -> String {
        switch sectionId {
        case "what-is-cbt":
            return "brain.head.profile"
        case "thought-feeling-behavior":
            return "arrow.triangle.2.circlepath"
        case "cognitive-distortions":
            return "lightbulb.fill"
        case "how-to-use":
            return "hand.raised.fingers.spread"
        default:
            return "book.fill"
        }
    }

    private func markdownText(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            // Fallback to plain text if markdown parsing fails
            return AttributedString(markdown)
        }
    }
}

#Preview {
    NavigationStack {
        CBTIntroductionView()
    }
}
