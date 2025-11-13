//
//  MealEntry.swift
//  Monitor
//
//  Core domain model for meal tracking in ED recovery
//

import Foundation
import SwiftData

@Model
final class MealEntry {
    var id: UUID
    var timestamp: Date

    // Meal classification
    var mealType: MealType

    // Meal details
    var foodAndDrink: String
    var location: String
    var imageData: Data? // Optional meal photo (compressed)

    // Assessment
    var believedExcessive: Bool // "I believed this consumption was excessive"

    // Behavioral responses to meal
    var vomited: Bool
    var laxativesAmount: Int // Number of laxatives taken (0 = none)
    var diureticsAmount: Int // Number of diuretics taken (0 = none)

    // Exercise tracking
    var exercised: Bool
    var exerciseDuration: Int? // Minutes (only if exercised = true)
    var exerciseIntensity: ExerciseIntensity? // Only if exercised = true
    var exerciseType: String? // Description (only if exercised = true)

    // Emotional tracking
    var emotionsBefore: String? // Emotions before the meal
    var emotionsAfter: String? // Emotions after the meal
    var thoughtsAndFeelings: String? // Additional context

    // Review tracking
    var isReviewed: Bool
    var reviewedAt: Date?
    var reviewNotes: String? // Therapist or self-reflection notes

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealType: MealType = .morning,
        foodAndDrink: String,
        location: String = "",
        imageData: Data? = nil,
        believedExcessive: Bool = false,
        vomited: Bool = false,
        laxativesAmount: Int = 0,
        diureticsAmount: Int = 0,
        exercised: Bool = false,
        exerciseDuration: Int? = nil,
        exerciseIntensity: ExerciseIntensity? = nil,
        exerciseType: String? = nil,
        emotionsBefore: String? = nil,
        emotionsAfter: String? = nil,
        thoughtsAndFeelings: String? = nil,
        isReviewed: Bool = false,
        reviewedAt: Date? = nil,
        reviewNotes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealType = mealType
        self.foodAndDrink = foodAndDrink
        self.location = location
        self.imageData = imageData
        self.believedExcessive = believedExcessive
        self.vomited = vomited
        self.laxativesAmount = laxativesAmount
        self.diureticsAmount = diureticsAmount
        self.exercised = exercised
        self.exerciseDuration = exerciseDuration
        self.exerciseIntensity = exerciseIntensity
        self.exerciseType = exerciseType
        self.emotionsBefore = emotionsBefore
        self.emotionsAfter = emotionsAfter
        self.thoughtsAndFeelings = thoughtsAndFeelings
        self.isReviewed = isReviewed
        self.reviewedAt = reviewedAt
        self.reviewNotes = reviewNotes
    }

    // MARK: - Computed Properties

    /// Whether any compensatory behaviors were reported in response to this meal
    var hadBehavioralResponse: Bool {
        return vomited ||
               laxativesAmount > 0 ||
               diureticsAmount > 0 ||
               exercised
    }

    /// Summary of behaviors for display
    var behaviorSummary: String? {
        guard hadBehavioralResponse else { return nil }

        var behaviors: [String] = []
        if vomited { behaviors.append("vomiting") }
        if laxativesAmount > 0 {
            behaviors.append("laxatives (\(laxativesAmount))")
        }
        if diureticsAmount > 0 {
            behaviors.append("diuretics (\(diureticsAmount))")
        }
        if exercised {
            if let duration = exerciseDuration {
                behaviors.append("exercise (\(duration) min)")
            } else {
                behaviors.append("exercise")
            }
        }

        return behaviors.joined(separator: ", ")
    }

    /// Human-readable meal type label
    var mealTypeLabel: String {
        mealType.displayName
    }

    /// Icon for the meal type
    var mealTypeIcon: String {
        mealType.icon
    }

    /// Whether this entry has any concerning patterns
    /// Used for providing supportive guidance during review
    var hasConcerningPattern: Bool {
        believedExcessive || hadBehavioralResponse
    }

    /// Formatted timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }

    /// Exercise summary for display
    var exerciseSummary: String? {
        guard exercised else { return nil }

        var parts: [String] = []

        if let type = exerciseType, !type.isEmpty {
            parts.append(type)
        }

        if let duration = exerciseDuration {
            parts.append("\(duration) min")
        }

        if let intensity = exerciseIntensity {
            parts.append(intensity.displayName.lowercased())
        }

        return parts.isEmpty ? "Exercise" : parts.joined(separator: ", ")
    }
}
