import Foundation
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
        self.timePassed = 0.0
        self.startValue = startValue
        self.endValue = endValue
        self.shakeCycleCount = shakeCycleCount
        self.currentValue = self.startValue
    }

    func update(dt : Double){
        timePassed += dt
        var progress = timePassed / animationTime
        var valueRange = endValue-startValue
        if (progress >= 1.0) {return}
        switch animationMode{
            case AnimationMode.LINEAR:
                currentValue = startValue + valueRange * progress
            case AnimationMode.EASE_IN:
                currentValue = endValue - valueRange * sin((1.0-progress) * Double.pi/2)
            case AnimationMode.EASE_OUT:
                currentValue = startValue + valueRange * sin(progress * Double.pi/2)
            case AnimationMode.EASE_IN_OUT:
                currentValue = endValue - valueRange * sin((0.5-progress) * Double.pi)
            case AnimationMode.SHAKE_ASYMMETRIC:
                var sawtooth = (progress * shakeCycleCount).truncatingRemainder(1.0) * shakeCycleCount // 0 to 1, rising linearly and falling sharply
                var triangle = valueRange * 2.0 * (sawtooth - 2.0 * max(0.5-triangle, 0)) // scaled to value range, rising and falling linearly 
                currentValue = endValue - triangle * (1.0-progress) // same as symmetric but decaying with progress
            case AnimationMode.SHAKE_SYMMETRIC:
                var sawtooth = (progress * shakeCycleCount).truncatingRemainder(1.0) * shakeCycleCount
                var triangle = valueRange * 2.0 * (sawtooth - 2.0 * max(0.5-triangle, 0.0))
                currentValue = endValue - triangle * (1.0-progress) * 2.0 // only difference: this is times 2
            default:
        }
    }
    func getValue() -> Double {
        return currentValue
    }
}