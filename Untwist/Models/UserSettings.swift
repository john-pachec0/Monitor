//
//  UserSettings.swift
//  Untwist
//
//  Tracks user preferences and onboarding state
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    // Adaptive learning properties
    var distortionReviewCount: Int
    var hasSeenDistortionTutorial: Bool
    var prefersFastMode: Bool

    // Learn feature discovery
    var learnToolbarHintShownCount: Int
    var hasVisitedLearn: Bool
    // Made optional to support migration from older schema versions
    private var _hasSeenLearnTooltip: Bool?
    private var _learnIconPulseCount: Int?

    // Feature flags (made optional to support migration from older schema versions)
    private var _rateAnxietyAtCapture: Bool?

    // Worry scheduling properties
    // Made optional to support migration from older schema versions
    // Use computed properties below to access with default values
    private var _preferredReviewTime: Date?
    private var _notificationsEnabled: Bool?
    private var _showWorryTimeLockAlert: Bool?

    // Biometric authentication
    // Made optional to support migration from older schema versions
    private var _requiresBiometricAuth: Bool?

    // Public computed properties with default values for migration compatibility
    var preferredReviewTime: Date {
        get {
            if let time = _preferredReviewTime {
                return time
            }
            // Default to 8:00 PM on a fixed date
            let calendar = Calendar.current
            let components = DateComponents(year: 2025, month: 1, day: 1, hour: 20, minute: 0)
            return calendar.date(from: components) ?? Date()
        }
        set {
            _preferredReviewTime = newValue
        }
    }

    var notificationsEnabled: Bool {
        get {
            return _notificationsEnabled ?? false
        }
        set {
            _notificationsEnabled = newValue
        }
    }

    var rateAnxietyAtCapture: Bool {
        get {
            return _rateAnxietyAtCapture ?? false
        }
        set {
            _rateAnxietyAtCapture = newValue
        }
    }

    var requiresBiometricAuth: Bool {
        get {
            return _requiresBiometricAuth ?? false
        }
        set {
            _requiresBiometricAuth = newValue
        }
    }

    var hasSeenLearnTooltip: Bool {
        get {
            return _hasSeenLearnTooltip ?? false
        }
        set {
            _hasSeenLearnTooltip = newValue
        }
    }

    var learnIconPulseCount: Int {
        get {
            return _learnIconPulseCount ?? 0
        }
        set {
            _learnIconPulseCount = newValue
        }
    }

    var showWorryTimeLockAlert: Bool {
        get {
            return _showWorryTimeLockAlert ?? true
        }
        set {
            _showWorryTimeLockAlert = newValue
        }
    }

    init(
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = Date(),
        distortionReviewCount: Int = 0,
        hasSeenDistortionTutorial: Bool = false,
        prefersFastMode: Bool = false,
        rateAnxietyAtCapture: Bool = false,
        preferredReviewTime: Date? = nil,
        notificationsEnabled: Bool = false,
        learnToolbarHintShownCount: Int = 0,
        hasVisitedLearn: Bool = false,
        hasSeenLearnTooltip: Bool = false,
        learnIconPulseCount: Int = 0,
        showWorryTimeLockAlert: Bool = true,
        requiresBiometricAuth: Bool = false
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.distortionReviewCount = distortionReviewCount
        self.hasSeenDistortionTutorial = hasSeenDistortionTutorial
        self.prefersFastMode = prefersFastMode
        self._rateAnxietyAtCapture = rateAnxietyAtCapture
        self.learnToolbarHintShownCount = learnToolbarHintShownCount
        self.hasVisitedLearn = hasVisitedLearn
        self._hasSeenLearnTooltip = hasSeenLearnTooltip
        self._learnIconPulseCount = learnIconPulseCount
        self._showWorryTimeLockAlert = showWorryTimeLockAlert

        // Set default review time to 8:00 PM on a fixed date
        if let providedTime = preferredReviewTime {
            self._preferredReviewTime = providedTime
        } else {
            // Create a fixed reference date for 8:00 PM
            let calendar = Calendar.current
            let components = DateComponents(year: 2025, month: 1, day: 1, hour: 20, minute: 0)
            self._preferredReviewTime = calendar.date(from: components)
        }

        self._notificationsEnabled = notificationsEnabled
        self._requiresBiometricAuth = requiresBiometricAuth
    }
}
