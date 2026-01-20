

import SwiftUI

struct GameView: View {
    let levelData: LevelData
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameLoop: GameLoop
    @State private var levelResult: LevelResult?

    init(levelData: LevelData) {
        self.levelData = levelData
        _gameLoop = StateObject(wrappedValue: GameLoop(levelData: levelData))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.black,
                            Color(red: 0.05, green: 0.03, blue: 0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.18),
                            Color.clear
                        ]),
                        center: .topTrailing,
                        startRadius: 40,
                        endRadius: 320
                    )
                }
                .ignoresSafeArea()
                gameLoop.drawSelfThenChildren(in: geo.size)

                if let result = levelResult {
                    LevelCompleteOverlay(
                        levelTitle: levelData.title,
                        score: result.total_score,
                        stars: result.total_stars,
                        onExit: { dismiss() }
                    )
                }
            }
            .onDisappear {
                gameLoop.stopGame()
            }
            .onAppear {
                gameLoop.onLevelComplete = { result in
                    levelResult = result
                }
            }
        }
    }
}

private struct LevelCompleteOverlay: View {
    let levelTitle: String
    let score: Int
    let stars: Int
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Level Complete")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text(levelTitle)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Text("Final Score: \(score)")
                    .font(.title2.bold())
                    .foregroundStyle(.yellow)

                Stars(rating: stars)
                    .font(.title3)

                Button(action: onExit) {
                    Label("Back to Levels", systemImage: "list.bullet")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white, in: Capsule())
                }
                .foregroundStyle(.black)
            }
            .padding(24)
            .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 24))
            .padding(24)
        }
    }
}
