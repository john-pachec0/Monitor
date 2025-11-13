//
//  SettingsView.swift
//  Monitor
//
//  Configure notifications, care team, and app preferences
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
            // Meal Reminders Section
            Section {
                DatePicker(
                    "Breakfast",
                    selection: $userSettings.breakfastReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)

                DatePicker(
                    "Lunch",
                    selection: $userSettings.lunchReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)

                DatePicker(
                    "Dinner",
                    selection: $userSettings.dinnerReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)

                DatePicker(
                    "Evening Check-In",
                    selection: $userSettings.eveningCheckInTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            } header: {
                Text("Meal Reminders")
            } footer: {
                Text("Set times for gentle meal reminders and evening reflection.")
                    .font(Theme.Typography.footnote)
            }

            // Notifications Section
            Section {
                Toggle(
                    "Notifications Enabled",
                    isOn: $userSettings.notificationsEnabled
                )
                .onChange(of: userSettings.notificationsEnabled) { oldValue, newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        NotificationService.shared.cancelReviewTimeReminder()
                    }
                }

                if userSettings.notificationsEnabled {
                    Toggle(
                        "Meal Reminders",
                        isOn: $userSettings.mealRemindersEnabled
                    )

                    Toggle(
                        "Evening Check-In",
                        isOn: $userSettings.eveningCheckInEnabled
                    )
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text(userSettings.notificationsEnabled ?
                     "Receive gentle reminders to support your recovery journey." :
                     "Enable notifications to receive meal reminders and supportive messages.")
                    .font(Theme.Typography.footnote)
            }

            // Care Team Section
            Section {
                NavigationLink {
                    CareTeamView(settings: userSettings)
                } label: {
                    HStack {
                        Label("Care Team", systemImage: "person.2.fill")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        if !userSettings.careTeam.isEmpty {
                            Text("\(userSettings.careTeam.count)")
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }

                if userSettings.careTeam.isEmpty {
                    // Show quick emergency contact fields when no care team
                    TextField("Emergency Contact", text: Binding(
                        get: { userSettings.emergencyContact ?? "" },
                        set: { userSettings.emergencyContact = $0.isEmpty ? nil : $0 }
                    ))

                    TextField("Emergency Phone", text: Binding(
                        get: { userSettings.emergencyPhone ?? "" },
                        set: { userSettings.emergencyPhone = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.phonePad)
                }
            } header: {
                Text("Care Team & Emergency Contacts")
            } footer: {
                if userSettings.careTeam.isEmpty {
                    Text("Add your care team members (dietitians, therapists, doctors) to keep their contact information handy. All information stays private on your device.")
                        .font(Theme.Typography.footnote)
                } else {
                    Text("Your care team information is stored privately on your device and can be included in PDF exports.")
                        .font(Theme.Typography.footnote)
                }
            }

            // Display Preferences Section
            Section {
                Toggle(
                    "Show Photos in List",
                    isOn: $userSettings.showPhotosInList
                )
            } header: {
                Text("Display Preferences")
            } footer: {
                Text("Choose whether to display meal photos in the journal list view.")
                    .font(Theme.Typography.footnote)
            }

            // Data Management Section
            Section {
                HStack {
                    Text("Auto-Archive After")
                    Spacer()
                    Text("\(userSettings.autoArchiveAfterDays) days")
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("Entries older than \(userSettings.autoArchiveAfterDays) days will be automatically archived.")
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
                    Text("Focus")
                    Spacer()
                    Text("ED Recovery")
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
                Text("View historical meal entries. Archived entries are automatically deleted after \(userSettings.autoArchiveAfterDays) days.")
                    .font(Theme.Typography.footnote)
            }

            // Support Section
            Section {
                Button {
                    showingSupport = true
                } label: {
                    HStack {
                        Text("Support Monitor")
                            .foregroundColor(Theme.Colors.text)
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            } header: {
                Text("Support")
            } footer: {
                Text("Monitor is free and always will be. If you find it helpful, consider supporting its development.")
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
                Text("Share bugs, feature requests, or general thoughts. Your feedback helps make Monitor better.")
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
            Text("To receive reminders for your daily review, please enable notifications in Settings > Monitor > Notifications.")
        }
    }

    private func requestNotificationPermission() {
        NotificationService.shared.requestPermission { granted in
            if granted {
                // Schedule meal reminders if enabled
                // TODO: Implement meal reminder scheduling in Phase 2
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
        userSettings.hasSeenMealEntryTutorial = false
        userSettings.hasSeenBehaviorTutorial = false
        userSettings.hasSeenReviewTutorial = false
        userSettings.mealEntryCount = 0
    }
    #endif
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self])
}
