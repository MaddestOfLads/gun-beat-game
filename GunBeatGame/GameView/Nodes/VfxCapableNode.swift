// Nodes that can be influenced by VFX.
// They have a position, size, and color, as well as variables which 
import SwiftUI //so that Color can work

class VfxCapableNode : Node {
    var color: Color
    var vfx_color: Color = Color.black
    var vfx_color_blend_amount : Double = 0.0 // 0 to 1
    var delta_color_blend: Double = -1.0 // How fast per second the currently applied effect(s) will decay

    var scale: CGSize //relative to screen size
    var vfx_scale_multiplier : CGSize = CGSize(width: 1.0, height: 1.0)
    
    var position: CGPoint //relative to screen size
    var vfx_position_offset : CGPoint = CGPoint(x: 1.0, y: 1.0)


    init(position: CGPoint, scale: CGSize, color: Color) {
        self.position = position
        self.scale = scale
        self.color = color
    }

    func updateVfx(dt : Double) { // Should be ran once in physicsProcess; updates all VFX
        vfx_color_blend_amount = 
            min(1.0, 
            max(0.0, 
            vfx_color_blend_amount + (delta_color_blend * dt)))
    }

    func pulseColor(pulseTime: Double, color: Color, fadeIn : Bool){
        vfx_color = color
        if(fadeIn){
            vfx_color_blend_amount = 0.0
            delta_color_blend = 1.0/pulseTime
        }else{
            vfx_color_blend_amount = 1.0
            delta_color_blend = -1.0/pulseTime
        }
    }
}

