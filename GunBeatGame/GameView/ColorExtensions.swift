import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    struct RGBAComponents {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }

    var rgbaComponents: RGBAComponents {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return RGBAComponents(
                red: Double(red),
                green: Double(green),
                blue: Double(blue),
                alpha: Double(alpha)
            )
        }
        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        let converted = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        return RGBAComponents(
            red: Double(converted.redComponent),
            green: Double(converted.greenComponent),
            blue: Double(converted.blueComponent),
            alpha: Double(converted.alphaComponent)
        )
        #endif
        return RGBAComponents(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func mix(with color: Color, by amount: Double) -> Color {
        let clamped = min(max(amount, 0.0), 1.0)
        let base = rgbaComponents
        let target = color.rgbaComponents
        return Color(
            red: base.red + (target.red - base.red) * clamped,
            green: base.green + (target.green - base.green) * clamped,
            blue: base.blue + (target.blue - base.blue) * clamped,
            opacity: base.alpha + (target.alpha - base.alpha) * clamped
        )
    }
}
