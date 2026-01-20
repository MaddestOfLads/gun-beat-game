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
    var systemImageName: String?

    init(position: CGPoint, scale: CGSize, color: Color, text: String, systemImageName: String? = nil, onPressed: (() -> Void)? = nil) {
        self.text = text
        self.systemImageName = systemImageName
        self.onPressed = onPressed
        super.init(position: position, scale: scale, color: color)
    }

    override func draw(in size: CGSize) -> AnyView { //Overrides Node.draw()
        let buttonSize = CGSize(
            width: size.width * scale.width * vfx_scale_multiplier.width,
            height: size.height * scale.height * vfx_scale_multiplier.height
        )
        let baseColor = color.mix(with: vfx_color, by: vfx_color_blend_amount)
        let strokeWidth = max(1.0, buttonSize.width * 0.02)
        let shadowRadius = buttonSize.width * 0.12

        return AnyView(
            Button(action: {
                self.onPressed?()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
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
                            RoundedRectangle(cornerRadius: self.cornerRadius)
                                .stroke(Color.white.opacity(0.2), lineWidth: strokeWidth)
                        )
                        .shadow(color: baseColor.opacity(0.55), radius: shadowRadius, x: 0, y: shadowRadius * 0.15)

                    if let systemImageName {
                        Image(systemName: systemImageName)
                            .resizable()
                            .scaledToFit()
                            .padding(buttonSize.width * 0.18)
                            .foregroundColor(Color.white)
                    } else {
                        Text(text)
                            .foregroundColor(Color.white)
                            .font(.system(size: buttonSize.height * 0.35, weight: .semibold, design: .rounded))
                            .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(width: buttonSize.width, height: buttonSize.height)
            }
            .accessibilityLabel(Text(text))
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
