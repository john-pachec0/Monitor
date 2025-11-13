//
//  SettingsView.swift
//  Untwist
//
//  Configure worry time notifications and review preferences
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if let userSettings = settings.first {
                    SettingsForm(userSettings: userSettings)
                } else {
                    // This should never happen since settings are created at app launch
                    ProgressView()
                }
            }
            .navigationTitle("Settings")
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

// MARK: - Settings Form

struct SettingsForm: View {
    @Bindable var userSettings: UserSettings
    @EnvironmentObject private var biometricService: BiometricAuthService
    @State private var showingFeedback = false
    @State private var showingSupport = false
    @State private var showingMentalHealthResources = false
    @State private var showingArchive = false
    @State private var showPermissionDeniedAlert = false

    var body: some View {
        Form {
            // Worry Time Section
            Section {
                DatePicker(
                    "Review Time",
                    selection: $userSettings.preferredReviewTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .onChange(of: userSettings.preferredReviewTime) { oldValue, newValue in
                    // Reschedule notification if enabled
                    if userSettings.notificationsEnabled {
                        NotificationService.shared.scheduleWorryTimeReminder(at: newValue)
                    }
                }
            } header: {
                Text("Worry Time")
            } footer: {
                Text("Set your daily worry time - a dedicated moment to review and reframe your thoughts.")
                    .font(Theme.Typography.footnote)
            }

            // Notifications Section
            Section {
                Toggle(
                    "Daily Reminders",
                    isOn: $userSettings.notificationsEnabled
                )
                .onChange(of: userSettings.notificationsEnabled) { oldValue, newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        NotificationService.shared.cancelWorryTimeReminder()
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Get a gentle reminder at your worry time to review captured thoughts.")
                    .font(Theme.Typography.footnote)
            }

            // Capture Settings Section
            Section {
                Toggle(
                    "Rate anxiety when capturing",
                    isOn: $userSettings.rateAnxietyAtCapture
                )
            } header: {
                Text("Capture Settings")
            } footer: {
                Text("Track how postponing worries affects your anxiety by rating it when you first capture a thought and again when you review it.")
                    .font(Theme.Typography.footnote)
            }

            // Privacy & Security Section
            Section {
                if biometricService.isBiometricAvailable {
                    Toggle(isOn: $userSettings.requiresBiometricAuth) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: biometricService.biometricType == .faceID ? "faceid" : "touchid")
                                .foregroundColor(Theme.Colors.primary)
                            Text("Require \(biometricService.biometricTypeString)")
                        }
                    }
                    .tint(Theme.Colors.primary)
                } else {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "lock.slash")
                            .foregroundColor(Theme.Colors.textTertiary)
                        Text("Biometric authentication not available")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            } header: {
                Text("Privacy & Security")
            } footer: {
                Text(biometricService.isBiometricAvailable
                     ? "Unlock the app using \(biometricService.biometricTypeString) when you open it or return from background."
                     : "This device does not support Face ID or Touch ID, or it has not been set up yet.")
                    .font(Theme.Typography.footnote)
            }

            // About Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                HStack {
                    Text("Framework")
                    Spacer()
                    Text("CBT")
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Link(destination: URL(string: "https://google.com")!) {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                Link(destination: URL(string: "https://google.com")!) {
                    HStack {
                        Text("Terms of Service")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                Button {
                    showingMentalHealthResources = true
                } label: {
                    HStack {
                        Text("Mental Health Resources")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "heart.text.square")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                Button {
                    showingArchive = true
                } label: {
                    HStack {
                        Text("Archive")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "archivebox")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            } header: {
                Text("About")
            } footer: {
                Text("View historical thoughts from previous days. Archived thoughts are automatically deleted after 30 days.")
                    .font(Theme.Typography.footnote)
            }

            // Support Section
            Section {
                Button {
                    showingSupport = true
                } label: {
                    HStack {
                        Text("Support Untwist")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            } header: {
                Text("Support")
            } footer: {
                Text("Untwist is free and always will be. If you find it helpful, consider supporting its development.")
                    .font(Theme.Typography.footnote)
            }

            // Feedback Section
            Section {
                Button {
                    showingFeedback = true
                } label: {
                    HStack {
                        Text("Send Feedback")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "paperplane")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            } header: {
                Text("Feedback")
            } footer: {
                Text("Share bugs, feature requests, or general thoughts. Your feedback helps make Untwist better.")
                    .font(Theme.Typography.footnote)
            }

            // Debug Section (for development)
            #if DEBUG
            Section {
                Button {
                    resetOnboarding()
                } label: {
                    HStack {
                        Text("Reset Onboarding")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Debug")
            } footer: {
                Text("For testing: Reset the onboarding flow. Close and reopen the app to see onboarding again.")
                    .font(Theme.Typography.footnote)
            }
            #endif
        }
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showingFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showingSupport) {
            SupportView()
        }
        .sheet(isPresented: $showingMentalHealthResources) {
            MentalHealthResourcesView()
        }
        .sheet(isPresented: $showingArchive) {
            ArchiveView()
        }
        .alert("Enable Notifications in Settings", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("To receive reminders for your worry time, please enable notifications in Settings > Untwist > Notifications.")
        }
    }

    private func requestNotificationPermission() {
        NotificationService.shared.requestPermission { granted in
            if granted {
                // Schedule the notification
                NotificationService.shared.scheduleWorryTimeReminder(at: userSettings.preferredReviewTime)
            } else {
                // Permission denied, turn off toggle and show helpful alert
                userSettings.notificationsEnabled = false
                showPermissionDeniedAlert = true
            }
        }
    }

    #if DEBUG
    private func resetOnboarding() {
        userSettings.hasCompletedOnboarding = false
        userSettings.distortionReviewCount = 0
        userSettings.hasSeenDistortionTutorial = false
        userSettings.prefersFastMode = false
    }
    #endif
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self])
}
