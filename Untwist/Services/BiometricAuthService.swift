//
//  BiometricAuthService.swift
//  Untwist
//
//  Centralized service for biometric authentication (Face ID / Touch ID)
//

import LocalAuthentication
import SwiftUI

@MainActor
class BiometricAuthService: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var biometricType: BiometricType = .none
    @Published var error: BiometricError?

    // Keep reference to context to properly invalidate it
    private var currentContext: LAContext?

    // Track retry attempts to prevent infinite loops
    private var retryCount: Int = 0
    private let maxRetries: Int = 2

    enum BiometricType {
        case faceID
        case touchID
        case none
    }

    enum BiometricError: LocalizedError {
        case notAvailable
        case notEnrolled
        case authenticationFailed
        case userCanceled

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device."
            case .notEnrolled:
                return "Face ID or Touch ID is not set up. Go to Settings > Face ID & Passcode to set it up."
            case .authenticationFailed:
                return "Authentication failed. Please try again."
            case .userCanceled:
                return "Authentication was canceled."
            }
        }
    }

    init() {
        checkBiometricAvailability()
    }

    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }

    func authenticate(isRetry: Bool = false) async {
        // Clear any previous errors when starting fresh authentication
        if !isRetry {
            self.error = nil
            retryCount = 0
        }

        // Invalidate any existing context
        currentContext?.invalidate()

        // Small delay to allow system to reset after device unlock
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Create fresh context
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        currentContext = context

        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                handleAuthError(error)
            }
            return
        }

        do {
            let reason = "Unlock Untwist to view your thoughts"
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)

            if success {
                isUnlocked = true
                self.error = nil
                retryCount = 0  // Reset on success
            }
        } catch let authError as LAError {
            // Handle specific authentication error cases
            handleLAError(authError)
        } catch {
            // Catch any other unexpected errors
            self.error = .authenticationFailed
        }
    }

    private func handleAuthError(_ error: NSError) {
        guard let laError = LAError.Code(rawValue: error.code) else {
            self.error = .notAvailable
            return
        }

        switch laError {
        case .biometryNotEnrolled:
            self.error = .notEnrolled
        case .biometryNotAvailable:
            self.error = .notAvailable
        default:
            self.error = .notAvailable
        }
    }

    private func handleLAError(_ error: LAError) {
        switch error.code {
        case .userCancel, .systemCancel, .appCancel:
            self.error = .userCanceled
            retryCount = 0  // Reset on cancel
        case .authenticationFailed:
            self.error = .authenticationFailed
        case .biometryNotEnrolled:
            self.error = .notEnrolled
        case .biometryNotAvailable:
            self.error = .notAvailable
        case .biometryLockout:
            // Face ID/Touch ID is temporarily locked out
            // Only retry if we haven't exceeded max retries
            if retryCount < maxRetries {
                retryCount += 1
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    await authenticate(isRetry: true)
                }
            } else {
                self.error = .authenticationFailed
                retryCount = 0
            }
        case .invalidContext:
            // Context is invalid (e.g., Face ID just used for something else)
            // Only retry once for invalid context
            if retryCount < 1 {
                retryCount += 1
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    await authenticate(isRetry: true)
                }
            } else {
                self.error = .authenticationFailed
                retryCount = 0
            }
        default:
            self.error = .authenticationFailed
        }
    }

    func lock() {
        isUnlocked = false
        // Invalidate context when locking
        currentContext?.invalidate()
        currentContext = nil
        // Reset retry counter
        retryCount = 0
        // Clear any errors
        error = nil
    }

    var biometricTypeString: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Biometric Authentication"
        }
    }

    var isBiometricAvailable: Bool {
        biometricType != .none
    }
}
