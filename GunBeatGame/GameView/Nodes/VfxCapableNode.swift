// Nodes that can be influenced by VFX.
// They have a position, size, and color, as well as variables which 

class VfxCapableNode : Node {
    var color: Color
    var vfx_color: Color = Color.black
    var vfx_color_blend_amount : Float // 0 to 1

    var dimensions: CGSize //relative to screen size
    var vfx_dimensions_multiplier : CGSize = CGSize(width: 1.0, height: 1.0)
    
    var position: CGPoint //relative to screen size
    var vfx_position_offset : position : CGPoint = CGPoint(width: 1.0, height: 1.0)

    init(position: CGPoint, dimensions: CGSize, color: Color) {
        self.position = position
        self.dimensions = dimensions
        self.color = color
    }
}