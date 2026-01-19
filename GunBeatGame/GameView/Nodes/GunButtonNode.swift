import SwiftUI

// ButtonNode variant specifically for GunButton so that it can have text above it
// No, there was no simpler way, because why would Steve let us just position text normally
class GunButtonNode : ButtonNode {
    var scoreText : String = "0"
    init(position: CGPoint, scale: CGSize, color: Color, text: String, onPressed: (() -> Void)? = nil) {
        super.init(position: position, scale: scale, color: color, text: text, onPressed: onPressed)
    }
    override func draw(in size: CGSize) -> AnyView{
        VStack{
            Text(scoreText)
            Button(action: {
                self.onPressed?()
            }) {
                Text(text)
                    .frame(width: size.width * scale.width * vfx_scale_multiplier.width,
                        height: size.height * scale.height * vfx_scale_multiplier.height)
                    .background(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
                    .foregroundColor(Color.black)
                    .cornerRadius(self.cornerRadius)
            }
            .position(
                x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height
            )
        }
    }
}