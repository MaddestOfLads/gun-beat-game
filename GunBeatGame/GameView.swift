//
//  GameView.swift
//  GunBeatGame
//
//  Created by stud on 14/10/2025.
//

import SwiftUI

#Preview {
    GameView()
}

//TODO: physics controller

struct GameView: View { // RENDERING CODE GOES HERE.

    @StateObject private var controller = GameController() //TODO

    var body: some View {
        GeometryReader{geo in
            ZStack  {
                //TODO: draw child nodes.
                Button("Gun") { //TODO: make the gun its own node

                }.frame(width:geo.size.width * 0.3, height: geo.size.height*0.2)
                    .background(Color.blue)
                    .foregroundColor(Color.red)
                    .cornerRadius(8)
                    .position(x: geo.size.width * 0.7, y : geo.size.height * 0.7)
            }
        }
    }

}

class Node {

    var parent: Node?
    var children: [Node] = []

    
    func addChild(_ node: Node) {
        node.parent = self
        children.append(node)
        node.enterTree()
    }

    func removeChild(_ node: Node) {
        if let index = children.firstIndex(where: { $0 === node }) {
            children.remove(at: index)
            node.parent = nil
        }
    }

    func enterTree() {
        //Override this with code that triggers at the start of lifetime
    }
    func physicsProcess(dt: Double, bt : Double)
    {
        //Override this with code that triggers every frame
    }
    func draw(in size: CGSize) -> AnyView {
        //Override this with drawing code
    }
    
    final func physicsProcessSelfThenChildren(dt: Double, bt: Double) { //Wrapper for physicsProcess() that implements tree order (first self, then children)
        physicsProcess(dt: <#T##Double#>, bt: <#T##Double#>)
        for child in children {
            child.physicsProcessSelfThenChildren(dt: dt, bt: bt)
        }
    }


    final func drawSelfThenChildren(in size : CGSize) -> AnyView //Wrapper for draw() that imprements tree order (first self, then children)
    {
        let childViews = children.map { child in
            child.draw(in: size)
        }

        return AnyView(
            ZStack {
                ForEach(0..<childViews.count, id: \.self) { i in
                    childViews[i]
                }
            }
        )
    }
}


class SceneTree{ //Contains all of the bubbles.
    
    @State var time : Double = 0.0 //Time measured in seconds
    @State var beat : Double = 0.0 //Time measured in beats that elapsed since the song started
        //For example: If BPM is 120, and 1.2 seconds have passed since the song started, then Time is 1.2 and Beat is 2.4

    @State var preloadedBubbles: [Bubble] = [];
    @State var spawnedBubbles : [Bubble] = [];
    @State var hitBubbles : [Bubble] = [];
    func enterTree() //Triggers on song start / restart
    {
        preloadBubbles()
        beat = 0.0
        time = 0.0
    }
    func physicsProcess(dt : Double, db : Double) //Triggers every frame. Performs all real-time physics calculations (tells bubbles to move, etc). Runs all children physicsProcesses too.
    {
        time += dt
        beat += db
        spawnBubbles()
        for bubble in spawnedBubbles{
            bubble.physicsProcess(dt: dt, db: db);
        }
        print(beat)
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
                preloadedBubbles.remove(at: i)
            }
        }
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
        // EXAMPLE: 3.5 means the bubble will line up with the barrel 3 and a half beats after the song starts
    
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

