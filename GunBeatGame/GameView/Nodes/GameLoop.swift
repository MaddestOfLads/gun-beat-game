import SwiftUI
import Combine
import AVFoundation
//The designated root node with no parent.
//This is the only node with its own update timer - all other nodes are updated when this one updates itself.

class GameLoop : Node, ObservableObject{

    @Published var frame : Int = 0 //Frame number; changing this triggers view updates
    let FPS : Double = 60.0
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    var isPaused : Bool = false

    var frameTimer : Timer?

    var packedBubbles : [PackedBubble] = []
    var indexOfNextBubbleToSpawn : Int = 0

	var song_player : AVAudioPlayer!

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

    lazy var pauseButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.95, y:0.05),
            dimensions: CGSize(width:0.1, height:0.1),
            color: Color.brown,
            text: "Pause",
            onPressed: { self.togglePause() }
        )
        return button
    }()
    
    lazy var restartButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.85, y:0.05),
            dimensions: CGSize(width:0.1, height:0.1),
            color: Color.brown,
            text: "Restart",
            onPressed: { self.startOrRestartSong() }
        )
        return button
    }()

    lazy var scoreCounter : TextNode = {
        let text = TextNode(
            position: CGPoint(x: 0.7, y: 0.6),
            dimensions: CGSize(width: 0.2, height: 0.05),
            color: Color.black,
            text: ""
        )
    }
    
    init(levelData : LevelData) {
        super.init()
        loadLevelData(levelData: levelData)
        setupAudioSession()
        spawnLevelUI()
        let dt = 1.0 / FPS
        let db = dt * (self.bpm / 60.0)
        frameTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { _ in
            if(!isPaused) {
                self.physicsProcessSelfThenChildren(dt: dt, db: db)
            }
        }
        startOrRestartSong()
    }

    func spawnLevelUI()
    {
        addChild(gunButton)
        addChild(pauseButton)
        addChild(restartButton)
    }
    
    func setupAudioSession()
    {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    func startOrRestartSong() {
        beat = 0.0
        song_player.stop()
        
        for child in children{
            if let bubble = child as? BubbleNode {
                removeChild(bubble)
            }
        }
        
        print("Playing song")
        song_player.play(atTime: 0.0)
    }

    func loadLevelData(levelData : LevelData)
    {
        /**
         
        let parts = levelData.musicAssetName.split(separator: "/").map(String.init)
        let last = parts.last ?? levelData.musicAssetName
        let subdir = parts.count > 1 ? parts.dropLast().joined(separator: "/") : nil

        let fileParts = last.split(separator: ".", maxSplits: 1).map(String.init)
        let name = fileParts.first ?? last
        let ext  = fileParts.count == 2 ? fileParts[1] : "wav"
         */
        
        if let url = Bundle.main.url(forResource: levelData.musicAssetName, withExtension: "wav") {
            do {
                print("Audio file loaded successfully", levelData.musicAssetName)
                song_player = try AVAudioPlayer(contentsOf: url)
                song_player.prepareToPlay()
            } catch {
                print("❌ AVAudioPlayer init failed:", error)
            }
        } else {
            print("❌ Could not find audio file:", levelData.musicAssetName)
        }
        
        // DO NOT return; let bubbles load regardless

		// Load bubbles
        for bubble in levelData.bubbles {

            let r = Double(bubble.color.r) / 255.0
            let g = Double(bubble.color.g) / 255.0
            let b = Double(bubble.color.b) / 255.0
            let c = Color(red: r, green: g, blue: b)

            self.packedBubbles.append(
                PackedBubble(
                    targetBeat: Double(bubble.targetBeat),
                    speed: Double(bubble.speed),
                    height: Double(bubble.size),
                    color: c
                )
            )
        }

        //Sort bubbles by spawn time ascending to simplify spawn logic
        packedBubbles = packedBubbles.sorted {$0.spawnBeat < $1.spawnBeat}
    }

    override func physicsProcess(dt: Double, db: Double) {
        frame += 1
        beat += db
        spawnBubbles()
    }
    
    //Spawns next bubble if its spawn time has come
    func spawnBubbles() {
        while indexOfNextBubbleToSpawn < packedBubbles.count &&
              beat > packedBubbles[indexOfNextBubbleToSpawn].spawnBeat {

            print("Spawning bubble at beat:", beat,
                  "spawnBeat:", packedBubbles[indexOfNextBubbleToSpawn].spawnBeat)
            print("beat:", beat, "count:", packedBubbles.count, "nextIdx:", indexOfNextBubbleToSpawn)
            let newBubble = BubbleNode(pb: packedBubbles[indexOfNextBubbleToSpawn])
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

    func togglePause() {
        if(!isPaused){
            pauseButton.text = "Resume"
            isPaused = true
            song_player.pause()
        }else{
            pauseButton.text = "Pause"
            isPaused = false;
            song_player.play()
        }
    }
    //TODO: pause button
    //TODO: restart button
    //TODO: score counter
    //TODO: music
    //TODO: improve bubble pop animation


}
