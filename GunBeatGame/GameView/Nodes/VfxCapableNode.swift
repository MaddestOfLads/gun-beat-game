// Nodes that can be influenced by VFX.
// They have a position, size, and color, as well as variables which 

class VfxCapableNode : Node {
    var color: Color
    var vfx_color: Color = Color.black
    var vfx_color_blend_amount : Float // 0 to 1
    var delta_color_blend: Float = -1.0 // How fast per second the currently applied effect(s) will decay

    var dimensions: CGSize //relative to screen size
    var vfx_dimensions_multiplier : CGSize = CGSize(width: 1.0, height: 1.0)
    
    var position: CGPoint //relative to screen size
    var vfx_position_offset : position : CGPoint = CGPoint(width: 1.0, height: 1.0)


    init(position: CGPoint, dimensions: CGSize, color: Color) {
        self.position = position
        self.dimensions = dimensions
        self.color = color
    }

    func updateVfx(dt : float) { // Should be ran once in physicsProcess; updates all VFX
        vfx_color_blend_amount = 
            min(1.0, 
            max(0.0, 
            vfx_color_blend_amount + (delta_color_blend * dt)))
    }

    func pulseColor((pulse_time: Float, color: Color)){
        vfx_color = color
        vfx_color_blend_amount = 1.0
        delta_color_blend = -1.0/pulse_time
    }
}