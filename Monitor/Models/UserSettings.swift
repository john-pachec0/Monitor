//
//  UserSettings.swift
//  Monitor
//
//  Tracks user preferences and meal reminder configuration for ED recovery
//

import Foundation
import SwiftData

// MARK: - Care Team Member

@Model
final class CareTeamMember {
    var name: String
    var role: CareTeamRole
    var phone: String?
    var email: String?
    var notes: String?
    var createdAt: Date

    // Relationship to settings
    var settings: UserSettings?

    init(
        name: String,
        role: CareTeamRole,
        phone: String? = nil,
        email: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.role = role
        self.phone = phone
        self.email = email
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - Care Team Roles

enum CareTeamRole: String, Codable, CaseIterable, Identifiable {
    case dietitian = "Dietitian/Nutritionist"
    case therapist = "Therapist"
    case psychiatrist = "Psychiatrist"
    case medicalDoctor = "Medical Doctor"
    case peerMentor = "Peer Mentor"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dietitian:
            return "leaf.fill"
        case .therapist:
            return "brain.head.profile"
        case .psychiatrist:
            return "cross.case.fill"
        case .medicalDoctor:
            return "stethoscope"
        case .peerMentor:
            return "person.2.fill"
        case .other:
            return "person.fill"
        }
    }
}

// MARK: - User Settings

@Model
final class UserSettings {
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    // Meal reminder times
    var breakfastReminderTime: Date
    var lunchReminderTime: Date
    var dinnerReminderTime: Date
    var eveningCheckInTime: Date

    // Care team (relationship to CareTeamMember)
    @Relationship(deleteRule: .cascade)
    var careTeam: [CareTeamMember] = []

    // Emergency contact (separate from care team)
    var emergencyContact: String?
    var emergencyPhone: String?

    // Notification preferences
    var notificationsEnabled: Bool
    var mealRemindersEnabled: Bool
    var eveningCheckInEnabled: Bool
    var supportiveMessagesEnabled: Bool // Encouraging notifications throughout the day

    // Tutorial tracking
    var hasSeenMealEntryTutorial: Bool
    var hasSeenBehaviorTutorial: Bool
    var hasSeenReviewTutorial: Bool
    var mealEntryCount: Int // Track number of entries for progressive disclosure

    // Privacy and security
    var requiresBiometricAuth: Bool
    var autoArchiveAfterDays: Int // Days to keep entries before auto-archive (default 90)

    // Display preferences
    var showPhotosInList: Bool // Whether to show meal photos in list view
    var defaultMealType: MealType? // Suggest this meal type based on time of day

    init(
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = Date(),
        breakfastReminderTime: Date? = nil,
        lunchReminderTime: Date? = nil,
        dinnerReminderTime: Date? = nil,
        eveningCheckInTime: Date? = nil,
        emergencyContact: String? = nil,
        emergencyPhone: String? = nil,
        notificationsEnabled: Bool = false,
        mealRemindersEnabled: Bool = false,
        eveningCheckInEnabled: Bool = false,
        supportiveMessagesEnabled: Bool = false,
        hasSeenMealEntryTutorial: Bool = false,
        hasSeenBehaviorTutorial: Bool = false,
        hasSeenReviewTutorial: Bool = false,
        mealEntryCount: Int = 0,
        requiresBiometricAuth: Bool = false,
        autoArchiveAfterDays: Int = 90,
        showPhotosInList: Bool = true,
        defaultMealType: MealType? = nil
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt

        // Default reminder times if not provided
        let calendar = Calendar.current

        if let breakfast = breakfastReminderTime {
            self.breakfastReminderTime = breakfast
        } else {
            self.breakfastReminderTime = calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        }

        if let lunch = lunchReminderTime {
            self.lunchReminderTime = lunch
        } else {
            self.lunchReminderTime = calendar.date(from: DateComponents(hour: 12, minute: 30)) ?? Date()
        }

        if let dinner = dinnerReminderTime {
            self.dinnerReminderTime = dinner
        } else {
            self.dinnerReminderTime = calendar.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
        }

        if let evening = eveningCheckInTime {
            self.eveningCheckInTime = evening
        } else {
            self.eveningCheckInTime = calendar.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        }

        self.emergencyContact = emergencyContact
        self.emergencyPhone = emergencyPhone
        self.notificationsEnabled = notificationsEnabled
        self.mealRemindersEnabled = mealRemindersEnabled
        self.eveningCheckInEnabled = eveningCheckInEnabled
        self.supportiveMessagesEnabled = supportiveMessagesEnabled
        self.hasSeenMealEntryTutorial = hasSeenMealEntryTutorial
        self.hasSeenBehaviorTutorial = hasSeenBehaviorTutorial
        self.hasSeenReviewTutorial = hasSeenReviewTutorial
        self.mealEntryCount = mealEntryCount
        self.requiresBiometricAuth = requiresBiometricAuth
        self.autoArchiveAfterDays = autoArchiveAfterDays
        self.showPhotosInList = showPhotosInList
        self.defaultMealType = defaultMealType
    }

    // MARK: - Computed Properties

    /// Whether the user has configured care team information
    var hasCareTeamConfigured: Bool {
        !careTeam.isEmpty || emergencyContact != nil
    }

    /// Whether any notifications are enabled
    var hasAnyNotificationsEnabled: Bool {
        notificationsEnabled && (mealRemindersEnabled || eveningCheckInEnabled || supportiveMessagesEnabled)
    }

    /// Formatted time string for a given reminder
    func formattedTime(for reminderDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderDate)
    }

    /// Get suggested time period based on current time of day
    func suggestedMealType(for date: Date = Date()) -> MealType {
        if let defaultType = defaultMealType {
            return defaultType
        }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<11:
            return .morning
        case 11..<15:
            return .midday
        case 15..<18:
            return .afternoon
        case 18..<22:
            return .evening
        default:
            return .night
        }
    }
}
