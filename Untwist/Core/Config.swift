//
//  Config.swift
//  Untwist
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
    static let feedbackEndpoint = "https://api.untwist.app/feedback"
}
