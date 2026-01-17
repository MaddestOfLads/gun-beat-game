//Here we have the code for storing any information that relates to the user, such as settings and progress. LEVELS ITSELF ARE MANAGED IN LevelMangerModel.swift


// Make a systme that reads from this structure and we're golden
struct LevelResult: Codable, Identifiable {
    let level_id: String
    let total_score : Int
    let total_stars : Int
}