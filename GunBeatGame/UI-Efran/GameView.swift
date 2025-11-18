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

    var time : Double = 0.0 //Time measured in seconds
    var beat : Double = 0.0 //Time measured in beats that elapsed since the song started
        //For example: If BPM is 120, and 1.2 seconds have passed since the song started, then Time is 1.2 and Beat is 2.4

    var preloadedBubbles: [Bubble] = [];
    var spawnedBubbles : [Bubble] = [];
    var hitBubbles : [Bubble] = [];
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1/FPS)) {timeline in
            ZStack  {
                GeometryReader{geometry in
					//Rendering goes here
					ForEach(spawnedBubbles) { bubble in
						Rectangle()
						.fill(Color.blue)
						.frame(
							width: geometry.size.width * CGFLoat(bubble.WIDTH),
							height: geometry.size.height * CGFLoat(bubble.HEIGHT)
						)
						.position(
							x: geometry.size.width * 0.35,
							y: geometry.size.height * 0.2 - CGFLoat(bubble.PosAboveBarrel)
						)
					}
                    Button("Gun") {
                        fireGun()
                    }.frame(width:geometry.size.width * 0.3, height: geometry.size.height*0.2)
                        .background(Color.blue)
                        .foregroundColor(Color.red)
                        .cornerRadius(8)
                        .position(x: geometry.size.width * 0.7, y : geometry.size.height * 0.7)
				}
            }
        }
		.onAppear
		{
			physicsProcess()
		}
    }
    func startGame() //Triggers on song start / restart
    {
        preloadBubbles()
		beat = 0.0;
		time = 0.0;
    }
    func physicsProcess() //Triggers every frame
    {
        time += 1.0 / FPS
        beat = time * 60.0 / BPM
		spawnBubbles()
        print(Beat)
    }
    func preloadBubbles() //Creates all bubble objects before the song plays
    {
		//TODO: put more bubbles here ig
        preloadedBubbles.append(Bubble(targetBeat : 3.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 4.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 6.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 8.0, speedInScreensPerBeat : 0.5))
    }
	func spawnBubbles() { //Spawns all bubbles if their spawn time has arrived 
		for i in (0..<preloadedBubbles.count).reversed() { //From last to first bc removing array elements moves the remaining ones'
			let bubble = preloadedBubbles[i]
			if bubble.SpawnBeat < beat {
				spawnedBubbles.append(bubble)
				preloadedBubbles.remove(at: index)
			}
		}
	}
	func fireGun()
	{
		print("Fired")
	}
}

class Bubble {
    let SPAWN_SCREEN_OFFSET : Double = 1.5 // How many screens above the barrel the button should spawn (above 1 = offscreen)
    
    let WIDTH : Double = 0.1
    let HEIGHT : Double = 0.05
        // Bubble dimensions on screen
    
    var TargetBeat : Double
        // The number of beat at which the bubble should line up with the barrel
        // NOTE: the length of each beat varies from song to song and will be stored in the parent
        // EXAMPLE: 3.5 = 3 and a half beats after the song starts
    
    var SpeedInScreensPerBeat : Double
    var SpawnBeat : Double
		//The beat at which the bubble should be spawned
    var PosAboveBarrel : Double
		//Vertical position. Positive = bubble is above barrel, negative = bubble is below barrel
    
    init(targetBeat : Double, speedInScreensPerBeat : Double) // Constructor
    {
        TargetBeat = targetBeat
        SpeedInScreensPerBeat = speedInScreensPerBeat
        SpawnBeat = targetBeat - SPAWN_SCREEN_OFFSET / speedInScreensPerBeat
        PosAboveBarrel = SPAWN_SCREEN_OFFSET
    }
    
    func updatePos(beatTime : Double) // Updates position of spawned bubbles
    {
        PosAboveBarrel = (beatTime - TargetBeat) * SpeedInScreensPerBeat
    }
}

#Preview {
    GameView()
}
