//
//  HomeView.swift
//  Monitor
//
//  Main screen: Clean slate for logging meals
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var biometricService: BiometricAuthService
    @Query private var entries: [MealEntry]
    @Query private var settings: [UserSettings]

    @State private var showingCapture = false
    @State private var showingSettings = false
    @State private var showingJournal = false
    @State private var showMealSavedToast = false
    @State private var animateJournalIcon = false

    var userSettings: UserSettings? {
        settings.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Clean slate content
                    mainContent

                    Spacer()

                    // Bottom capture button
                    captureButton
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Monitor")
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
                // Journal icon on right side
                journalIconButton
                    .padding(.trailing, Theme.Spacing.md)
                    .padding(.bottom, 100) // Position just above capture button, below care team
            }
            .sheet(isPresented: $showingCapture) {
                CaptureMealView(onSaved: {
                    showMealSavedToast = true

                    // Animate journal icon to show meal was saved
                    animateJournalIcon = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        animateJournalIcon = false
                    }
                })
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(biometricService)
            }
            .navigationDestination(isPresented: $showingJournal) {
                MealHistoryView()
            }
            .toast(message: "Meal saved", isPresented: $showMealSavedToast)
        }
    }

    // MARK: - Subviews

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                    .frame(maxHeight: 60)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.textTertiary.opacity(0.6))
                    .padding(.bottom, Theme.Spacing.sm)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))
                    .accessibilityLabel("Monitor Home")
                    .accessibilityHidden(true)

                Text(entries.isEmpty ? "Welcome to Monitor" : "Ready to log?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.text)
                    .multilineTextAlignment(.center)
                    .animation(.none, value: entries.count)

                Text(entries.isEmpty ?
                    "Track your meals and feelings in a non-judgmental space. Share with your care team when you're ready." :
                    "Log your meals as you eat. Review and reflect when it feels right.")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .animation(.none, value: entries.count)
                    .fixedSize(horizontal: false, vertical: true)

                // Care Team Panel
                if let settings = userSettings, !settings.careTeam.isEmpty {
                    careTeamPanel
                        .padding(.top, Theme.Spacing.lg)
                }

                Spacer()
                    .frame(minHeight: 100)
            }
            .padding(.top, Theme.Spacing.md)
        }
    }

    private var captureButton: some View {
        Button {
            showingCapture = true
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Log a Meal")
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
        .accessibilityLabel("Log a meal")
        .accessibilityHint("Opens form to record a meal")
    }

    // MARK: - Care Team Panel

    private var careTeamPanel: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Your Care Team")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.text)
                .padding(.horizontal, Theme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    if let settings = userSettings {
                        ForEach(settings.careTeam.sorted(by: { $0.createdAt < $1.createdAt }), id: \.name) { member in
                            CareTeamCard(member: member)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }

    // MARK: - Journal Icon

    private var journalIconButton: some View {
        Button {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            showingJournal = true
        } label: {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: journalIcon)
                    .font(.system(size: 32))
                    .foregroundColor(animateJournalIcon ? Theme.Colors.primary : journalColor)
                    .symbolEffect(.bounce, value: animateJournalIcon)
                    .scaleEffect(animateJournalIcon ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateJournalIcon)

                Text("Journal")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .accessibilityLabel("Journal")
        .accessibilityHint("View your meal entries")
    }

    // MARK: - Helper Properties

    private var journalIcon: String {
        entries.isEmpty ? "book" : "book.fill"
    }

    private var journalColor: Color {
        entries.isEmpty ? Theme.Colors.textTertiary.opacity(0.5) : Theme.Colors.textSecondary
    }
}

// MARK: - Care Team Card

struct CareTeamCard: View {
    let member: CareTeamMember

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Role icon and name
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: member.role.icon)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(member.name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)
                        .lineLimit(1)

                    Text(member.role.rawValue)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Divider()

            // Contact info
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                if let phone = member.phone, !phone.isEmpty {
                    Menu {
                        if let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                            Link(destination: url) {
                                Label("Call \(phone)", systemImage: "phone.fill")
                            }
                        }
                        if let url = URL(string: "sms:\(phone.replacingOccurrences(of: " ", with: ""))") {
                            Link(destination: url) {
                                Label("Message \(phone)", systemImage: "message.fill")
                            }
                        }
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .frame(width: 16)

                            Text(phone)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.primary)
                                .underline()
                        }
                    }
                    .buttonStyle(.plain)
                }

                if let email = member.email, !email.isEmpty,
                   let emailURL = URL(string: "mailto:\(email)") {
                    Link(destination: emailURL) {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "envelope.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .frame(width: 16)

                            Text(email)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.primary)
                                .underline()
                                .lineLimit(1)
                        }
                    }
                }

                if let notes = member.notes, !notes.isEmpty {
                    HStack(alignment: .top, spacing: Theme.Spacing.xs) {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(width: 16)

                        Text(notes)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .frame(width: 240)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadows.card.color,
            radius: Theme.Shadows.card.radius,
            x: Theme.Shadows.card.x,
            y: Theme.Shadows.card.y
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: MealEntry.self, inMemory: true)
        .environmentObject(BiometricAuthService())
}
