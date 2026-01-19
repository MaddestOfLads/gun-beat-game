import SwiftUI

class GunMarkerNode : VfxCapableNode {

    var thicknessTween : Tween = Tween(
        animationMode : Tween.AnimationMode = AnimationMode.LINEAR,
        animationTime : Double = 0.25,
        startValue : Double = 0.03,
        endValue : Double = 0.01)
    
    init(position: CGPoint, scale: CGSize, color: Color) {
        self.zIndex = 1
        super.init(position: position, scale: scale, color: color)
    }

    override func physicsProcess(dt : Double, db : Double){
        thicknessTween.progress(dt)
    }

    override func Pulse(){
        thicknessTween.startTween()
    }

    override func draw(in size: CGSize) -> AnyView{
        retrun AnyView{
            Rectangle()
            .fill(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
            .frame(width: size.width * scale.width * vfx_scale_multiplier.width,
                height: size.height * CGFloat(thicknessTween.getValue()))
            .position(
                x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height
            )
        }
    }
}