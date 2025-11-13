//
//  DistortionDetailView.swift
//  Untwist
//
//  Educational detail view for each cognitive distortion
//  ~3 minute read with structured, conversational content
//

import SwiftUI

struct DistortionDetailView: View {
    let distortion: CognitiveDistortion

    private var guide: DistortionGuide? {
        DistortionGuides.guide(for: distortion)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // Header with icon and reading time
                headerSection

                if let guide = guide {
                    // What it sounds like
                    whatItSoundsLike(guide.commonPatterns)

                    // Why this happens
                    definitionSection(guide.definition)

                    // Real examples
                    realExamplesSection(guide.realWorldExamples)

                    // How to spot it
                    reflectionSection(guide.reflectionQuestions)

                    // The practice
                    reframingSection(guide.reframingTips, commonPitfall: guide.commonPitfall)

                    // Practice exercise (if available)
                    if let exercise = guide.practiceExercise {
                        practiceExerciseSection(exercise)
                    }

                    // Related patterns (if available)
                    if let relatedPatterns = guide.relatedPatterns, !relatedPatterns.isEmpty {
                        relatedPatternsSection(relatedPatterns)
                    }
                } else {
                    // Fallback
                    Text("Content coming soon...")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding()
                }

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle(distortion.displayName)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: distortion.icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(distortion.category)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("~3 min read")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func whatItSoundsLike(_ patterns: [String]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("What it sounds like:")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(patterns, id: \.self) { pattern in
                    HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                        Text("•")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.primary)
                        Text(pattern)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func definitionSection(_ definition: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Why this happens:")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Text(definition)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.primaryLight.opacity(0.2))
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func realExamplesSection(_ examples: [DistortionExample]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Real examples:")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            ForEach(examples) { example in
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(example.scenario)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.warning)
                            Text(example.distortedThought)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.success)
                            Text(example.balancedThought)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
            }
        }
    }

    private func reflectionSection(_ questions: [String]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("How to spot it:")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(questions, id: \.self) { question in
                    Text(question)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
    }

    private func reframingSection(_ tips: [String], commonPitfall: String?) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("The practice:")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.primary)
                        Text(tip)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Common pitfall (if available)
                if let pitfall = commonPitfall {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.warning)
                            Text("Common Pitfall:")
                                .font(Theme.Typography.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.Colors.text)
                        }
                        Text(pitfall)
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.warning.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [Theme.Colors.primary.opacity(0.1), Theme.Colors.primary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .strokeBorder(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func practiceExerciseSection(_ exercise: PracticeExercise) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Try It Now:")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Exercise title
                Text(exercise.title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.text)

                // Instructions
                Text(exercise.instructions)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Steps
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                            Text("\(index + 1).")
                                .font(Theme.Typography.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.Colors.primary)
                            Text(step)
                                .font(Theme.Typography.callout)
                                .foregroundColor(Theme.Colors.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .strokeBorder(Theme.Colors.primary.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func relatedPatternsSection(_ patterns: [RelatedPattern]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Related Patterns:")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(patterns) { pattern in
                    NavigationLink(destination: DistortionDetailView(distortion: pattern.distortion)) {
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Image(systemName: pattern.distortion.icon)
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(pattern.distortion.displayName)
                                    .font(Theme.Typography.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.text)

                                Text(pattern.connection)
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.textTertiary)
                        }
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.sm)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DistortionDetailView(distortion: .allOrNothing)
    }
}
