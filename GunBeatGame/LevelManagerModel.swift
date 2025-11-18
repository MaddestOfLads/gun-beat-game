import Foundation

struct LevelData: Codable {
    let id: String
    let title: String
    let description: String
    let songBPM: Float
    let bubbles: [Bubble]
    let startingAmmo: Int
    let ammoDivider: Int
    let musicAssetName: String
    let backgroundAssetName: String
    let coverAssetName: String
}

struct Bubble: Codable {
    let targetBeat: Float
    let size: Float         // in screens
    let speed: Float        // screens per beat
    let color: RGBColor
}

struct RGBColor: Codable {
    let r: Int
    let g: Int
    let b: Int
}



func loadLevelData(named fileName: String) -> LevelData? {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("Could not find \(fileName).json")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(LevelData.self, from: data)
    } catch {
        print("Failed to decode JSON:", error)
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

            if let level = loadLevelData(named: "Levels/\(fileName)") {
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