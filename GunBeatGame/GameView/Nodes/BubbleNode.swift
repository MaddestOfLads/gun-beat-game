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
    let hitMarginMultiplier: CGFloat = 1.6

    init(pb: PackedBubble) // Constructor
    //Creates the bubble node from the packedBubble (which only stores bubble data)
    {
        self.speed = pb.speed
        self.hitMargin = pb.hitMargin * hitMarginMultiplier
        super.init(position: SPAWN_POS, scale : CGSize(width: pb.width, height: pb.height), color: pb.color)
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
        let width = scale.width * vfx_scale_multiplier.width * size.width
        let height = scale.height * vfx_scale_multiplier.height * size.height
        let baseColor = color.mix(with: vfx_color, by: vfx_color_blend_amount)
        let cornerRadius = max(6.0, min(width, height) * 0.22)
        let strokeWidth = max(1.0, width * 0.01)

        return AnyView(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            baseColor.opacity(0.95),
                            baseColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.25), lineWidth: strokeWidth)
                )
                .shadow(color: baseColor.opacity(0.55), radius: width * 0.12, x: 0, y: 0)
                .frame(width: width, height: height)
                .position(
                    x: (position.x + vfx_position_offset.x) * size.width,
                    y: (position.y + vfx_position_offset.y) * size.height
                )
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
            let rawAccuracy = (hitMargin - abs(popHeight + (scale.height/CGFloat(2.0)) - position.y))/hitMargin
            return max(0.0, min(1.0, rawAccuracy))
        }
        else {return 0.0}
    }

    func getHit()
    {
        isPopped = true
        pulseColor(pulseTime: 0.5, color: Color.white, fadeIn: false)
    }
}
