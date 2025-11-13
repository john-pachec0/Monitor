//
//  MonitorApp.swift
//  Monitor
//
//  A privacy-first meal tracking app for ED recovery support
//

import SwiftUI
import SwiftData

@main
struct MonitorApp: App {
    // Store the model container so we can initialize settings
    let modelContainer: ModelContainer

    // Biometric authentication service
    @StateObject private var biometricService = BiometricAuthService()

    // Track scene phase for app lifecycle
    @Environment(\.scenePhase) private var scenePhase

    // Track when app went to background
    @State private var backgroundTime: Date?
    @State private var inactiveTime: Date?

    init() {
        // Configure navigation bar appearance globally with adaptive colors
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Adaptive background color
        appearance.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.11, green: 0.12, blue: 0.13, alpha: 1.0) // Dark background
            default:
                return UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1.0) // Light background
            }
        }

        // Adaptive text color
        let textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.92, green: 0.94, blue: 0.95, alpha: 1.0) // Light text
            default:
                return UIColor(red: 0.15, green: 0.18, blue: 0.20, alpha: 1.0) // Dark text
            }
        }

        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Adaptive tint color for toolbar items - Teal theme
        UINavigationBar.appearance().tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.35, green: 0.75, blue: 0.80, alpha: 1.0) // Lighter teal
            default:
                return UIColor(red: 0.25, green: 0.65, blue: 0.70, alpha: 1.0) // Teal
            }
        }

        // Initialize SwiftData model container with migration support
        do {
            // Configure model container with explicit schema
            let schema = Schema([MealEntry.self, UserSettings.self, CareTeamMember.self])
            // Use a new database name to avoid migration conflicts from the old Untwist schema
            // This creates a fresh database for the Monitor app
            let databaseURL = URL.documentsDirectory.appending(path: "MonitorV2.sqlite")
            let modelConfiguration = ModelConfiguration(url: databaseURL)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Ensure UserSettings singleton exists
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<UserSettings>()

            do {
                let existingSettings = try context.fetch(descriptor)

                if existingSettings.isEmpty {
                    // No settings exist, create fresh
                    let newSettings = UserSettings()
                    context.insert(newSettings)
                    try context.save()
                    print("Created new UserSettings singleton")
                } else {
                    print("Found existing UserSettings: \(existingSettings.count)")
                }
            } catch {
                // If fetch fails, try to create new settings
                print("Error fetching UserSettings, creating new: \(error)")
                let newSettings = UserSettings()
                context.insert(newSettings)
                try context.save()
            }

            // Clean up archived meal entries older than 30 days
            do {
                let entriesDescriptor = FetchDescriptor<MealEntry>()
                let allEntries = try context.fetch(entriesDescriptor)

                // Calculate cutoff date (30 days ago)
                let calendar = Calendar.current
                guard let cutoffDate = calendar.date(byAdding: .day, value: -30, to: Date()) else {
                    print("Failed to calculate cutoff date for cleanup")
                    return
                }

                // Filter and delete old entries
                let oldEntries = allEntries.filter { $0.timestamp < cutoffDate }

                if !oldEntries.isEmpty {
                    oldEntries.forEach { entry in
                        context.delete(entry)
                    }
                    try context.save()
                    print("Deleted \(oldEntries.count) meal entries older than 30 days")
                } else {
                    print("No meal entries older than 30 days to delete")
                }
            } catch {
                print("Error cleaning up old meal entries: \(error)")
            }
        } catch {
            // Provide more detailed error information
            print("ModelContainer initialization error: \(error)")
            print("Error details: \(error.localizedDescription)")
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowLockScreen {
                    BiometricLockView()
                        .environmentObject(biometricService)
                } else {
                    ContentContainer()
                        .environmentObject(biometricService)
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
            }
        }
        .modelContainer(modelContainer)
    }

    private var shouldShowLockScreen: Bool {
        guard let settings = fetchUserSettings() else { return false }
        guard settings.requiresBiometricAuth else { return false }
        return !biometricService.isUnlocked
    }

    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        let settings = fetchUserSettings()

        switch newPhase {
        case .background:
            // App going to background - always lock for security
            if settings?.requiresBiometricAuth == true {
                backgroundTime = Date()
                biometricService.lock()
            }
            inactiveTime = nil

        case .active:
            // App coming to foreground
            if settings?.requiresBiometricAuth == true {
                // If coming from background, check time threshold
                if oldPhase == .background, let bgTime = backgroundTime {
                    let timeSinceBackground = Date().timeIntervalSince(bgTime)
                    // Require re-auth if background for > 30 seconds
                    if timeSinceBackground > 30 {
                        biometricService.lock()
                    }
                }
                // If coming from inactive, check if it was a long inactive period
                else if oldPhase == .inactive, let inactTime = inactiveTime {
                    let timeSinceInactive = Date().timeIntervalSince(inactTime)
                    // Only lock if inactive for > 5 seconds (excludes Control Center, notifications, etc.)
                    if timeSinceInactive > 5 {
                        biometricService.lock()
                    }
                }
            }
            backgroundTime = nil
            inactiveTime = nil

        case .inactive:
            // App becoming inactive (could be Control Center, lock screen, notification, etc.)
            // Track time but don't lock immediately - only lock if inactive for meaningful duration
            if settings?.requiresBiometricAuth == true {
                inactiveTime = Date()
            }

        @unknown default:
            break
        }
    }

    private func fetchUserSettings() -> UserSettings? {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<UserSettings>()
        return try? context.fetch(descriptor).first
    }
}

// MARK: - Content Container

struct ContentContainer: View {
    @Query private var settings: [UserSettings]

    @State private var showOnboarding = false

    var body: some View {
        Group {
            if let userSettings = settings.first {
                HomeView()
                    .onAppear {
                        // Check onboarding status once settings are loaded
                        if !userSettings.hasCompletedOnboarding {
                            showOnboarding = true
                        }
                    }
                    .fullScreenCover(isPresented: $showOnboarding) {
                        OnboardingView {
                            userSettings.hasCompletedOnboarding = true
                            showOnboarding = false
                        }
                    }
            } else {
                // This should never happen since we create settings in init()
                // But provide a fallback just in case
                ProgressView()
            }
        }
    }
}
