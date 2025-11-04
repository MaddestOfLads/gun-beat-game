//
//  GameView.swift
//  GunBeatGame
//
//  Created by stud on 14/10/2025.
//

import SwiftUI


struct GameView: View {
    
    var FPS : Double = 60.0
    var BPM : Double = 120.0 //Beats per minute; will depend on song
    
    @State var Time : Double = 0.0 //Time measured in seconds
    @State var Beat : Double = 0.0 //Time measured in beats that elapsed since the song started
        //For example: If BPM is 120, and 1.2 seconds have passed since the song started, then Time is 1.2 and Beat is 2.4

    @State var preloadedBubbles = Array<Bubble>();
    @State var spawnedBubbles = Array<Bubble>();
    @State var hitBubbles = Array<Bubble>();
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1/FPS)) {timeline in
            //TODO: figure out this timelineview bullshit
            ZStack  {
                //TODO: add Canvas to ZStack for regularly updating elements
                GeometryReader{geometry in //GeometryReader used for static / UI elements
                    Button("Gun") {
                        print("fired")
                    }.frame(width:geometry.size.width * 0.3, height: geometry.size.height*0.2)
                        .background(Color.blue)
                        .foregroundColor(Color.red)
                        .cornerRadius(8)
                        .position(x: geometry.size.width * 0.7, y : geometry.size.height * 0.7)
                }.onAppear()
                {
                    startGame()
                }
            }
        }
    }
    func startGame() //Triggers on song start / restart
    {
        preloadBubbles()
        Beat = Time
        var gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/self.FPS, repeats: true) { gameTimer in
            //TODO: replace Timer with TimelineView
            physicsProcess()
        }
    }
    func physicsProcess() //Triggers every frame
    {
        Time += 1.0 / FPS
        Beat += 60.0 / BPM
        print(Beat)
    }
    func preloadBubbles() //Creates all bubble objects before the song plays
    {
        preloadedBubbles.append(Bubble(targetBeat : 3.0, speedInScreensPerBeat : 0.5))
    }
    func spawnbubbles() //Spawns and draws bubble objects that are about to appear on screen
    {
        for bubble in preloadedBubbles
        {
            if(bubble.SpawnBeat < Beat)
            {
                bubble.spawn()
            }
        }
    }
}

class Bubble {
    let SPAWN_SCREEN_OFFSET : Double = 1.5 // How many screens above the barrel the button should spawn
    
    let WIDTH : Double = 0.1
    let HEIGHT : Double = 0.05
        // Bubble dimensions on screen
    
    var TargetBeat : Double
        // The number of beat at which the bubble should line up with the barrel
        // NOTE: the length of each beat varies from song to song and will be stored in the parent
        // EXAMPLE: 3.5 = 3 and a half beats after the song starts
    
    var SpeedInScreensPerBeat : Double
    var SpawnBeat : Double
    var PosAboveBarrel : Double
    
    init(targetBeat : Double, speedInScreensPerBeat : Double) // Constructor
    {
        TargetBeat = targetBeat
        SpeedInScreensPerBeat = speedInScreensPerBeat
        SpawnBeat = targetBeat - SPAWN_SCREEN_OFFSET / speedInScreensPerBeat
        PosAboveBarrel = SPAWN_SCREEN_OFFSET
    }
    
    func spawn() // Creates a rectangle to represent this button
    {
        
    }
    
    func updatePos(beatTime : Double) // Updates position of spawned bubbles
    {
        PosAboveBarrel = (beatTime - TargetBeat) * SpeedInScreensPerBeat
    }
}

#Preview {
    GameView()
}
