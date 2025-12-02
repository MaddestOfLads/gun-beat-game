import SwiftUI

#Preview {
    GameView()
}

//GameView: responsible for rendering (drawing) game objects
struct GameView: View {
    
    @ObservedObject var gameLoop = GameLoop()
    //Most game logic happens inside gameLoop

    var body: some View {
        //View should automatically update when gameLoop triggers the next frame
        GeometryReader{geo in
            ZStack {
                gameLoop.drawSelfThenChildren(in: geo.size)
            }
        }
    }

}


