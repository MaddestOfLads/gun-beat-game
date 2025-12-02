
//The designated root node with no parent.
//This is the only node with its own update timer - all other nodes are updated when this one updates itself.

class GameLoop : Node, ObservableObject{

    @Published var frame : Int = 0 //Frame number; changing this triggers view updates
    let FPS : Double = 60.0
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    var frameTimer : Timer?

    var packedBubbles : [PackedBubble]
    var indexOfNextBubbleToSpawn : Int = 0
    
    var gunButton : BubbonNode

    init() {
        enterTree()
    }

    func enterTree() {
        loadLevelData(120.0)
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
        gunButton = ButtonNode(
            position: CGPoint(0.7, 0.8),
            dimensions: CGSize(0.2, 0.15),
            color: Color.green(),
            text: "Gun",
            onPressed: {fireGun()}
        )
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
        self.packedBubbles = packedBubbles

        //TODO: load bubbles from file instead
            //Note: PackedBubble has more optional arguments, see PackedBubble.swift
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
    func fireGun() {
        //TODO: handle gunfire
    }

    //TODO: make bubbles poppable
    //TODO: do something when bubbles aren't popped
}