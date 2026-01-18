//Here we have the code for storing any information that relates to the user, such as settings and progress. LEVELS ITSELF ARE MANAGED IN LevelMangerModel.swift


//i need you to make a function that takes in this object and updates the database
struct LevelResult: Codable {
    let level_id: String
    let total_score : Int
    let total_stars : Int
}
