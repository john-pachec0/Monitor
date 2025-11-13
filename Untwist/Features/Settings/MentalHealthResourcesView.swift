//
//  MentalHealthResourcesView.swift
//  Untwist
//
//  Mental health resources and important disclaimers
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

                            Text("Untwist is here to support you, but it's important to know when to reach out for additional help.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Crisis Resources
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("If you're in crisis or experiencing suicidal thoughts:")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                CrisisResourceRow(
                                    icon: "phone.fill",
                                    title: "Call 988",
                                    subtitle: "Suicide & Crisis Lifeline"
                                )

                                CrisisResourceRow(
                                    icon: "message.fill",
                                    title: "Text \"HOME\" to 741741",
                                    subtitle: "Crisis Text Line"
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

                        // What Untwist Is
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("What Untwist Is")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            Text("Untwist is a journaling tool based on cognitive behavioral therapy strategies. It's designed to help you recognize and reframe anxious thought patterns.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // What Untwist Is Not
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("What Untwist Is Not")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                DisclaimerBullet(text: "A substitute for professional therapy or counseling")
                                DisclaimerBullet(text: "Medical or mental health advice")
                                DisclaimerBullet(text: "A diagnostic tool")
                                DisclaimerBullet(text: "Designed for crisis situations")
                                DisclaimerBullet(text: "Suitable for treating serious mental health conditions")
                            }
                        }

                        // Professional Care Notice
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(Theme.Colors.primary)
                                    .font(.title3)

                                Text("If you have a diagnosed mental health condition or are under professional care, please consult your provider before using this app.")
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
            .navigationTitle("Mental Health Resources")
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
