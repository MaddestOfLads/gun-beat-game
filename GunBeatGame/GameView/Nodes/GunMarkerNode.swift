import SwiftUI

class GunMarkerNode : VfxCapableNode {

    private let visibilityDuration: Double = 0.25
    private var visibilityTimeLeft: Double = 0.0
    var thicknessTween: Tween = Tween(
        animationMode: .LINEAR,
        animationTime: 0.25,
        startValue: 0.03,
        endValue: 0.01
    )
    var widthTween: Tween = Tween(
        animationMode: .EASE_OUT,
        animationTime: 0.2,
        startValue: 1.3,
        endValue: 1.0
    )
    
    override init(position: CGPoint, scale: CGSize, color: Color) {
        super.init(position: position, scale: scale, color: color)
    }

    override func physicsProcess(dt : Double, db : Double){
        thicknessTween.update(dt: dt)
        widthTween.update(dt: dt)
        vfx_scale_multiplier.width = CGFloat(widthTween.getValue())
        if visibilityTimeLeft > 0 {
            visibilityTimeLeft = max(0.0, visibilityTimeLeft - dt)
        }
    }

    func pulse(){
        thicknessTween.startTween()
        widthTween.startTween()
        visibilityTimeLeft = visibilityDuration
        pulseColor(pulseTime: 0.25, color: Color.white, fadeIn: false)
    }

    override func draw(in size: CGSize) -> AnyView{
        guard visibilityTimeLeft > 0 else {
            return AnyView(EmptyView())
        }
        let baseColor = color.mix(with: vfx_color, by: vfx_color_blend_amount)
        let height = size.height * CGFloat(thicknessTween.getValue())
        let width = size.width * scale.width * vfx_scale_multiplier.width
        return AnyView(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            baseColor.opacity(0.2),
                            baseColor.opacity(0.9),
                            baseColor.opacity(0.2)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .shadow(color: baseColor.opacity(0.6), radius: height * 4, x: 0, y: 0)
                .position(
                    x: (position.x + vfx_position_offset.x) * size.width,
                    y: (position.y + vfx_position_offset.y) * size.height
                )
        )
    }
}
