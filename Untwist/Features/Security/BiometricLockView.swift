//
//  BiometricLockView.swift
//  Untwist
//
//  Lock screen shown when app requires biometric authentication
//

import SwiftUI

struct BiometricLockView: View {
    @EnvironmentObject private var biometricService: BiometricAuthService

    var body: some View {
        ZStack {
            // Background
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                // Lock icon
                Image(systemName: biometricIconName)
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)
                    .symbolEffect(.pulse)

                VStack(spacing: Theme.Spacing.sm) {
                    Text("Untwist is Locked")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    Text("Unlock to view your thoughts")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Unlock button
                Button {
                    Task {
                        await biometricService.authenticate()
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: biometricIconName)
                        Text("Unlock with \(biometricService.biometricTypeString)")
                    }
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .fill(Theme.Colors.primary)
                    )
                }
                .padding(.horizontal, Theme.Spacing.xl)
            }
            .padding(Theme.Spacing.xl)
        }
        .alert("Authentication Error", isPresented: .constant(biometricService.error != nil)) {
            Button("OK") {
                biometricService.error = nil
            }
            if biometricService.error == .notEnrolled {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } message: {
            if let error = biometricService.error {
                Text(error.localizedDescription)
            }
        }
        .onAppear {
            // Auto-trigger authentication on appear
            Task {
                await biometricService.authenticate()
            }
        }
    }

    private var biometricIconName: String {
        switch biometricService.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        }
    }
}
