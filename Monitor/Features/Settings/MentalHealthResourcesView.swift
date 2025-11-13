//
//  MentalHealthResourcesView.swift
//  Monitor
//
//  Health and recovery resources with important disclaimers
//

import SwiftUI

struct MentalHealthResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                        // Header
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("You're Not Alone")
                                .font(Theme.Typography.largeTitle)
                                .foregroundColor(Theme.Colors.text)

                            Text("Monitor is here to support you, but it's important to know when to reach out for additional help.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Crisis Resources
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("If you're in crisis or need immediate support:")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                CrisisResourceRow(
                                    icon: "message.fill",
                                    title: "Text \"NEDA\" to 741741",
                                    subtitle: "National Eating Disorders Association"
                                )

                                CrisisResourceRow(
                                    icon: "phone.fill",
                                    title: "Call 988",
                                    subtitle: "Suicide & Crisis Lifeline"
                                )

                                CrisisResourceRow(
                                    icon: "staroflife.fill",
                                    title: "Call 911",
                                    subtitle: "Or go to your nearest emergency room"
                                )
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .cornerRadius(Theme.CornerRadius.md)

                        // What Monitor Is
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("What Monitor Is")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            Text("Monitor is a self-monitoring tool for tracking eating patterns and building awareness around food and nutrition. It's designed to help you recognize patterns, behaviors, and emotional connections to eating in a mindful, non-judgmental way.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // What Monitor Is Not
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("What Monitor Is Not")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                DisclaimerBullet(text: "A substitute for professional treatment, therapy, or medical care")
                                DisclaimerBullet(text: "Medical, nutritional, or mental health advice")
                                DisclaimerBullet(text: "A diagnostic tool or meal plan creator")
                                DisclaimerBullet(text: "Designed for crisis situations or acute care")
                                DisclaimerBullet(text: "Suitable for treating eating disorders or serious conditions without professional support")
                            }
                        }

                        // Professional Care Notice
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(Theme.Colors.primary)
                                    .font(.title3)

                                Text("If you have a diagnosed eating disorder or are under professional care, please consult your provider before using this app. This tool works best as a supplement to professional treatment.")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)

                        Spacer(minLength: Theme.Spacing.xxl)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Health & Recovery Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct CrisisResourceRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.primary)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                    .bold()

                Text(subtitle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

struct DisclaimerBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
            Text("•")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)

            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    MentalHealthResourcesView()
}
