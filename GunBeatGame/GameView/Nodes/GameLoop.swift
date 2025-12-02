import SwiftUI
import Combine
//The designated root node with no parent.
//This is the only node with its own update timer - all other nodes are updated when this one updates itself.

class GameLoop : Node, ObservableObject{

    @Published var frame : Int = 0 //Frame number; changing this triggers view updates
    let FPS : Double = 60.0
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    var frameTimer : Timer?

    var packedBubbles : [PackedBubble] = []
    var indexOfNextBubbleToSpawn : Int = 0
    
    lazy var gunButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.7, y:0.8),
            dimensions: CGSize(width:0.2, height:0.15),
            color: Color.green,
            text: "Gun",
            onPressed: { self.fireGun() }
        )
        return button
    }()

    override init() {
        super.init()
        loadLevelData(bpm: 120.0)
        spawnLevelUI()
        let dt = 1.0 / FPS
        let db = dt * (self.bpm / 60.0)
        frameTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { _ in
            self.physicsProcessSelfThenChildren(dt: dt, db: db)
        }
        startOrRestartSong()
    }

    func spawnLevelUI()
    {
        addChild(gunButton)
    }

    //TODO: add a song restart button to call this function
    func startOrRestartSong() {
        beat = 0.0
        //TODO: play/restart the level's song
        //TODO: destroy all spawned bubbles
    }

    func loadLevelData(bpm: Double)
        //TODO: load more things, like songs, bubble data, etc. from the database
    {
        self.bpm = bpm

        //TODO: load bubbles from file instead
            //Note: PackedBubble has more optional arguments, see PackedBubble.swift
        self.packedBubbles.append(PackedBubble(targetBeat : 2.0, speed : 0.12))
        self.packedBubbles.append(PackedBubble(targetBeat : 4.0, speed : 0.12))
        self.packedBubbles.append(PackedBubble(targetBeat : 6.0, speed : 0.12))
        self.packedBubbles.append(PackedBubble(targetBeat : 8.0, speed : 0.12))

        //Sort bubbles by spawn time ascending to simplify spawn logic
        packedBubbles = packedBubbles.sorted {$0.spawnBeat < $1.spawnBeat}
    }

    override func physicsProcess(dt : Double, db : Double)
    {
        frame += 1
        beat += db
        spawnBubbles()
        for child in children{
            child.physicsProcess(dt: dt, db: db);
        }
    }
    
    //Spawns next bubble if its spawn time has come
    func spawnBubbles() {
        while(indexOfNextBubbleToSpawn < packedBubbles.count && beat > packedBubbles[indexOfNextBubbleToSpawn].spawnBeat) {
            let newBubble : BubbleNode = BubbleNode(pb: packedBubbles[indexOfNextBubbleToSpawn])
            addChild(newBubble)
            indexOfNextBubbleToSpawn += 1
        }
    }



    func fireGun() {
        for child in children{
            if let bubble = child as? BubbleNode {
                if (bubble.hitAccuracy(popHeight: 0.8) > 0) {
                    bubble.getHit()
                }
            }
        }
    }
    //TODO: pause button
    //TODO: restart button
    //TODO: score counter
    //TODO: music
    //TODO: improve bubble pop animation


}
