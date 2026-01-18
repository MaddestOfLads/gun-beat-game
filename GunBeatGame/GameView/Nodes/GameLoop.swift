import SwiftUI
import Combine
import AVFoundation
//The designated root node with no parent.
//This is the only node with its own update timer - all other nodes are updated when this one updates itself.

class GameLoop : Node, ObservableObject{

    @Published var frame : Int = 0 //Frame number; changing this triggers view updates
    let FPS : Double = 60.0
    let MAX_SCORE_PER_BUBBLE : Int = 100
    var bubblePopHeight : CGFloat = 0.8
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    @Published var isPaused : Bool = false // Published to trigger view updates on pause (because frame won't change duh)

    var frameTimer : Timer?

    var packedBubbles : [PackedBubble] = []
    var indexOfNextBubbleToSpawn : Int = 0

	var song_player : AVAudioPlayer!

    var current_score : Float = 0
    var missed_score : Float = 0
    let MISSED_SCORE_HEAL_AMOUNT : Float = 0.2 // Restore this much missed score for every 1pt of gained score
    var missedScoreThresholdForFailure : Float = 200.0

    var level_loss_animation_playing : Bool = false
    let LEVEL_LOSS_TIME : Double = 0.5
    var level_loss_time_left : Double = 0.5

    var level_win_animation_playing : Bool = false
    let LEVEL_WIN_TIME : Double = 2.0
    var level_win_time_left : Double = 2.0
    
    lazy var gunButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.7, y:0.8),
            scale: CGSize(width:0.3, height:0.15),
            color: Color.green,
            text: "Gun",
            onPressed: { self.fireGun() }
        )
        return button
    }()
    
    lazy var pauseButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.85, y:0.05),
            scale: CGSize(width:0.3, height:0.1),
            color: Color.brown,
            text: "Pause",
            onPressed: { self.togglePause() }
        )
        return button
    }()
    
    lazy var restartButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.85, y:0.15),
            scale: CGSize(width:0.3, height:0.1),
            color: Color.brown,
            text: "Restart",
            onPressed: { self.startOrRestartSong() }
        )
        return button
    }()

    lazy var scoreCounter : TextNode = {
        let counter = TextNode(
            position: CGPoint(x: 0.7, y: 0.6),
            scale: CGSize(width: 0.2, height: 0.05),
            color: Color.black,
            text: "0"
        )
        return counter
    }()
    
    init(levelData : LevelData) {
        super.init()
        loadLevelData(levelData: levelData)
        setupAudioSession()
        spawnLevelUI()
        let dt = 1.0 / FPS
        let db = dt * (self.bpm / 60.0)
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false){_ in
            startPhysicsProcess()
        }
    }

    func startPhysicsProcess(){
        startOrRestartSong()
        frameTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { _ in
            if(!self.isPaused) {
                self.physicsProcessSelfThenChildren(dt: dt, db: db)
            }
        }
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
        level_loss_animation_playing = false

        for child in children{
            if let bubble = child as? BubbleNode {
                removeChild(bubble)
            }
        }
        
        beat = 0.0
        indexOfNextBubbleToSpawn = 0

        print("Playing song")
        if song_player.isPlaying {
            song_player.pause()
        }
        song_player.currentTime = 0.0
        song_player.play()
    }


    func loadLevelData(levelData : LevelData)
    {
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
        
        self.bpm = levelData.songBPM
        self.missedScoreThresholdForFailure = Float(levelData.missedScoreThresholdForFailure)

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
        progressLevelLossAnimationIfLost(dt:dt)
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

    // if multiple bubbles hit: accept only the ones that were hit perfectly
        // if none were hit perfectly: accept the one with the highest score
    // 
    func fireGun() {
        var bubblesInHitRange : [BubbleNode] = []
        
        for child in children{
            if let bubble = child as? BubbleNode {
                var accuracy : Double = bubble.hitAccuracy(popHeight: CGFloat(bubblePopHeight))
                if (accuracy > 0.0) {
                    bubblesInHitRange.append(bubble)
                }
            }
        }

        var bubblesHitPerfectly : [BubbleNode] = []
        for bubble in bubblesInHitRange{
            if bubble.hitAccuracy(popHeight: bubblePopHeight) == 1.0 {
                bubblesHitPerfectly.append(bubble)
            }
        }

        if bubblesHitPerfectly.count > 0 { 
            for bubble in bubblesHitPerfectly{
                popBubble(bubble: bubble)
            }
        }
        else if bubblesInHitRange.count > 0 {
            bubblesInHitRange = bubblesInHitRange.sorted {$0.hitAccuracy(popHeight : bubblePopHeight) > $1.hitAccuracy(popHeight : bubblePopHeight)}
            popBubble(bubble: bubblesInHitRange[0])
        }
        else
        {
            changeScore(changeAmount: -Float(MAX_SCORE_PER_BUBBLE))
        }
    }

    func popBubble(bubble : BubbleNode){
        var hit_accuracy : Float = Float(bubble.hitAccuracy(popHeight: bubblePopHeight))
        var added_score : Float = ceil(hit_accuracy * Float(MAX_SCORE_PER_BUBBLE))
        changeScore(changeAmount: added_score)
        bubble.getHit()
        if(areVictoryCriteriaFulfilled()) {
            startLevelWinAnimation()
        }
    }

    func togglePause() {
        if(!isPaused){
            pauseButton.text = "Resume"
            isPaused = true // set after pauseButton text change to trigger a view update
            song_player.pause()
        }else{
            pauseButton.text = "Pause"
            isPaused = false;
            song_player.play()
        }
    }

    func changeScore(changeAmount : Float) {
        if (changeAmount >= 0) {
            current_score += changeAmount
            missed_score -= changeAmount * MISSED_SCORE_HEAL_AMOUNT
            scoreCounter.pulseColor(pulseTime: 0.25, color: Color.green, fadeIn: false)
        }
        else
        {
            missed_score -= changeAmount
            scoreCounter.pulseColor(pulseTime: 0.25, color: Color.red, fadeIn: false)
            if (missed_score > missedScoreThresholdForFailure)
            {
                startLevelLossAnimation()
            }
        }
        scoreCounter.text = String(current_score)
    }

    func startLevelLossAnimation() {
        for child in children {
            if let bubble = child as? BubbleNode {
                bubble.slowing_down = true
            }
            if let vfxNode = child as? VfxCapableNode {
                vfxNode.pulseColor(pulseTime: 0.5, color: Color.red, fadeIn: false)
            }
        }
    }
    
    func progressLevelLossAnimationIfLost(dt : Double){
        if(level_loss_animation_playing){
            level_loss_time_left -= dt
            if (level_loss_time_left <= 0.0){
                startOrRestartSong()
            }
        }
    }

    func areVictoryCriteriaFulfilled() -> Bool {
        if indexOfNextBubbleToSpawn < packedBubbles.count {return false}
        for child in children {
            if let bubble = child as? BubbleNode {
                if !bubble.isPopped {return false}
            }
        }
        return true;
    }

    func startLevelWinAnimation(){
        song_player.stop()
        level_win_animation_playing = true
        level_win_time_left = LEVEL_WIN_TIME
    }

    func progressLevelWinAnimationIfWon(dt: Double){
        level_win_time_left -= dt
        if level_win_time_left <= 0{
            returnVictorious()
        }
    }

    func returnVictorious(){
        // TODO: make this method return to main menu and update the player database
        print("Victory!")
    }

    /**
        beating a level - HALF DONE
            - triggers when there's no bubbles spawned AND id of next bubble to spawn == packed bubble count - DONE
            - fade to black
            - return to level view
        losing a level - DONE
            All VFX nodes flash red, level restarts after 0.5s
        TODO: vfx!!!
            - multiple pulse modes (fade in, fade out)
        TODO: sfx!!!
            - on bubble pop
            - on firing a missed shot
            - on letting a bubble pass
            - on level win: some kind of ding
            - on level loss: spawn white noise idk
    */
}
