//
//  UntwistApp.swift
//  Untwist
//
//  A CBT-based app for capturing and reframing anxious thoughts
//

import SwiftUI
import SwiftData

@main
struct UntwistApp: App {
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
                return UIColor(red: 0.12, green: 0.11, blue: 0.10, alpha: 1.0) // Dark background
            default:
                return UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0) // Light background
            }
        }

        // Adaptive text color
        let textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0) // Light text
            default:
                return UIColor(red: 0.20, green: 0.18, blue: 0.17, alpha: 1.0) // Dark text
            }
        }

        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Adaptive tint color for toolbar items
        UINavigationBar.appearance().tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.90, green: 0.62, blue: 0.48, alpha: 1.0) // Lighter primary
            default:
                return UIColor(red: 0.82, green: 0.52, blue: 0.38, alpha: 1.0) // Primary
            }
        }

        // Initialize SwiftData model container with migration support
        do {
            // Configure model container with explicit schema
            let schema = Schema([AnxiousThought.self, UserSettings.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
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

            // Clean up archived thoughts older than 30 days
            do {
                let thoughtsDescriptor = FetchDescriptor<AnxiousThought>()
                let allThoughts = try context.fetch(thoughtsDescriptor)

                // Calculate cutoff date (30 days ago)
                let calendar = Calendar.current
                guard let cutoffDate = calendar.date(byAdding: .day, value: -30, to: Date()) else {
                    print("Failed to calculate cutoff date for cleanup")
                    return
                }

                // Filter and delete old thoughts
                let oldThoughts = allThoughts.filter { $0.timestamp < cutoffDate }

                if !oldThoughts.isEmpty {
                    oldThoughts.forEach { thought in
                        context.delete(thought)
                    }
                    try context.save()
                    print("Deleted \(oldThoughts.count) thoughts older than 30 days")
                } else {
                    print("No thoughts older than 30 days to delete")
                }
            } catch {
                print("Error cleaning up old thoughts: \(error)")
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
