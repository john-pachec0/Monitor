//
//  OnboardingView.swift
//  Untwist
//
//  First-launch onboarding explaining CBT and how the app works
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 3

    // Force TabView to recreate when onboarding is shown
    private let onboardingID = UUID()

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button - keep space reserved on all pages for consistent layout
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)
                    .opacity(currentPage < totalPages - 1 ? 1 : 0)
                    .disabled(currentPage >= totalPages - 1)
                }

                // Content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    CombinedHowItWorksPage()
                        .tag(1)

                    PrivacyPage()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .id(onboardingID) // Force recreation on each onboarding instance

                // Custom progress dots
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Theme.Colors.primary : Theme.Colors.textTertiary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, Theme.Spacing.sm)

                // Navigation - consistent button position across all pages
                Button {
                    if currentPage < totalPages - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                        .frame(maxWidth: .infinity)
                        .primaryButtonStyle()
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        onComplete()
        dismiss()
    }
}

// MARK: - Page 1: Welcome

struct WelcomePage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                // Twisted → Straight line visual
                TwistedLineGraphic()
                    .frame(height: 120)

                Text("Welcome to Untwist")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.text)
                    .multilineTextAlignment(.center)

                Text("Your pocket CBT companion for transforming anxious thoughts")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Theme.Spacing.xl)

                Text("Evidence-based CBT techniques")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Page 2: Combined How It Works + Worry Scheduling

struct CombinedHowItWorksPage: View {
    @Query private var settings: [UserSettings]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                // Reduced top spacing
                Spacer().frame(height: Theme.Spacing.sm)

                Text("How It Works")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.text)

                // Compact step cards with reduced spacing
                VStack(spacing: Theme.Spacing.sm) {
                    StepCard(
                        icon: "square.and.pencil",
                        title: "Capture",
                        description: "When anxiety strikes, quickly capture the thought. We'll look at it together later."
                    )

                    StepCard(
                        icon: "magnifyingglass",
                        title: "Notice",
                        description: "Identify cognitive distortions - the thinking patterns that make anxiety worse."
                    )

                    StepCard(
                        icon: "sparkles",
                        title: "Reframe",
                        description: "Create a more balanced perspective. With practice, this becomes second nature."
                    )
                }
                .padding(.horizontal, Theme.Spacing.lg)

                // Reduced spacing before divider
                Divider()
                    .padding(.vertical, Theme.Spacing.xs)

                // Worry time scheduling section - this will peek at the bottom
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.Colors.primary)

                    Text("Schedule Your Worry Time")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)

                    Text("Research shows that scheduling a specific time each day to review your worries reduces all-day anxiety. Outside this time, we'll gently remind you to wait—and you can always choose to review anyway if needed.")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Theme.Spacing.lg)
                }

                // Time picker section
                if let userSettings = settings.first {
                    WorryTimePickerSection(userSettings: userSettings)
                }

                Spacer().frame(height: Theme.Spacing.xl)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Worry Time Picker Section

struct WorryTimePickerSection: View {
    @Bindable var userSettings: UserSettings
    @State private var showPermissionDeniedAlert = false

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Choose Your Worry Time")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.text)

            DatePicker(
                "Daily Review Time",
                selection: $userSettings.preferredReviewTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.Spacing.lg)

            // Notification toggle
            VStack(spacing: Theme.Spacing.xs) {
                Toggle(isOn: Binding(
                    get: { userSettings.notificationsEnabled },
                    set: { newValue in
                        userSettings.notificationsEnabled = newValue
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            NotificationService.shared.cancelWorryTimeReminder()
                        }
                    }
                )) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(Theme.Colors.primary)
                        Text("Remind me daily")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.primary))
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.sm)
            }

            Text("You can change this anytime in Settings")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textTertiary)
                .padding(.top, Theme.Spacing.xs)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.md)
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
            DispatchQueue.main.async {
                if granted {
                    // Schedule the notification
                    NotificationService.shared.scheduleWorryTimeReminder(at: self.userSettings.preferredReviewTime)
                } else {
                    // Permission denied, turn off toggle and show helpful alert
                    self.userSettings.notificationsEnabled = false
                    self.showPermissionDeniedAlert = true
                }
            }
        }
    }
}

// MARK: - Disclaimer Sheet (Deprecated - now integrated into PrivacyPage)

/*
struct DisclaimerSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
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
                            DisclaimerPoint(text: "A substitute for professional therapy or counseling")
                            DisclaimerPoint(text: "Medical or mental health advice")
                            DisclaimerPoint(text: "A diagnostic tool")
                            DisclaimerPoint(text: "Designed for crisis situations")
                            DisclaimerPoint(text: "Suitable for treating serious mental health conditions")
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

                    // Crisis Resources
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("If you're in crisis:")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.text)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            CrisisResource(
                                icon: "phone.fill",
                                title: "Call 988",
                                subtitle: "Suicide & Crisis Lifeline"
                            )

                            CrisisResource(
                                icon: "message.fill",
                                title: "Text \"HOME\" to 741741",
                                subtitle: "Crisis Text Line"
                            )
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Important Information")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
*/

// MARK: - Old Mental Health Resources Page (Removed)

struct MentalHealthResourcesPage_Removed: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Spacer().frame(height: Theme.Spacing.md)

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
                .padding(.horizontal, Theme.Spacing.md)

                // Crisis Resources
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("If you're in crisis or experiencing suicidal thoughts:")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)

                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        CrisisResource(
                            icon: "phone.fill",
                            title: "Call 988",
                            subtitle: "Suicide & Crisis Lifeline"
                        )

                        CrisisResource(
                            icon: "message.fill",
                            title: "Text \"HOME\" to 741741",
                            subtitle: "Crisis Text Line"
                        )

                        CrisisResource(
                            icon: "staroflife.fill",
                            title: "Call 911",
                            subtitle: "Or go to your nearest emergency room"
                        )
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.primary.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.md)
                .padding(.horizontal, Theme.Spacing.md)

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
                .padding(.horizontal, Theme.Spacing.md)

                // What Untwist Is Not
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("What Untwist Is Not")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        DisclaimerPoint(text: "A substitute for professional therapy or counseling")
                        DisclaimerPoint(text: "Medical or mental health advice")
                        DisclaimerPoint(text: "A diagnostic tool")
                        DisclaimerPoint(text: "Designed for crisis situations")
                        DisclaimerPoint(text: "Suitable for treating serious mental health conditions")
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)

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
                .padding(.horizontal, Theme.Spacing.md)

                Spacer().frame(height: Theme.Spacing.xl)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Crisis Resource Component

struct CrisisResource: View {
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

// MARK: - Disclaimer Point Component

struct DisclaimerPoint: View {
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

// MARK: - Page 3: Privacy & Important Information

struct PrivacyPage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Reduced top spacing for scrollable content
                Spacer().frame(height: Theme.Spacing.md)

                // Privacy Section
                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.Colors.primary)

                    Text("Your Thoughts\nStay Private")
                        .font(Theme.Typography.largeTitle)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        PrivacyPoint(text: "All data stays on your device")
                        PrivacyPoint(text: "No cloud sync or accounts required")
                        PrivacyPoint(text: "No tracking or data collection")
                        PrivacyPoint(text: "What you write is completely private")
                    }
                    .padding(.horizontal, Theme.Spacing.xl)

                    Text("Your mental health journey belongs to you")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Theme.Spacing.xl)
                }

                // Divider
                Divider()
                    .padding(.vertical, Theme.Spacing.sm)

                // Important Information Section
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Section Header
                    Text("Important Information")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .center)

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
                            DisclaimerPoint(text: "A substitute for professional therapy or counseling")
                            DisclaimerPoint(text: "Medical or mental health advice")
                            DisclaimerPoint(text: "A diagnostic tool")
                            DisclaimerPoint(text: "Designed for crisis situations")
                            DisclaimerPoint(text: "Suitable for treating serious mental health conditions")
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

                    // Crisis Resources
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("If you're in crisis:")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.text)

                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            CrisisResource(
                                icon: "phone.fill",
                                title: "Call 988",
                                subtitle: "Suicide & Crisis Lifeline"
                            )

                            CrisisResource(
                                icon: "message.fill",
                                title: "Text \"HOME\" to 741741",
                                subtitle: "Crisis Text Line"
                            )
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                Spacer().frame(height: Theme.Spacing.xl)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Supporting Components

struct TwistedLineGraphic: View {
    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            // Twisted line
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.Colors.textTertiary)
                
                Text("Anxious")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Image(systemName: "arrow.right")
                .font(.title)
                .foregroundColor(Theme.Colors.primary)
            
            // Straight line
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.Colors.primary)
                
                Text("Balanced")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

struct StepCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.text)

                Text(description)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrivacyPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Theme.Colors.success)
                .font(.title3)

            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.text)

                Text(description)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
