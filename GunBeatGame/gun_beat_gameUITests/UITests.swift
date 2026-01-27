import XCTest

final class UITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testPlayButtonNavigatesToLevelSelect() {
        let app = XCUIApplication()
        app.launch()

        let playButton = app.buttons["playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 2), "Play button should be visible on the title screen.")
        playButton.tap()

        let levelSelectTitle = app.staticTexts["levelSelectTitle"]
        XCTAssertTrue(levelSelectTitle.waitForExistence(timeout: 5), "Level select view should appear after tapping Play.")
    }

    func testHowToPlayButtonOpensInstructions() {
        let app = XCUIApplication()
        app.launch()

        let howToPlayButton = app.buttons["howToPlayButton"]
        XCTAssertTrue(howToPlayButton.waitForExistence(timeout: 2), "How to Play button should be visible on the title screen.")
        howToPlayButton.tap()

        let howToPlayTitle = app.staticTexts["howToPlayTitle"]
        XCTAssertTrue(howToPlayTitle.waitForExistence(timeout: 5), "How to Play screen should appear after tapping the button.")
    }
}
