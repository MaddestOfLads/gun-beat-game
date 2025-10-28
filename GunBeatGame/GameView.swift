//
//  GameView.swift
//  GunBeatGame
//
//  Created by stud on 14/10/2025.
//

import SwiftUI


struct GameView: View {
    
    @State var gameTime : Double = 0.0
    @State var beatTime : Double = 0.0
    var FPS : Double = 30.0
    var BPM : Double = 120.0 //Beats per minute; will depend on song
    
    var body: some View {
        GeometryReader{geometry in
            Button("Gun") {
                print("fire")
            }.frame(width:geometry.size.width * 0.3, height: geometry.size.height*0.2)
            .background(Color.blue)
            .foregroundColor(Color.red)
            .cornerRadius(8)
            .position(x: geometry.size.width * 0.7, y : geometry.size.height * 0.7)
        }.onAppear() //todo: add more ui elements
        {
            //Actual game logic goes here
            
            var unspawnedBubbles = {
                Bubble(targetBeat : 3.0, speedInScreensPerBeat : 0.5)
            }
            
            self.beatTime = self.gameTime
            var gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { gameTimer in
                //THINGS THAT HAPPEN EVERY FRAME GO HERE
                self.gameTime += 1.0/self.FPS
                self.beatTime += 1.0/BPM*60.0
                print(self.gameTime)
            }
        }
    }
}

class Bubble {
    let SPAWN_SCREEN_OFFSET : Double = 1.0 // How many screens above the barrel the button should spawn
    
    let BUBBLE_WIDTH : Double = 0.1
    let BUBBLE_HEIGHT : Double = 0.05
    
    var TargetBeat : Double // The number of beat at which the bubble should line up with the barrel
        //NOTE: the length of each beat varies from song to song and will be stored in the parent
        //EXAMPLE: 3.5 = 3 and a half beats after the song starts
    
    var SpeedInScreensPerBeat : Double
    
    var SpawnBeat : Double
    
    init(targetBeat : Double, speedInScreensPerBeat : Double) // Constructor
    {
        TargetBeat = targetBeat
        SpeedInScreensPerBeat = speedInScreensPerBeat
        SpawnBeat = targetBeat - SPAWN_SCREEN_OFFSET / speedInScreensPerBeat
    }
    
    func getPos(beatTime : Double)
    {
        
    }
    
}

#Preview {
    GameView()
}
