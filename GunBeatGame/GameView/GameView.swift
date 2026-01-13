

import SwiftUI

struct GameView: View {
    let levelData: LevelData
    @StateObject private var gameLoop: GameLoop

    init(levelData: LevelData) {
        self.levelData = levelData
        _gameLoop = StateObject(wrappedValue: GameLoop(levelData: levelData))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                gameLoop.drawSelfThenChildren(in: geo.size)
            }
        }
    }
}


