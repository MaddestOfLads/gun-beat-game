import SwiftUI

// ButtonNode variant specifically for GunButton so that it can show the gun image
class GunButtonNode : ButtonNode {
    override init(position: CGPoint, scale: CGSize, color: Color, text: String, systemImageName: String? = nil, onPressed: (() -> Void)? = nil) {
        super.init(position: position, scale: scale, color: color, text: text, systemImageName: systemImageName, onPressed: onPressed)
    }
    override func draw(in size: CGSize) -> AnyView{
        let buttonSize = CGSize(
            width: size.width * scale.width * vfx_scale_multiplier.width,
            height: size.height * scale.height * vfx_scale_multiplier.height
        )
        let baseColor = color.mix(with: vfx_color, by: vfx_color_blend_amount)
        let shadowRadius = buttonSize.width * 0.12
        let strokeWidth = max(1.0, buttonSize.width * 0.02)
        let hasGunImage = UIImage(named: "gun") != nil
        return AnyView(
            Button(action: {
                self.onPressed?()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .fill(
                            hasGunImage
                                ? AnyShapeStyle(Color.clear)
                                : AnyShapeStyle(
                                    LinearGradient(
                                        colors: [
                                            baseColor.opacity(0.95),
                                            baseColor.opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: self.cornerRadius)
                                .stroke(Color.white.opacity(hasGunImage ? 0.0 : 0.2), lineWidth: strokeWidth)
                        )
                        .shadow(
                            color: baseColor.opacity(hasGunImage ? 0.35 : 0.55),
                            radius: shadowRadius,
                            x: 0,
                            y: shadowRadius * 0.15
                        )

                    if hasGunImage {
                        Image("gun")
                            .resizable()
                            .scaledToFit()
                            .padding(buttonSize.width * 0.12)
                            .shadow(color: Color.black.opacity(0.25), radius: buttonSize.width * 0.04, x: 0, y: buttonSize.width * 0.02)
                    } else {
                        Image(systemName: "scope")
                            .resizable()
                            .scaledToFit()
                            .padding(buttonSize.width * 0.2)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: buttonSize.width, height: buttonSize.height)
                .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            }
            .accessibilityLabel(Text(text))
            .position(
                x: (position.x + vfx_position_offset.x) * size.width,
                y: (position.y + vfx_position_offset.y) * size.height
            )
        )
    }
}
