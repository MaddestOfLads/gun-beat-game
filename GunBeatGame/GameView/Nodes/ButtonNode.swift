//Node for in-game buttons.
//Use this to create things like pause button, gun button, etc.
//Don't make a new class extending this, just make a new object.
//The constructor lets you make it call a function, like this:
/*
    var someButton : GunButton(argumentsOrSth) {
        some functions that the button will call
    }
    AddChild(someButton) - DONT FORGET THIS
*/
//If you want the button to make the parent call a function, use the Node.parent property.

import SwiftUI

class ButtonNode: VfxCapableNode{

    var onPressed: (() -> Void)?
    let cornerRadius: CGFloat = 8.0;
    var text : String

    init(position: CGPoint, scale: CGSize, color: Color, text: String, onPressed: (() -> Void)? = nil) {
        self.text = text
        self.onPressed = onPressed
        super.init(position: position, scale: scale, color: color)
    }

    override func draw(in size: CGSize) -> AnyView { //Overrides Node.draw()
        AnyView(
            Button(action: {
                self.onPressed?()
            }) {
                Text(text)
                    .frame(width: size.width * scale.width * vfx_scale_multiplier.width,
                        height: size.height * scale.height * vfx_scale_multiplier.height)
                    .background(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
                    .foregroundColor(self.color.mix(with: vfx_color, by: vfx_color_blend_amount))
                    .cornerRadius(self.cornerRadius)
            }
            .position(
                x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height
            )
        )
    }
    override func physicsProcess(dt: Double, db: Double) {
        updateVfx(dt:dt)
    }
}
