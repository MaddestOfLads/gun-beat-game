import SwiftUI

class BubbleNode : VfxCapableNode{
    
    let SPAWN_POS : CGPoint = CGPoint(x: 0.35, y: -0.5)
    
    //variables for controlling the pop animation:
    let POP_ANIMATION_TIME : Double = 0.4
    var beats_since_popped : Double = 0.0
    var isPopped : Bool = false
    var opacity : Double = 1.0
    var popped_x_speed : Double = -0.4

    var slowing_down : Bool = false
    let SLOW_DOWN_TIME : Double = 0.5

    var speed : Double //Measured in screens per beat

    var hitMargin : CGFloat //Margin used to accept imperfect hits with a lesser score

    init(pb: PackedBubble) // Constructor
    //Creates the bubble node from the packedBubble (which only stores bubble data)
    {
        super.init(position: SPAWN_POS, color: pb.color, scale : CGSize(width: pb.width, height: pb.height))
        self.position = SPAWN_POS
        self.speed = pb.speed
        self.hitMargin = pb.hitMargin
    }

    override func physicsProcess(dt : Double, db : Double)
    //Called by parent node every frame
    //Makes the bubble move
    {
        if(slowing_down) {speed -= speed * dt * SLOW_DOWN_TIME}
        if(!isPopped) {
            position.y += db * speed
        }
        else
        {
            beats_since_popped += db
            opacity -= db / POP_ANIMATION_TIME
            position.x += db * popped_x_speed
        }
        updateVfx(dt:dt)
    }

    override func draw(in size: CGSize) -> AnyView
    //Renders the bubble; called by parent node
    {
        return AnyView(Rectangle()
            .fill(color.mix(with: vfx_color, by: vfx_color_blend_amount))
            .frame(width: scale.width * vfx_scale_multiplier.width * size.width, height: scale.height * vfx_dimensions_multiplier.height * canvasSize.height)
            .position(x: (position.x + vfx_position_offset.x) * size.width, y: (position.y + vfx_position_offset.y) * canvasSize.height)
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
            popHeight < position.y + (scale.height/2)
            && popHeight > position.y - (scale.height/2)
        ) {return 1.0}
        else if(
            popHeight < position.y + (scale.height/2) + hitMargin
            && popHeight > position.y - (scale.height/2) - hitMargin
        )
        {
            return (hitMargin - abs(popHeight + (size.height/2) - position.y))/hitMargin
        }
        else {return 0.0}
    }

    func getHit()
    {
        isPopped = true
        pulseColor(time: 0.5, color: Color.white)
    }
}
