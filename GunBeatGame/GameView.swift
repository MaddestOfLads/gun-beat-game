//
//  GameView.swift
//  GunBeatGame
//
//  Created by stud on 14/10/2025.
//

import SwiftUI


struct GameView: View {
    @State var timePassed : Double = 0.0
    
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
                Bubble(targetBeatTime : 3.0, speedInScreensPerBeat : 0.5)
            }
            
            var gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { gameTimer in
                //THINGS THAT HAPPEN EVERY FRAME GO HERE
                self.timePassed += 1.0/30.0
                print(self.timePassed)
            }
        }
    }
}

class Bubble {
    var TargetBeatTime : Double // The number of beat at which the bubble should line up with the barrel
        //NOTE: the length of each beat varies from song to song and will be stored in the parent
        //EXAMPLE: 3.5 = 3 and a half beats after the song starts
    var SpeedInScreensPerBeat : Double
    init(targetBeatTime : Double, speedInScreensPerBeat : Double) // Constructor
    {
        TargetBeatTime = targetBeatTime
        SpeedInScreensPerBeat = speedInScreensPerBeat
    }
    func getVerticalOffsetFromBarrel(currentBeatTime : Double)
    {
        
    }
    //bubble code goes here:§
    // - function to calculate the time at which the bubble should be spawned offscreen (and begin moving)
    // - function to move the bubble, which will be called each frame by the timer if the bubble is spawned
    // - function to handle bubble being destroyed
    // - function to handle bubble hitting the end of the screen
}

#Preview {
    GameView()
}
