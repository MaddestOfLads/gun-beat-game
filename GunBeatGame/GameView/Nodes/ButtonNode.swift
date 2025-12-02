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

class ButtonNode: Node {
    var text: String
    var color: Color
    var onPressed: (() -> Void)?
    var dimensions: CGSize //relative to screen size
    var position: CGPoint //relative to screen size
    let cornerRadius: CGFloat = 8.0;

    init(position: CGPoint, dimensions: CGSize, color: Color, text: String, onPressed: (() -> Void)? = nil) {
        self.position = position
        self.dimensions = dimensions
        self.color = color
        self.text = text
        self.onPressed = onPressed
    }

    override func draw(in size: CGSize) -> AnyView { //Override from Node
        AnyView(
            Button(action: {
                onPressed?()
            }) {
                Text(text)
                    .frame(width: size.width * dimensions.width,
                        height: size.height * dimensions.height)
                    .background(self.color)
                    .foregroundColor(Color.black)
                    .cornerRadius(self.cornerRadius)
            }
            .position(
                x: position.x * size.width,
                y: position.y * size.height
            )
        )
    }
}