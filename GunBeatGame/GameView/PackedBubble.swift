// Lightweight class for bubbles that haven't been spawned yet
// Used to avoid having to process unspawned bubbles.
import SwiftUI

class PackedBubble {
    //Distance is measured in screens and relative to screen dimension
    //Distances should be stored as CGFloats
    //Time is measured in beats of current song
    var speed : Double
    var width : CGFloat
    var height : CGFloat
    var hitMargin : CGFloat
    var spawnBeat : Double
    var color : Color
    init(
        targetBeat : Double,
        gunBarrelPositionY : CGFloat = 0.8,
        spawnPosY : CGFloat = -0.5,
        speed: Double = 0.5,
        width : CGFloat = 0.1,
        height : CGFloat = 0.05,
        hitMargin : CGFloat = 0.03,
        color: Color = Color.blue)
        //TODO: replace gunBarrelPositionY with a reference (this constant 0.8 is messy)
    {
        self.spawnBeat = targetBeat - Double(gunBarrelPositionY - spawnPosY) / speed
        self.spawnBeat = max(0.0, self.spawnBeat)
        self.speed = speed
        self.width = width
        self.height = height
        self.hitMargin = hitMargin
        self.color = color
    }
}
