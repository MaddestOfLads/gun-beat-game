import Foundation
import XCTest
@testable import GunBeatGame 

final class LevelManagerBasicTests: XCTestCase {
    private func makeBundle(files: [(path: String, contents: String)]) throws -> Bundle {
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let bundleURL = baseURL.appendingPathComponent("Test.bundle", isDirectory: true)
        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)

        let infoPlist: [String: Any] = [
            "CFBundleIdentifier": "com.test.bundle.\(UUID().uuidString)",
            "CFBundleName": "TestBundle",
            "CFBundleVersion": "1"
        ]
        let infoURL = bundleURL.appendingPathComponent("Info.plist")
        let infoData = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try infoData.write(to: infoURL)

        for file in files {
            let fileURL = bundleURL.appendingPathComponent(file.path)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard let data = file.contents.data(using: .utf8) else {
                throw NSError(domain: "LevelManagerBasicTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode file contents."])
            }
            try data.write(to: fileURL)
        }

        guard let bundle = Bundle(url: bundleURL) else {
            throw NSError(domain: "LevelManagerBasicTests", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create bundle."])
        }
        return bundle
    }

    func testLoadLevelDataAcceptsJSONFilename() throws {
        let json = """
        {
          "id": "sample_level",
          "title": "Sample Level",
          "description": "Simple level for beginners.",
          "songBPM": 90.0,
          "startingAmmo": 3,
          "ammoDivisor": 1,
          "scoreFor1StarRating": 10,
          "scoreFor2StarRating": 20,
          "scoreFor3StarRating": 30,
          "missedScoreThresholdForFailure": 5,
          "musicAssetName": "sample_song",
          "backgroundAssetName": "sample_bg",
          "coverAssetName": "sample_cover",
          "bubbles": [
            {
              "targetBeat": 1.0,
              "size": 0.05,
              "speed": 0.2,
              "color": { "r": 255, "g": 255, "b": 255 }
            }
          ]
        }
        """
        let bundle = try makeBundle(files: [(path: "sample.json", contents: json)])

        let level = loadLevelData(fileName: "sample.json", bundle: bundle)

        XCTAssertNotNil(level)
        XCTAssertEqual(level?.id, "sample_level")
        XCTAssertEqual(level?.bubbles.count, 1)
    }
}
