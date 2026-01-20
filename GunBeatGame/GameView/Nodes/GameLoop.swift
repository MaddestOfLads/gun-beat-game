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
    var bubbleMissHeight : CGFloat = 1.0
    var bpm : Double = 120.0 //Varies from song to song
    var beat: Double = 0.0
        //Time measured in beats. Resets on song restart.
    
    @Published var isPaused : Bool = false // Published to trigger view updates on pause (because frame won't change duh)

    var frameTimer : Timer?
    var level_id : String = "0"

    var packedBubbles : [PackedBubble] = []
    var indexOfNextBubbleToSpawn : Int = 0

    var songPlayer: AVAudioPlayer?
    var onLevelComplete: ((LevelResult) -> Void)?

    var current_score : Float = 0
    var missed_score : Float = 0
    let MISSED_SCORE_HEAL_AMOUNT : Float = 0.2 // Restore this much missed score for every 1pt of gained score
    var missedScoreThresholdForFailure : Float = 250.0 // miss 3 bubbles/shots in a row = fail

    var level_loss_animation_playing : Bool = false
    let LEVEL_LOSS_TIME : Double = 0.5
    var level_loss_time_left : Double = 0.5

    var level_win_animation_playing : Bool = false
    let LEVEL_WIN_TIME : Double = 2.0
    var level_win_time_left : Double = 2.0
    var pointsFor1Star : Int = 0
    var pointsFor2Star : Int = 0
    var pointsFor3Star : Int = 0

    
    var backgroundColor : Color = Color.black
    var uiColor : Color = Color.orange
    var bubbleColor : Color = Color.orange
    var bubbleFlashColor : Color = Color.white

    lazy var gunMarker : GunMarkerNode = {
        let marker = GunMarkerNode(
            position: CGPoint(x: 0.3, y: bubblePopHeight),
            scale: CGSize(width: 0.55, height: 0.01),
            color: Color.gray
        )
        return marker
    }()

    lazy var gunButton: GunButtonNode = {
        let button = GunButtonNode(
            position: CGPoint(x:0.7, y:0.8),
            scale: CGSize(width:0.3, height:0.15),
            color: self.uiColor,
            text: "Gun",
            onPressed: { self.fireGun() }
        )
        return button
    }()
    
    lazy var pauseButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.85, y:0.05),
            scale: CGSize(width:0.3, height:0.1),
            color: self.uiColor,
            text: "Pause",
            systemImageName: "pause.fill",
            onPressed: { self.togglePause() }
        )
        return button
    }()
    
    lazy var restartButton: ButtonNode = {
        let button = ButtonNode(
            position: CGPoint(x:0.85, y:0.15),
            scale: CGSize(width:0.3, height:0.1),
            color: self.uiColor,
            text: "Restart",
            systemImageName: "arrow.clockwise",
            onPressed: { self.startOrRestartSong() }
        )
        return button
    }()

    lazy var scoreCounter : TextNode = {
        let counter = TextNode(
            position: CGPoint(x: 0.7, y: 0.6),
            scale: CGSize(width: 0.25, height: 0.08),
            color: self.bubbleColor,
            text: "0"
        )
        return counter
    }()

    lazy var missFlash: MissFlashNode = {
        let flash = MissFlashNode()
        return flash
    }()

    init(levelData : LevelData, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        super.init()
        self.onLevelComplete = onLevelComplete
        loadLevelData(levelData: levelData)
        setupAudioSession()
        spawnLevelUI()
        let dt = 1.0 / FPS
        let db = dt * (self.bpm / 60.0)
        _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.startPhysicsProcess(dt: dt, db: db)
        }
    }

    @MainActor deinit {
        stopGame()
    }

    func startPhysicsProcess(dt: Double, db: Double){
        startOrRestartSong()
        frameTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { _ in
            if(!self.isPaused) {
                self.physicsProcessSelfThenChildren(dt: dt, db: db)
            }
        }
    }

    func stopGame() {
        frameTimer?.invalidate()
        frameTimer = nil
        songPlayer?.stop()
        isPaused = true
    }

    func spawnLevelUI()
    {
        addChild(missFlash)
        addChild(gunMarker)
        addChild(gunButton)
        addChild(pauseButton)
        addChild(restartButton)
        addChild(scoreCounter)
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
        current_score = 0.0
        missed_score = 0.0
        scoreCounter.text = "0"

        print("Playing song")
        if let songPlayer = songPlayer {
            if songPlayer.isPlaying {
                songPlayer.pause()
            }
            songPlayer.currentTime = 0.0
            songPlayer.play()
        } else {
            print("Audio player not ready yet.")
        }
    }


    func loadLevelData(levelData : LevelData)
    {
        if let url = Bundle.main.url(forResource: levelData.musicAssetName, withExtension: "wav") {
            do {
                print("Audio file loaded successfully", levelData.musicAssetName)
                songPlayer = try AVAudioPlayer(contentsOf: url)
                songPlayer?.prepareToPlay()
            } catch {
                print("AVAudioPlayer init failed:", error)
            }
        } else {
            print("Could not find audio file:", levelData.musicAssetName)
        }
        
        self.bpm = levelData.songBPM
        self.missedScoreThresholdForFailure = Float(levelData.missedScoreThresholdForFailure)
        self.pointsFor1Star = levelData.scoreFor1StarRating
        self.pointsFor2Star = levelData.scoreFor2StarRating
        self.pointsFor3Star = levelData.scoreFor3StarRating
        self.level_id = levelData.id

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


    override func draw(in size: CGSize) -> AnyView{
        return AnyView(
            self.backgroundColor
        )
    }

    override func physicsProcess(dt: Double, db: Double) {
        frame += 1
        beat += db
        spawnBubbles()
        checkForMissedBubbles()
        progressLevelLossAnimationIfLost(dt:dt)
        progressLevelWinAnimationIfWon(dt: dt)
        if shouldStartVictory() {
            startLevelWinAnimation()
        }
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

    func checkForMissedBubbles() {
        var bubblesToRemove: [BubbleNode] = []
        for child in children {
            if let bubble = child as? BubbleNode {
                if bubble.isPopped {
                    if bubble.opacity <= 0 {
                        bubblesToRemove.append(bubble)
                    }
                    continue
                }
                if bubble.position.y >= bubbleMissHeight {
                    bubblesToRemove.append(bubble)
                    missBubble(bubble: bubble)
                }
            }
        }
        for bubble in bubblesToRemove {
            removeChild(bubble)
        }
    }

    // if multiple bubbles hit: accept only the ones that were hit perfectly
        // if none were hit perfectly: accept the one with the highest score
    // 
    func fireGun() {
        gunMarker.pulse()
        var bubblesInHitRange : [BubbleNode] = []
        
        for child in children{
            if let bubble = child as? BubbleNode {
                if bubble.isPopped {
                    continue
                }
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

    func missBubble(bubble : BubbleNode){
        changeScore(changeAmount: Float(-MAX_SCORE_PER_BUBBLE))
    }

    func togglePause() {
        if(!isPaused){
            pauseButton.text = "Resume"
            pauseButton.systemImageName = "play.fill"
            isPaused = true // set after pauseButton text change to trigger a view update
            songPlayer?.pause()
        }else{
            pauseButton.text = "Pause"
            pauseButton.systemImageName = "pause.fill"
            isPaused = false;
            songPlayer?.play()
        }
    }

    func changeScore(changeAmount : Float) {
        if (changeAmount >= 0) {
            current_score += changeAmount
            missed_score -= changeAmount * MISSED_SCORE_HEAL_AMOUNT
            gunButton.pulseColor(pulseTime: 0.25, color: Color.green, fadeIn: false)
            scoreCounter.pulseColor(pulseTime: 0.25, color: Color.green, fadeIn: false)
        }
        else
        {
            current_score = max(0.0, current_score + changeAmount)
            missed_score -= changeAmount
            gunButton.pulseColor(pulseTime: 0.25, color: Color.red, fadeIn: false)
            scoreCounter.pulseColor(pulseTime: 0.25, color: Color.red, fadeIn: false)
            missFlash.triggerFlash()
            if (missed_score > missedScoreThresholdForFailure)
            {
                startLevelLossAnimation()
            }
        }
        scoreCounter.text = String(Int(current_score))
    }

    func startLevelLossAnimation() {
        if level_loss_animation_playing {
            return
        }
        level_loss_animation_playing = true
        level_loss_time_left = LEVEL_LOSS_TIME
        for child in children {
            if let bubble = child as? BubbleNode {
                bubble.slowing_down = true
            }
            if let vfxNode = child as? VfxCapableNode {
                vfxNode.pulseColor(pulseTime: 0.5, color: Color.red, fadeIn: true)
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

    func shouldStartVictory() -> Bool {
        if level_win_animation_playing || level_loss_animation_playing {
            return false
        }
        return areVictoryCriteriaFulfilled()
    }

    func startLevelWinAnimation(){
        if level_win_animation_playing {
            return
        }
        songPlayer?.stop()
        level_win_animation_playing = true
        level_win_time_left = LEVEL_WIN_TIME
    }

    func progressLevelWinAnimationIfWon(dt: Double){
        if !level_win_animation_playing {
            return
        }
        level_win_time_left -= dt
        if level_win_time_left <= 0{
            returnVictorious()
        }
    }

    func returnVictorious(){
        level_win_animation_playing = false
        var finalScore : Int = Int(current_score)
        var starsAcquired : Int = 0
        if (finalScore >= pointsFor1Star){starsAcquired += 1}
        if (finalScore >= pointsFor2Star){starsAcquired += 1}
        if (finalScore >= pointsFor3Star){starsAcquired += 1}

        let result : LevelResult = LevelResult(
            level_id: self.level_id,
            total_score: finalScore,
            total_stars : starsAcquired)
        do {
            try storeLevelResult(result)
        } catch {
            print("Failed to store level result:", error)
        }
        print("Victory!")
        stopGame()
        DispatchQueue.main.async {
            self.onLevelComplete?(result)
        }
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


    /**
        ISSUES TO ADDRESS:
            - score counter not showing up
    */

}
