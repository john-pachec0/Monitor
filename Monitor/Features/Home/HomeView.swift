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
                    .padding(.bottom, 180) // Position above capture button
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
            }
            .navigationDestination(isPresented: $showingJournal) {
                MealHistoryView()
            }
            .toast(message: "Meal saved", isPresented: $showMealSavedToast)
        }
    }

    // MARK: - Subviews

    private var mainContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
                .frame(maxHeight: 60)

            Image(systemName: "fork.knife")
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

            Spacer()
                .frame(minHeight: 100)
        }
        .padding(.top, Theme.Spacing.md)
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

#Preview {
    HomeView()
        .modelContainer(for: MealEntry.self, inMemory: true)
}
