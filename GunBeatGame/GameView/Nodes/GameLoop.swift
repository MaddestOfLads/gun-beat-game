
//The designated root node with no parent.
//This is the only node with its own update timer - all other nodes are updated when this one updates itself.

class GameLoop : Node, ObservableObject{

    @Published var frame : Int = 0 //Frame number; changing this triggers view updates
    let FPS : Double = 60.0
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    var frameTimer : Timer
        //The timer that triggers every frame.

    var packedBubbles : [PackedBubble]
        //These are not nodes, just data objects for spawning actual bubble nodes.
    
    var indexOfNextBubbleToSpawn : Int = 0
        //Bubbles are ordered by their spawn time. This is the index of the next bubble to spawn.
        //Should be reset to 0 every time the song is restarted.
    
    var gunButton : BubbonNode

    func init() {
        loadLevelData(120.0)
        spawnLevelUI()
        frameTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { _ in
            self.physicsProcessSelfThenChildren(dt: dt, db: db)
        }
        startOrRestartSong()
    }

    func spawnLevelUI()
    {

    }

    func startOrRestartSong() {
        beat = 0.0
        //TODO: play/restart the level's song
        //TODO: destroy all spawned bubbles
        //TODO: (later down the line)
    }

    func loadLevelData(bpm: Double)
        //TODO: load more things, like songs, bubble data, etc. here
    {
        self.bpm = bpm
        self.packedBubbles = packedBubbles

        //TODO: load bubbles from file instead
        //read packedBubble 
        self.packedBubbles.append(PackedBubble(targetBeat : 2.0, speedInScreensPerBeat : 0.5))
        self.packedBubbles.append(PackedBubble(targetBeat : 4.0, speedInScreensPerBeat : 0.5))
        self.packedBubbles.append(PackedBubble(targetBeat : 6.0, speedInScreensPerBeat : 0.5))
        self.packedBubbles.append(PackedBubble(targetBeat : 8.0, speedInScreensPerBeat : 0.5))
        
        //Sort bubbles by spawn time ascending to simplify spawn logic
        packedBubbles = packedBubbles.sorted {$0.spawnBeat < $1.spawnBeat}
    }

    func physicsProcess(dt : Double, db : Double) //Override from Node
    {
        frame += 1
        beat += db
        spawnBubbles()
        for child in children{
            child.physicsProcess(dt: dt, db: db);
        }
    }
    func preloadBubbles()
        //Creates all bubble objects before the song plays
        //This only needs to trigger ONCE, when the level is loaded. Even if you restart the song, don't trigger it again.
    {
    }
    
    //Spawns next bubble if its spawn time has come
    func spawnBubbles() {
        while(packedBubbles[indexOfNextBubbleToSpawn].spawnBeat) {
            var newBubble = packedBubbles[indexOfNextBubbleToSpawn].spawnBubble()
            addChild(newBubble)
        }
    }


    //TODO: make a gun node by extending ButtonNode

    //TODO: make the gun node trigger this function when pressed
    func onGunFired() {
        //TODO: handle gunfire
    }

    //TODO: make bubbles poppable
    //TODO: do something when bubbles aren't popped
}