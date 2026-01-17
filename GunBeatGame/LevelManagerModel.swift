//Here we have the code for decoding levels from the JSON files stored in the assetsa


import Foundation
import SwiftUI
import Combine



struct LevelData: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let songBPM: Float
    let bubbles: [Bubble]
    let startingAmmo: Int 
    let ammoDivisor: Int
    let scoreFor1StarRating: Int
    let scoreFor2StarRating: Int
    let scoreFor3StarRating: Int
    let missedScoreThresholdForFailure : Int
        // If at any point your score DECREASES by a total equivalent to this amount, you lose.
        // Example: if threshold for failure is 150, and your highest score 
        // you instantly fail the level.
    let musicAssetName: String
    let backgroundAssetName: String
    let coverAssetName: String
}

struct Bubble: Codable {
    let targetBeat: Float
    let size: Float //IN SCREENS!!
    let speed: Float // SCREENS PER BEAT
    let color: RGBColor
}

struct RGBColor: Codable {
    let r: Int
    let g: Int
    let b: Int
}



func loadLevelData(named fileName: String) -> LevelData? {
    let clean = fileName.replacingOccurrences(of: ".json", with: "")

    let candidates: [URL?] = [
        Bundle.main.url(forResource: clean, withExtension: "json", subdirectory: "Levels"),
        Bundle.main.url(forResource: clean, withExtension: "json")
    ]

    guard let url = candidates.compactMap({ $0 }).first else {
        let inLevels = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Levels") ?? []
        let inRoot   = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("❌ Could not find \(clean).json")
        print("JSON in Levels:", inLevels.map { $0.lastPathComponent })
        print("JSON in root:", inRoot.map { $0.lastPathComponent })
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(LevelData.self, from: data)
    } catch {
        print("❌ Found file but failed to decode:", url.lastPathComponent, error)
        return nil
    }
}


func loadAllLevels() -> [LevelData] {
    var levels: [LevelData] = []

    guard let levelsURL = Bundle.main.url(forResource: "Levels", withExtension: nil) else {
        print("Could not find Levels folder in bundle")
        return []
    }

    do {
        let contents = try FileManager.default.contentsOfDirectory(at: levelsURL, includingPropertiesForKeys: nil)
        let jsonFiles = contents.filter { $0.pathExtension == "json" }

        for file in jsonFiles {
            let fileName = file.deletingPathExtension().lastPathComponent

            if let level = loadLevelData(named: fileName) {
                levels.append(level)
            } else {
                print("Failed to load level: \(fileName)")
            }
        }
    } catch {
        print("Error reading Levels directory:", error)
    }
    return levels
}

class LevelViewModel: ObservableObject {
    @Published var levels: [LevelData] = []

    init() {
       
        loadLevels()
    }

    func loadLevels() {
        // 1. Look for the file named "1.json" in the main bundle
        if let url = Bundle.main.url(forResource: "1", withExtension: "json") {
            do {
                // 2. Try to read the data
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                // 3. Decode it into your LevelData structure
                let level = try decoder.decode(LevelData.self, from: data)
                
                // 4. Add it to our list
                self.levels = [level]
                print("Success: Loaded level \(level.title)")
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Error: Could not find file '1.json'")
        }
    }
}
