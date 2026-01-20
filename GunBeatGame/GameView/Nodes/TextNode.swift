// Node for displaying text.
// Can change color and size in real time.

import SwiftUI

class TextNode: VfxCapableNode{
    var text: String

    init(position: CGPoint, scale: CGSize, color: Color, text: String = "") {
        self.text = text
        super.init(position: position, scale: scale, color: color)
    }

    override func draw(in size: CGSize) -> AnyView { //Overrides Node.draw()
        let fontSize = max(12.0, size.height * scale.height * 0.7 * vfx_scale_multiplier.height)
        return AnyView(
            Text(text)
                .frame(width: size.width * scale.width * vfx_scale_multiplier.width,
                    height: size.height * scale.height * vfx_scale_multiplier.height)
                .foregroundColor(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                .position(x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height)
        )
    }
    override func physicsProcess(dt: Double, db: Double) {
        updateVfx(dt:dt)
    }
}
