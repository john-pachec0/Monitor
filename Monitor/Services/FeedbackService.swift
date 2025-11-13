//
//  FeedbackService.swift
//  Monitor
//
//  Service for sending user feedback to server
//

import Foundation
import UIKit

// MARK: - Feedback Types

enum FeedbackType: String, Codable, CaseIterable, Identifiable {
    case bugReport = "bug_report"
    case featureRequest = "feature_request"
    case generalFeedback = "general_feedback"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bugReport: return "Bug Report"
        case .featureRequest: return "Feature Request"
        case .generalFeedback: return "General Feedback"
        }
    }

    var shortDisplayName: String {
        switch self {
        case .bugReport: return "Bug"
        case .featureRequest: return "Feature"
        case .generalFeedback: return "General"
        }
    }
}

// MARK: - Diagnostic Info

struct DiagnosticInfo: Codable {
    let appVersion: String
    let iosVersion: String
    let device: String
    let locale: String

    static func current() -> DiagnosticInfo {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let iosVersion = UIDevice.current.systemVersion
        let device = getDeviceModel()
        let locale = Locale.current.identifier

        return DiagnosticInfo(
            appVersion: appVersion,
            iosVersion: iosVersion,
            device: device,
            locale: locale
        )
    }

    /// Get the device model identifier (e.g., "iPhone14,2" for iPhone 13 Pro)
    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    var formattedDescription: String {
        """
        • App Version: \(appVersion)
        • iOS Version: \(iosVersion)
        • Device: \(device)
        • Locale: \(locale)
        """
    }
}

// MARK: - Feedback Payload

struct FeedbackPayload: Codable {
    let feedback: String
    let type: FeedbackType
    let diagnostic: DiagnosticInfo?
    let timestamp: Date
}

// MARK: - Feedback Service

class FeedbackService {
    static let shared = FeedbackService()

    private init() {}

    /// Send feedback to the server
    /// - Parameters:
    ///   - feedbackText: The user's feedback message
    ///   - type: The type of feedback (bug, feature, general)
    ///   - includeDiagnostic: Whether to include diagnostic information
    /// - Returns: Result with success or error
    func sendFeedback(
        feedbackText: String,
        type: FeedbackType,
        includeDiagnostic: Bool
    ) async -> Result<Void, FeedbackError> {
        // Validate feedback text
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.emptyFeedback)
        }

        // Create payload
        let payload = FeedbackPayload(
            feedback: feedbackText,
            type: type,
            diagnostic: includeDiagnostic ? DiagnosticInfo.current() : nil,
            timestamp: Date()
        )

        // Create request
        guard let url = URL(string: Config.feedbackEndpoint) else {
            return .failure(.invalidEndpoint)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add API key from secure configuration
        let apiKey = Config.feedbackAPIKey
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        #if DEBUG
        print("📤 Sending feedback to: \(Config.feedbackEndpoint)")
        print("🔑 Using API key: \(apiKey.prefix(10))...")
        #endif

        // Encode payload
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(payload)
        } catch {
            return .failure(.encodingError(error))
        }

        // Send request
        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            // Check status code
            switch httpResponse.statusCode {
            case 200...299:
                return .success(())
            case 400...499:
                return .failure(.clientError(httpResponse.statusCode))
            case 500...599:
                return .failure(.serverError(httpResponse.statusCode))
            default:
                return .failure(.unexpectedStatusCode(httpResponse.statusCode))
            }

        } catch {
            return .failure(.networkError(error))
        }
    }
}

// MARK: - Feedback Errors

enum FeedbackError: LocalizedError {
    case emptyFeedback
    case invalidEndpoint
    case encodingError(Error)
    case networkError(Error)
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .emptyFeedback:
            return "Please enter some feedback before sending."
        case .invalidEndpoint:
            return "Invalid feedback endpoint. Please contact support."
        case .encodingError:
            return "Failed to prepare feedback for sending."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received invalid response from server."
        case .clientError(let code):
            return "Request error (code \(code)). Please try again."
        case .serverError(let code):
            return "Server error (code \(code)). Please try again later."
        case .unexpectedStatusCode(let code):
            return "Unexpected response (code \(code))."
        }
    }
}
