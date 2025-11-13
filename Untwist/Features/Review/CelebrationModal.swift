//
//  CelebrationModal.swift
//  Untwist
//
//  Shows after 3rd review, explains switch to fast mode
//

import SwiftUI

struct CelebrationModal: View {
    let onDismiss: () -> Void

    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Modal content
            VStack(spacing: Theme.Spacing.xl) {
                // Celebration icon with animation
                ZStack {
                    Circle()
                        .fill(Theme.Colors.success.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showConfetti ? 1.2 : 1.0)
                        .opacity(showConfetti ? 0 : 1)

                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.Colors.success)
                        .rotationEffect(.degrees(showConfetti ? 360 : 0))
                }

                // Congratulations message
                VStack(spacing: Theme.Spacing.sm) {
                    Text("You've Got This!")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.text)

                    Text("Nice work completing your third review")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Divider()

                // Explanation of fast mode
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundColor(Theme.Colors.primary)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Switching to Fast Mode")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            Text("You've learned the distortions. From now on, you'll see a quick categorized list so you can identify patterns faster.")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(Theme.Colors.primary)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("You Can Always Go Back")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            Text("Tap the info button on any distortion to see the full details again.")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.primaryLight.opacity(0.3))
                .cornerRadius(Theme.CornerRadius.md)

                // Continue button
                Button {
                    onDismiss()
                } label: {
                    Text("Got It!")
                        .frame(maxWidth: .infinity)
                        .primaryButtonStyle()
                }
            }
            .padding(Theme.Spacing.xl)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 20,
                x: 0,
                y: 10
            )
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.6)
                .repeatForever(autoreverses: false)
            ) {
                showConfetti = true
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()

        Text("Background Content")
            .font(.title)

        CelebrationModal(onDismiss: {})
    }
}
