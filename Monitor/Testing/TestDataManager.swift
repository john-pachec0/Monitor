//
//  TestDataManager.swift
//  Monitor
//
//  Service for loading test data - to be updated for meal entries in Phase 2
//  DEBUG ONLY - Not included in production builds
//

#if DEBUG
import Foundation
import SwiftData

// TODO: Phase 2 - Update test data for meal entries
// This is currently stubbed to prevent compilation errors

/// Manager for loading and managing test data
class TestDataManager {

    /// Load test meal entries into SwiftData
    /// - Parameters:
    ///   - context: SwiftData ModelContext to insert into
    ///   - clearExisting: Whether to clear existing entries first (default: false)
    /// - Returns: Number of entries loaded
    static func loadTestData(context: ModelContext, clearExisting: Bool = false) throws -> Int {
        // Clear existing data if requested
        if clearExisting {
            try clearAllData(context: context)
        }

        // TODO: Implement meal entry test data loading in Phase 2
        return 0
    }

    /// Clear all meal entries from database
    /// - Parameter context: SwiftData ModelContext
    static func clearAllData(context: ModelContext) throws {
        let descriptor = FetchDescriptor<MealEntry>()
        let entries = try context.fetch(descriptor)

        for entry in entries {
            context.delete(entry)
        }

        try context.save()
    }

    /// Get count of current meal entries in database
    /// - Parameter context: SwiftData ModelContext
    /// - Returns: Number of entries
    static func getEntryCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<MealEntry>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
}
#endif
