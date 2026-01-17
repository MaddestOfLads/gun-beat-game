import SwiftUI

class BubbleNode : VfxCapableNode{
    
    let SPAWN_POS : CGPoint = CGPoint(x: 0.35, y: -0.5)
    
    //variables for controlling the pop animation:
    let POP_ANIMATION_TIME : Double = 0.4
    var beats_since_popped : Double = 0.0
    var isPopped : Bool = false
    var opacity : Double = 1.0
    var popped_x_speed : Double = -0.4

    var speed : Double //Measured in screens per beat

    var hitMargin : CGFloat //Margin used to accept imperfect hits with a lesser score

    init(pb: PackedBubble) // Constructor
    //Creates the bubble node from the packedBubble (which only stores bubble data)
    {
        super.init(position: SPAWN_POS, color: pb.color, size : CGSize(width: pb.width, height: pb.height))
        self.position = SPAWN_POS
        self.speed = pb.speed
        self.hitMargin = pb.hitMargin
    }

    override func physicsProcess(dt : Double, db : Double)
    //Called by parent node every frame
    //Makes the bubble move
    {
        if(!isPopped) {
            position.y += db * speed
        }
        else
        {
            beats_since_popped += db
            opacity -= db / POP_ANIMATION_TIME
            position.x += db * popped_x_speed
        }
    }

    override func draw(in canvasSize: CGSize) -> AnyView
    //Renders the bubble; called by parent node
    {
        return AnyView(Rectangle()
            .fill(color.mix(with: vfx_color, by: vfx_color_blend_amount))
            .frame(width: size.width * vfx_dimensions_multiplier.width * canvasSize.width, height: size.height * vfx_dimensions_multiplier.height * canvasSize.height)
            .position(x: (position.x + vfx_position_offset.x) * canvasSize.width, y: (position.y + vfx_position_offset.y) * canvasSize.height)
            .opacity(opacity)
        )
    }

    func hitAccuracy(popHeight : CGFloat) -> Double
    //Used to check if the bubble was hit by a shot
    //If bubble is in front of barrel, returns 1
    //If bubble is near barrel but still within hit margin, returns hit accuracy in range 1-0
    //If bubble is nowhere near barrel, returns 0
    {
        if(
            popHeight < position.y + (size.height/2)
            && popHeight > position.y - (size.height/2)
        ) {return 1.0}
        else if(
            popHeight < position.y + (size.height/2) + hitMargin
            && popHeight > position.y - (size.height/2) - hitMargin
        )
        {
            return (hitMargin - abs(popHeight + (size.height/2) - position.y))/hitMargin
        }
        else {return 0.0}
    }

    func getHit()
    {
        isPopped = true
        color = Color.red
    }
}
