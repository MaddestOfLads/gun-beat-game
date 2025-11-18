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
            spawnedBubbles.ForEach {
                $0.draw()
            }
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
        val dt = 1.0 / FPS
        val db = 60.0 / BPM
        time += dt
        beat += db
		spawnBubbles()
        spawnedBubbles.ForEach {
            $0.physicsProcess(1.0 / FPS, time * 60.0 / BPM);
        }
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

class Bubble : renderableBody2D, physicsBody{
    
    var width : CGFLoat = 0.1
    var height : CGFLoat = 0.05
    var pos : CGPoint = (0.35, -0.5)
        // (0, 0) is top left, (1, 1) is bottom right
    var color : Color = Color.blue

    var TargetBeat : Double
        // The number of beat at which the bubble should line up with the barrel
        // NOTE: the length of each beat varies from song to song and will be stored in the parent
        // EXAMPLE: 3.5 = 3 and a half beats after the song starts
    
    var SpeedInScreensPerBeat : Double
    var SpawnBeat : Double
		//The beat at which the bubble should be spawned
    
    init(targetBeat : Double, speedInScreensPerBeat : Double) // Constructor
    {
        TargetBeat = targetBeat
        SpeedInScreensPerBeat = speedInScreensPerBeat
        SpawnBeat = targetBeat - SPAWN_SCREEN_OFFSET / speedInScreensPerBeat
    }
    func physicsProcess(dt : Double, db : Double) //Makes the bubble move itself; should be called once per frame
    {
        y -= db * SpeedInScreensPerBeat
        //todo: despawn if y == 1 (aka reaches end of track)
        //todo: despawn if shot (somehow)
    }
    func draw() -> some View { //Makes the bubble render itself on screen; should be called after each PhysicsProcess
        GeometryReader{geo in
        Rectangle()
            .fill(color)
            .frame(width: width * geo.size.width, height: height * geo.size.height)
            .position(x: pos.x * geo.size.width, pos.y * geo.size.height)
        }
    }

}

#Preview {
    GameView()
}

protocol body2D
{
    var pos : CGPoint {get; set;}
    var screenPos : CGPoint {get => CGPoint(pos.x * geo.size.width, pos.y * geo.size.height)}
}

protocol physicsBody
{
    func physicsProcess(dt : Double, db : Double)
}

protocol renderableBody2D : body2D
{
    func draw() -> some View
}