import Foundation
import SwiftUI
// Class for interpolating (animating) a Double over time, meant to simplify animating a property over time.
// I made it because   Swift is     Pissing me off and I need it to work like it does in Godot.
class Tween{
    enum AnimationMode {
        case LINEAR // From A to B in a straight line
        case EASE_IN // Smooth beginning (sinusoid)
        case EASE_OUT // Smooth ending (sinusoid)
        case EASE_IN_OUT // Smooth beginning and ending
        case SHAKE_ASYMMETRIC // Shaking between start and end that collapses at end.
        case SHAKE_SYMMETRIC // Shaking between (start-end) and end that collapses at end. WARNING: MAY RETURN VALUES OUTSIDE RANGE!
    }
    var animationMode : Tween.AnimationMode
    var animationTime : Double
    var timePassed : Double = 0.0
    var startValue : Double
    var endValue : Double
    var shakeCycleCount : Double = 5.0 // Only for InterpolationMode.SHAKE. Higher value = faster shaking.
    var currentValue : Double
    
    init(
        animationMode : Tween.AnimationMode = AnimationMode.LINEAR,
        animationTime : Double = 1.0,
        startValue : Double = 0.0,
        endValue : Double = 1.0,
        shakeCycleCount : Double = 5.0
    ){
        self.animationMode = animationMode
        self.animationTime = animationTime
        self.startValue = startValue
        self.endValue = endValue
        self.shakeCycleCount = shakeCycleCount

        // tween should not trigger instantly, so end values are assigned
        self.timePassed = animationTime
        self.currentValue = self.endValue
        if (animationTime == 0.0){
            print("Tween animation time cannot be 0, setting to 0.5!")
            self.animationTime = 0.5
        }
    }

    func update(dt : Double){
        timePassed += dt
        var progress = min(max(timePassed / animationTime, 0.0), 1.0)
        var valueRange = endValue-startValue
        if (progress >= 1.0) {
            currentValue = endValue
            return
        }
        if (progress <= 0.0) {
            currentValue = startValue
            return
        }
        switch animationMode{
            case AnimationMode.LINEAR:
                currentValue = startValue + valueRange * progress
            case AnimationMode.EASE_IN:
                currentValue = endValue - valueRange * sin((1.0-progress) * Double.pi/2)
            case AnimationMode.EASE_OUT:
                currentValue = startValue + valueRange * sin(progress * Double.pi/2)
            case AnimationMode.EASE_IN_OUT:
                currentValue = startValue + (0.5 * valueRange) * (1.0 - cos(progress * Double.pi))
            case AnimationMode.SHAKE_ASYMMETRIC:
                var sawtooth = (progress * shakeCycleCount).truncatingRemainder(dividingBy: 1.0) // 0 to 1, rising linearly and falling sharply
                var triangle = 1.0 - abs(2.0 * sawtooth - 1.0)
                currentValue = endValue - valueRange * triangle * (1.0-progress) // same as symmetric but decaying with progress
            case AnimationMode.SHAKE_SYMMETRIC:
                var sawtooth = (progress * shakeCycleCount).truncatingRemainder(dividingBy: 1.0)
                var triangle = 1.0 - abs(2.0 * sawtooth - 1.0)
                currentValue = endValue - valueRange * triangle * (1.0-progress) * 2.0 // only difference: this is times 2
            default:
                break
        }
    }

    func getValue() -> Double {
        return currentValue
    }

    // Actually trigger tween effect 
    func startTween() {
        self.timePassed = 0.0
        self.currentValue = self.startValue
    }
}

// Tween wrappers for CGPoint, CGSize and Color
// (AI generated because it's just the same math for every Double with a lot of typing)
class PointTween {
    private let xTween: Tween
    private let yTween: Tween
    
    init(
        animationMode: Tween.AnimationMode = .LINEAR,
        animationTime: Double = 1.0,
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
        endPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
        shakeCycleCount: Double = 5.0
    ) {
        self.xTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: Double(startPoint.x),
            endValue: Double(endPoint.x),
            shakeCycleCount: shakeCycleCount
        )
        
        self.yTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: Double(startPoint.y),
            endValue: Double(endPoint.y),
            shakeCycleCount: shakeCycleCount
        )
    }
    
    func update(dt: Double) {
        xTween.update(dt: dt)
        yTween.update(dt: dt)
    }
    
    func getValue() -> CGPoint {
        return CGPoint(
            x: CGFloat(xTween.getValue()),
            y: CGFloat(yTween.getValue())
        )
    }
    
    func startTween() {
        xTween.startTween()
        yTween.startTween()
    }
}

class SizeTween {
    private let widthTween: Tween
    private let heightTween: Tween
    
    init(
        animationMode: Tween.AnimationMode = .LINEAR,
        animationTime: Double = 1.0,
        startSize: CGSize = CGSize(width: 0.0, height: 0.0),
        endSize: CGSize = CGSize(width: 0.0, height: 0.0),
        shakeCycleCount: Double = 5.0
    ) {
        self.widthTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: Double(startSize.width),
            endValue: Double(endSize.width),
            shakeCycleCount: shakeCycleCount
        )
        
        self.heightTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: Double(startSize.height),
            endValue: Double(endSize.height),
            shakeCycleCount: shakeCycleCount
        )
    }
    
    func update(dt: Double) {
        widthTween.update(dt: dt)
        heightTween.update(dt: dt)
    }
    
    func getValue() -> CGSize {
        return CGSize(
            width: CGFloat(widthTween.getValue()),
            height: CGFloat(heightTween.getValue())
        )
    }
    
    func startTween() {
        widthTween.startTween()
        heightTween.startTween()
    }
}

class ColorTween {
    private let redTween: Tween
    private let greenTween: Tween
    private let blueTween: Tween
    private let alphaTween: Tween
    
    init(
        animationMode: Tween.AnimationMode = .LINEAR,
        animationTime: Double = 1.0,
        startColor: Color,
        endColor: Color,
        shakeCycleCount: Double = 5.0
    ) {
        // Convert SwiftUI Colors to RGB components (0-1 range)
        let startRGB = startColor.rgbaComponents
        let endRGB = endColor.rgbaComponents
        
        self.redTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: startRGB.red,
            endValue: endRGB.red,
            shakeCycleCount: shakeCycleCount
        )
        
        self.greenTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: startRGB.green,
            endValue: endRGB.green,
            shakeCycleCount: shakeCycleCount
        )
        
        self.blueTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: startRGB.blue,
            endValue: endRGB.blue,
            shakeCycleCount: shakeCycleCount
        )
        
        self.alphaTween = Tween(
            animationMode: animationMode,
            animationTime: animationTime,
            startValue: startRGB.alpha,
            endValue: endRGB.alpha,
            shakeCycleCount: shakeCycleCount
        )
    }
    
    func update(dt: Double) {
        redTween.update(dt: dt)
        greenTween.update(dt: dt)
        blueTween.update(dt: dt)
        alphaTween.update(dt: dt)
    }
    
    func getValue() -> Color {
        return Color(
            red: redTween.getValue(),
            green: greenTween.getValue(),
            blue: blueTween.getValue(),
            opacity: alphaTween.getValue()
        )
    }
    
    func startTween() {
        redTween.startTween()
        greenTween.startTween()
        blueTween.startTween()
        alphaTween.startTween()
    }
}
