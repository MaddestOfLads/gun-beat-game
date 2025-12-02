// Lightweight class for bubbles that haven't been spawned yet
// Used to avoid having to process unspawned bubbles.
class PackedBubble {
    //Distance is measured in screens and relative to screen dimension
    //Distances should be stored as CGFloats
    //Time is measured in beats of current song
    let DEFAULT_SPEED : CGFloat = 0.5;
    let DEFAULT_WIDTH : CGFloat = 0.1;
    let DEFAULT_HEIGHT : CGFloat = 0.05;
    let DEFAULT_HIT_MARGIN : CGFloat = 0.1;
    let DEFAULT_COLOR : Color = Color.blue;
    var spawnBeat : Double
    var tagretBeat : Double
    init(
        targetBeat : Double,
        gunBarrelPositionY : CGFloat = 0.8,
        speed: Double = DEFAULT_SPEED,
        width : CGFloat = DEFAULT_WIDTH,
        height : CGFloat = DEFAULT_HEIGHT,
        hitMargin : CGFloat = DEFAULT_HIT_MARGIN,
        color: Color = DEFAULT_COLOR)
        //TODO: replace gunBarrelPositionY with a reference (this constant 0.8 is messy)
    {
        self.targetBeat = targetBeat;
        self.spawnBeat = targetBeat - (gunBarrelPositionY - Bubble.spawnPos.y) * speed
        self.speed = speed
        self.width = width
        self.height = height
        self.hitMargin = hitMargin
        self.color = color
    }
    func spawnBubble()
    {
        return Bubble(speedInScreensPerBeat)
    }
}