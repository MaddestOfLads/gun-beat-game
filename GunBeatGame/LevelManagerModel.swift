//Here we have the code for decoding levels from the JSON files stored in the assetsa


import Foundation
import SwiftUI
import Combine



struct LevelData: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let songBPM: Double
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
    let size: Float = 0.05 //IN SCREENS!!
    let speed: Float = 0.2 // SCREENS PER BEAT
    let color: RGBColor
}

struct RGBColor: Codable {
    let r: Int
    let g: Int
    let b: Int
}



func loadLevelData(fileName: String, bundle: Bundle = .main) -> LevelData? {
    let clean = fileName.replacingOccurrences(of: ".json", with: "")

    let candidates: [URL?] = [
        bundle.url(forResource: clean, withExtension: "json", subdirectory: "Levels"),
        bundle.url(forResource: clean, withExtension: "json")
    ]

    guard let url = candidates.compactMap({ $0 }).first else {
        let inLevels = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Levels") ?? []
        let inRoot   = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
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


func loadAllLevels(bundle: Bundle = .main) -> [LevelData] {
    var levels: [LevelData] = []

    let levelFiles = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Levels") ?? []
    if levelFiles.isEmpty {
        print("Could not find level JSON files in bundle")
        return []
    }

    for file in levelFiles {
        let fileName = file.deletingPathExtension().lastPathComponent

        if let level = loadLevelData(fileName: fileName, bundle: bundle) {
            levels.append(level)
        } else {
            print("Failed to load level: \(fileName)")
        }
    }
    return levels
}

class LevelViewModel: ObservableObject {
    @Published var levels: [LevelData] = []
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        loadLevels()
    }

    func loadLevels() {
        let loadedLevels = loadAllLevels(bundle: bundle)
        if !loadedLevels.isEmpty {
            self.levels = loadedLevels
            print("Success: Loaded \(loadedLevels.count) level(s)")
            return
        }

        if let fallback = loadLevelData(fileName: "1", bundle: bundle) {
            self.levels = [fallback]
            print("Success: Loaded fallback level \(fallback.title)")
        } else {
            print("Error: Could not find any level JSON files")
        }
    }
}
