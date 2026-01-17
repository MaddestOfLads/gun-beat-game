// Node for displaying text.
// Can change color and size in real time.

import SwiftUI

class TextNode: Node {
    var text: String
    var color: Color
    var dimensions: CGSize //relative to screen size
    var position: CGPoint //relative to screen size

    init(position: CGPoint, dimensions: CGSize, color: Color, text: String) {
        self.position = position
        self.dimensions = dimensions
        self.color = color
        self.text = text
    }

    override func draw(in size: CGSize) -> AnyView { //Overrides Node.draw()
        AnyView(
            Text(text)
                .frame(width: size.width * dimensions.width,
                    height: size.height * dimensions.height)
                .background(self.color)
                .foregroundColor(Color.black)
                .cornerRadius(self.cornerRadius)
                .position(width: position.x * size.width
                height: position.y * size.height)
        )
    }
}
