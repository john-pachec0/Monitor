//
//  TestDataManager.swift
//  Untwist
//
//  Service for loading test data for pattern matching evaluation
//  DEBUG ONLY - Not included in production builds
//

#if DEBUG
import Foundation
import SwiftData

/// Test thought data structure matching JSON format
struct TestThoughtData: Codable {
    let theme: String
    let content: String
    let distortions: [String]
    let reframe: String
    let emotionBefore: Int
    let emotionAfter: Int
}

/// Root JSON structure
struct TestThoughtsJSON: Codable {
    let thoughts: [TestThoughtData]
}

/// Manager for loading and managing test data
class TestDataManager {

    /// Load test thoughts from JSON and insert into SwiftData
    /// - Parameters:
    ///   - context: SwiftData ModelContext to insert into
    ///   - clearExisting: Whether to clear existing thoughts first (default: false)
    /// - Returns: Number of thoughts loaded
    /// - Throws: Error if loading or parsing fails
    static func loadTestData(context: ModelContext, clearExisting: Bool = false) throws -> Int {
        // Clear existing data if requested
        if clearExisting {
            try clearAllData(context: context)
        }

        // Load JSON file
        guard let url = Bundle.main.url(forResource: "TestThoughts", withExtension: "json") else {
            throw NSError(domain: "TestDataManager", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "TestThoughts.json not found in bundle"
            ])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let testData = try decoder.decode(TestThoughtsJSON.self, from: data)

        // Convert to AnxiousThought objects and insert
        let calendar = Calendar.current
        let baseDate = Date()

        for testThought in testData.thoughts {
            // Map string distortions to enum
            let distortions = testThought.distortions.compactMap { distortionString in
                CognitiveDistortion.allCases.first { $0.rawValue == distortionString }
            }

            // Create timestamp spread over past 30 days
            let daysAgo = -Int.random(in: 0...30)
            let timestamp = calendar.date(byAdding: .day, value: daysAgo, to: baseDate) ?? baseDate

            // Create thought
            let thought = AnxiousThought(
                timestamp: timestamp,
                content: testThought.content,
                isReviewed: true,
                reviewedAt: timestamp,
                distortions: distortions,
                reframe: testThought.reframe,
                emotionBefore: testThought.emotionBefore,
                emotionAfter: testThought.emotionAfter
            )

            // Extract keywords for pattern matching
            ThoughtAnalyzer.shared.updateKeywords(for: thought)

            context.insert(thought)
        }

        // Save all changes
        try context.save()

        return testData.thoughts.count
    }

    /// Clear all thoughts from database
    /// - Parameter context: SwiftData ModelContext
    /// - Throws: Error if deletion fails
    static func clearAllData(context: ModelContext) throws {
        let descriptor = FetchDescriptor<AnxiousThought>()
        let thoughts = try context.fetch(descriptor)

        for thought in thoughts {
            context.delete(thought)
        }

        try context.save()
    }

    /// Get count of current thoughts in database
    /// - Parameter context: SwiftData ModelContext
    /// - Returns: Number of thoughts
    static func getThoughtCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<AnxiousThought>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
}
#endif
