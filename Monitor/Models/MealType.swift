//
//  MealType.swift
//  Monitor
//
//  Time-based categorization for eating occasions (ED recovery-focused)
//  Removes judgment about meal "size" or "importance" - all eating matters equally
//

import Foundation
import SwiftUI

enum MealType: String, Codable, CaseIterable, Identifiable {
    case morning
    case midday
    case afternoon
    case evening
    case night

    var id: String { rawValue }

    // MARK: - Legacy Migration Support

    /// Custom decoder to support migration from old meal type values
    /// Maps: breakfast → morning, lunch → midday, snack → afternoon, dinner → evening, other → night
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Handle legacy values from before time-based categorization
        switch rawValue {
        case "breakfast":
            self = .morning
        case "lunch":
            self = .midday
        case "snack":
            self = .afternoon
        case "dinner":
            self = .evening
        case "other":
            self = .night
        // Handle new values
        case "morning":
            self = .morning
        case "midday":
            self = .midday
        case "afternoon":
            self = .afternoon
        case "evening":
            self = .evening
        case "night":
            self = .night
        default:
            // Fallback to morning if unknown value
            self = .morning
        }
    }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .afternoon: return "sun.min.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .morning: return 0
        case .midday: return 1
        case .afternoon: return 2
        case .evening: return 3
        case .night: return 4
        }
    }
}
