//Here we have the code for storing any information that relates to the user, such as settings and progress. LEVELS ITSELF ARE MANAGED IN LevelMangerModel.swift

import Foundation
import SwiftData

//i need you to make a function that takes in this object and updates the database
struct LevelResult: Codable {
    let level_id: String
    let total_score : Int
    let total_stars : Int
}

@Model
final class LevelResultRecord {
    var level_id: String
    var total_score: Int
    var total_stars: Int
    var created_at: Date

    init(level_id: String, total_score: Int, total_stars: Int, created_at: Date = Date()) {
        self.level_id = level_id
        self.total_score = total_score
        self.total_stars = total_stars
        self.created_at = created_at
    }
}

// A shared container for this file so callers don't need to pass a ModelContext
private enum _LevelResultStorage {
    // Lazily create a ModelContainer for LevelResultRecord
    static let container: ModelContainer = {
    
        let container = try! ModelContainer(for: LevelResultRecord.self)
        return container
    }()

    static var context: ModelContext { ModelContext(container) }
}

func storeLevelResult(_ result: LevelResult, context: ModelContext) throws {
    let record = LevelResultRecord(
        level_id: result.level_id,
        total_score: result.total_score,
        total_stars: result.total_stars
    )
    context.insert(record)
    try context.save()
}

func storeLevelResult(_ result: LevelResult) throws {
    try storeLevelResult(result, context: _LevelResultStorage.context)
}
