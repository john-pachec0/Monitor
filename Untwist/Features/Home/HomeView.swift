//
//  HomeView.swift
//  Untwist
//
//  Main screen: Clean slate for capturing worries
//  Worries are hidden in the Worry Box until review time
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var thoughts: [AnxiousThought]
    @Query private var settings: [UserSettings]

    @State private var showingCapture = false
    @State private var showingSettings = false
    @State private var showingWorryBox = false
    @State private var showingLearn = false
    @State private var showScheduleReminder = false
    @State private var showThoughtSavedToast = false
    @State private var animateWorryBoxIcon = false
    @State private var showWorryTimeInfo = false
    @State private var showLockAlertWithOption = false

    var userSettings: UserSettings? {
        settings.first
    }

    var formattedWorryTime: String {
        guard let userSettings = userSettings else { return "8:00 PM" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: userSettings.preferredReviewTime)
    }

    private var isOutsideScheduledTime: Bool {
        guard let settings = userSettings else {
            return false
        }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settings.preferredReviewTime)

        // Check if current time is within ±30 minutes of scheduled time
        guard let scheduledHour = components.hour,
              let scheduledMinute = components.minute else {
            return false
        }

        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let nowMinutes = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
        let scheduledMinutes = scheduledHour * 60 + scheduledMinute
        let difference = abs(nowMinutes - scheduledMinutes)

        return difference > 30 // Outside 30-minute window
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Clean slate content
                    mainContent

                    Spacer()

                    // Worry time indicator
                    worryTimeIndicator
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.sm)

                    // Bottom capture button
                    captureButton
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Untwist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens app settings")
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // TikTok-style vertical icon stack on right side
                verticalIconStack
                    .padding(.trailing, Theme.Spacing.md)
                    .padding(.bottom, 180) // Position above capture button
            }
            .onAppear {
                // Increment pulse count for Learn icon animation
                if let settings = userSettings, settings.learnIconPulseCount < 3 {
                    settings.learnIconPulseCount += 1
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureThoughtView(onSaved: {
                    showThoughtSavedToast = true

                    // Animate worry box icon to show thought was sent there
                    animateWorryBoxIcon = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        animateWorryBoxIcon = false
                    }
                })
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showWorryTimeInfo) {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                            Text("Research shows that scheduling a specific time each day to review your worries actually reduces all-day anxiety.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)

                            Text("How It Works")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            Text("Instead of ruminating constantly, your brain learns: \"We'll deal with this later at \(formattedWorryTime).\" During your worry time, you'll review your thoughts and practice reframing them.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)

                            Text("Outside your scheduled time, Untwist gently reminds you to wait. Many worries lose their intensity over time, and postponing review helps break the cycle of rumination.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.text)

                            Text("Of course, you can always choose to review anyway if you feel it's important.")
                                .font(Theme.Typography.callout)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(Theme.Spacing.lg)
                    }
                    .background(Theme.Colors.background.ignoresSafeArea())
                    .navigationTitle("Why Worry Time?")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showWorryTimeInfo = false
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showingWorryBox) {
                WorryBoxView()
            }
            .navigationDestination(isPresented: $showingLearn) {
                LearnHomeView()
            }
            .alert("Scheduled Worry Time", isPresented: $showScheduleReminder) {
                Button("Wait Until \(formattedWorryTime)", role: .cancel) {
                    // Just dismiss
                }
                Button("Review Anyway") {
                    showingWorryBox = true
                }
                if userSettings?.showWorryTimeLockAlert == true {
                    Button("Don't Show This Again") {
                        userSettings?.showWorryTimeLockAlert = false
                        showingWorryBox = true
                    }
                }
            } message: {
                if let time = userSettings?.preferredReviewTime {
                    Text("Your worry time is at \(time, format: .dateTime.hour().minute()). One benefit of postponing review is that many worries lose their intensity over time.\n\nWould you like to wait, or review your thoughts now?")
                }
            }
            .toast(message: "Thought saved", isPresented: $showThoughtSavedToast)
        }
    }

    // MARK: - Subviews

    private var mainContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
                .frame(maxHeight: 60) // Limited top spacer to push content higher

            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.textTertiary.opacity(0.6))
                .padding(.bottom, Theme.Spacing.sm)
                .symbolEffect(.pulse, options: .repeating.speed(0.3))
                .accessibilityLabel("Untwist Home")
                .accessibilityHidden(true)

            Text(thoughts.isEmpty ? "Welcome to Untwist" : "What's on your mind?")
                .font(Theme.Typography.largeTitle)
                .foregroundColor(Theme.Colors.text)
                .multilineTextAlignment(.center)
                .animation(.none, value: thoughts.count)

            Text(thoughts.isEmpty ?
                "When an anxious thought arises, capture it here. You'll review and reframe it later." :
                "Capture your worries as they come. They'll be waiting in your worry box when you're ready to review.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
                .animation(.none, value: thoughts.count)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(minHeight: 100) // Larger bottom spacer for breathing room
        }
        .padding(.top, Theme.Spacing.md) // Reduced top padding
    }

    private var worryTimeIndicator: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "clock")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textTertiary)

            Text("Worry time: \(formattedWorryTime)")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textTertiary)

            // Info button
            Button {
                showWorryTimeInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .accessibilityLabel("Why worry time?")
            .accessibilityHint("Learn about scheduled worry time")
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private var captureButton: some View {
        Button {
            showingCapture = true
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Capture a Worry")
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadows.button.color,
                radius: Theme.Shadows.button.radius,
                x: Theme.Shadows.button.x,
                y: Theme.Shadows.button.y
            )
        }
        .accessibilityLabel("Capture a worry")
        .accessibilityHint("Opens form to save an anxious thought")
    }

    // MARK: - Vertical Icon Stack (TikTok-style)

    private var verticalIconStack: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Learn icon button
            learnIconButton

            // Worry Box icon button
            worryBoxIconButton
        }
    }

    private var learnIconButton: some View {
        Button {
            showingLearn = true
            if let settings = userSettings {
                settings.learnToolbarHintShownCount += 1
                settings.hasVisitedLearn = true
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 32))
                        .foregroundColor(shouldPulseLearnIcon ? Theme.Colors.primary : Theme.Colors.textTertiary)
                        .symbolEffect(.pulse, options: .repeating, isActive: shouldPulseLearnIcon)

                    Text("Learn")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                // Badge indicator
                if shouldShowLearnBadge {
                    Circle()
                        .fill(Theme.Colors.error)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Theme.Colors.background, lineWidth: 2)
                        )
                        .offset(x: 8, y: -4)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityLabel("Learn")
        .accessibilityHint("Browse cognitive distortion guides")
        .accessibilityElement(children: .combine)
    }

    private var worryBoxIconButton: some View {
        Button {
            handleWorryBoxTap()
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: worryBoxIcon)
                        .font(.system(size: isOutsideScheduledTime ? 28 : 32))
                        .foregroundColor(animateWorryBoxIcon ? Theme.Colors.primary : worryBoxColor)
                        .symbolEffect(.pulse, options: .repeating, isActive: !isOutsideScheduledTime || (isOutsideScheduledTime && !thoughts.isEmpty))
                        .symbolEffect(.bounce, value: animateWorryBoxIcon)
                        .scaleEffect(animateWorryBoxIcon ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateWorryBoxIcon)

                    Text("Worry Box")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                // Badge indicator at review time (only if there are thoughts to review)
                if !isOutsideScheduledTime && !thoughts.isEmpty {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -2)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityLabel(isOutsideScheduledTime ? "Scheduled Worry Time" : "Worry Box")
        .accessibilityHint(isOutsideScheduledTime ? "Opens at \(formattedWorryTime)" : "Review your captured worries")
    }

    // MARK: - Helper Properties

    private var shouldShowLearnBadge: Bool {
        guard let settings = userSettings else { return false }
        // Show for new users who haven't visited Learn yet
        return !settings.hasVisitedLearn
    }

    private var shouldPulseLearnIcon: Bool {
        guard let settings = userSettings else { return false }
        // Pulse for first 3 app opens or until user visits Learn
        return settings.learnIconPulseCount < 3 && !settings.hasVisitedLearn
    }

    private var worryBoxIcon: String {
        if thoughts.isEmpty {
            return "archivebox"
        }
        return isOutsideScheduledTime ? "lock.fill" : "lock.open.fill"
    }

    private var worryBoxColor: Color {
        if thoughts.isEmpty {
            return Theme.Colors.textTertiary.opacity(0.5)
        }
        return isOutsideScheduledTime ? Theme.Colors.textSecondary : Theme.Colors.primary
    }

    private func handleWorryBoxTap() {
        if isOutsideScheduledTime && !thoughts.isEmpty && userSettings?.showWorryTimeLockAlert == true {
            // Haptic feedback - light (gentle reminder)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            showScheduleReminder = true
        } else {
            // Haptic feedback - success (this is the right time)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            showingWorryBox = true
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: AnxiousThought.self, inMemory: true)
}
