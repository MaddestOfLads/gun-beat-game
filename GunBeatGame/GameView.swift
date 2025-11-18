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

    @State var time : Double = 0.0 //Time measured in seconds
    @State var beat : Double = 0.0 //Time measured in beats that elapsed since the song started
        //For example: If BPM is 120, and 1.2 seconds have passed since the song started, then Time is 1.2 and Beat is 2.4

    @State var preloadedBubbles: [Bubble] = [];
    @State var spawnedBubbles : [Bubble] = [];
    @State var hitBubbles : [Bubble] = [];
    
    var body: some View {
        GeometryReader{geo in
            ZStack  {
                ForEach(spawnedBubbles.indices, id: \.self) {i in
                    spawnedBubbles[i].draw(in: geo.size)
                }
                Button("Gun") {
                    fireGun()
                }.frame(width:geo.size.width * 0.3, height: geo.size.height*0.2)
                    .background(Color.blue)
                    .foregroundColor(Color.red)
                    .cornerRadius(8)
                    .position(x: geo.size.width * 0.7, y : geo.size.height * 0.7)
            }
        }
    }
    mutating func startGame() //Triggers on song start / restart
    {
        preloadBubbles()
        beat = 0.0
		time = 0.0
    }
    mutating func physicsProcess() //Triggers every frame
    {
        var dt = 1.0 / FPS
        var db = 60.0 / BPM
        time += dt
        beat += db
		spawnBubbles()
        for bubble in spawnedBubbles{
            bubble.physicsProcess(dt: dt, db: db);
        }
        print(beat)
    }
    mutating func preloadBubbles() //Creates all bubble objects before the song plays
    {
		//TODO: put more bubbles here ig
        preloadedBubbles.append(Bubble(targetBeat : 3.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 4.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 6.0, speedInScreensPerBeat : 0.5))
        preloadedBubbles.append(Bubble(targetBeat : 8.0, speedInScreensPerBeat : 0.5))
    }
	mutating func spawnBubbles() { //Spawns all bubbles if their spawn time has arrived
		for i in (0..<preloadedBubbles.count).reversed() { //From last to first bc removing array elements moves the remaining ones'
			let bubble = preloadedBubbles[i]
			if bubble.SpawnBeat < beat {
				spawnedBubbles.append(bubble)
				preloadedBubbles.remove(at: i)
			}
		}
	}
	func fireGun()
	{
		print("Fired")
	}
}

class Bubble{
    
    var width : CGFloat = 0.1
    var height : CGFloat = 0.05
    var pos : CGPoint = CGPoint(x: 0.35, y: -0.5)
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
        SpawnBeat = targetBeat - pos.y / speedInScreensPerBeat
    }
    func physicsProcess(dt : Double, db : Double) //Makes the bubble move itself; should be called once per frame
    {
        pos.y -= db * SpeedInScreensPerBeat
        //todo: despawn if y == 1 (aka reaches end of track)
        //todo: despawn if shot (somehow)
    }
    func draw(in size: CGSize) -> some View { //Makes the bubble return itself as a shape
        return Rectangle()
            .fill(color)
            .frame(width: width * size.width, height: height * size.height)
            .position(x: pos.x * size.width, y: pos.y * size.height)
    }
}

#Preview {
    GameView()
}
