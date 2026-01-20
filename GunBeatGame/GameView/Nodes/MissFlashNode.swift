import SwiftUI

class MissFlashNode: Node {
    private var intensity: Double = 0.0
    private let decayRate: Double = 3.0

    func triggerFlash() {
        intensity = 1.0
    }

    override func physicsProcess(dt: Double, db: Double) {
        intensity = max(0.0, intensity - decayRate * dt)
    }

    override func draw(in size: CGSize) -> AnyView {
        let opacity = min(0.6, 0.6 * intensity)
        return AnyView(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.red.opacity(opacity)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
