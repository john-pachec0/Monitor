//
//  SupportView.swift
//  Untwist
//
//  A warm, gratitude-focused view for supporting development
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                        // Header
                        headerSection

                        // Ko-fi donation option
                        donationSection

                        // Research note
                        researchSection

                        Spacer(minLength: Theme.Spacing.xxl)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationTitle("Support Untwist")
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

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.Colors.primary)

                Spacer()
            }

            Text("Thank you for being here")
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.text)

            Text("Untwist is free and always will be. No ads, no tracking, no data collection. Just a simple tool to help you reframe anxious thoughts.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("If you find it helpful, consider supporting its development.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var donationSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Support Development")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            Button {
                openURL(URL(string: "https://ko-fi.com/untwist")!)
            } label: {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 44, height: 44)
                        .background(Theme.Colors.primary.opacity(0.15))
                        .cornerRadius(Theme.CornerRadius.sm)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Buy Me a Coffee")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.text)

                        Text("One-time or monthly support via Ko-fi")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.body)
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
                .cardStyle()
            }
        }
    }

    private var researchSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Supporting CBT Research")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Advancing mental health research")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.text)

                        Text("A portion of donations supports organizations advancing CBT and mental health research.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.primary.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
        }
    }
}

#Preview {
    SupportView()
}
