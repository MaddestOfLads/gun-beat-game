import SwiftUI

#Preview {
    GameView()
}

//GameView: responsible for rendering (drawing) game objects
struct GameView: View {
    
    //Most game logic happens inside gameLoop.
    //This constructor kickstarts everything.


	init(levelData : LevelData){
		self.levelData = levelData
	}
	let levelData : LevelData
    @ObservedObject var gameLoop = GameLoop(levelData)

    var body: some View {
        //View should automatically update when gameLoop triggers the next frame
        GeometryReader{geo in
            ZStack {
                gameLoop.drawSelfThenChildren(in: geo.size)
            }
        }
    }

}


