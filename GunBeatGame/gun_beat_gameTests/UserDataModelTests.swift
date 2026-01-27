import XCTest
@testable import GunBeatGame

final class UserDataModelTests: XCTestCase {
    func testLevelResultCodableRoundTrip() throws {
        let result = LevelResult(level_id: "level_1", total_score: 900, total_stars: 2)

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(LevelResult.self, from: data)

        XCTAssertEqual(decoded.level_id, "level_1")
        XCTAssertEqual(decoded.total_score, 900)
        XCTAssertEqual(decoded.total_stars, 2)
    }

    func testLevelResultRecordInitializer() {
        let timestamp = Date(timeIntervalSince1970: 1_234_567)

        let record = LevelResultRecord(
            level_id: "level_2",
            total_score: 1200,
            total_stars: 3,
            created_at: timestamp
        )

        XCTAssertEqual(record.level_id, "level_2")
        XCTAssertEqual(record.total_score, 1200)
        XCTAssertEqual(record.total_stars, 3)
        XCTAssertEqual(record.created_at, timestamp)
    }
}
