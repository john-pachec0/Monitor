//
//  Config.swift
//  Monitor
//
//  Configuration and secrets management
//

import Foundation

enum Config {
    /// API Key for feedback endpoint
    /// This value is injected from Secrets.xcconfig via build settings
    static var feedbackAPIKey: String {
        guard let apiKey = Bundle.main.infoDictionary?["FEEDBACK_API_KEY"] as? String,
              !apiKey.isEmpty,
              apiKey != "your-api-key-here",
              apiKey != "$(FEEDBACK_API_KEY)" else { // Check for unexpanded variable
            #if DEBUG
            print("⚠️ WARNING: FEEDBACK_API_KEY not properly configured")
            print("   See SETUP_SECRETS.md for configuration instructions")
            return ""
            #else
            fatalError("FEEDBACK_API_KEY not configured. Check build configuration.")
            #endif
        }

        return apiKey
    }

    /// Feedback API endpoint
    static let feedbackEndpoint = "https://api.Monitor.app/feedback"

    // MARK: - Photo Settings
    static let maxPhotoSizeKB = 500
    static let maxPhotoDimension: CGFloat = 2000

    // MARK: - Data Settings
    static let defaultAutoArchiveDays = 90
    static let maxEntriesPerDay = 20

    // MARK: - Export Settings
    static let pdfPageMargin: CGFloat = 50
    static let pdfRowHeight: CGFloat = 30
    static let pdfPhotoSize: CGFloat = 100

    // MARK: - UI Settings
    static let animationDuration = 0.3
    static let toastDuration = 2.0
    static let maxTextFieldLength = 500

    // MARK: - Validation
    static let minFoodDescriptionLength = 3
    static let maxLocationLength = 100
    static let maxContextLength = 1000
}
