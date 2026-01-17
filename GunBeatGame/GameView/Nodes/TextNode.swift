// Node for displaying text.
// Can change color and size in real time.

import SwiftUI

class TextNode: VfxCapableNode{
    var text: String

    init(position: CGPoint, dimensions: CGSize, color: Color, text: String = "") {
        super.init(position: position, dimensions: dimensions, color: color)
        self.text = text
    }

    override func draw(in size: CGSize) -> AnyView { //Overrides Node.draw()
        AnyView(
            Text(text)
                .frame(width: size.width * dimensions.width * vfx_dimensions_multiplier.width,
                    height: size.height * dimensions.height * vfx_dimensions_multiplier.height)
                .foregroundColor(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
                .position(x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height)
        )
    }
}
