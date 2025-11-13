//
//  ExerciseIntensity.swift
//  Monitor
//
//  Enum for categorizing exercise intensity levels
//

import Foundation
import SwiftUI

enum ExerciseIntensity: String, Codable, CaseIterable, Identifiable {
    case low
    case moderate
    case high
    case extreme

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .extreme: return "Extreme"
        }
    }

    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}
