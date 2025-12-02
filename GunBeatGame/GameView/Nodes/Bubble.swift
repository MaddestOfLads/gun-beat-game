import SwiftUI

class Bubble : Node{
    
    let SPAWN_POS : CGPoint = CGPoint(x: 0.35, y: -0.5)
    var size : CGSize
    var position : CGPoint
    var color : Color

    var speed : Double //Measured in screens per beat

    var hitMargin : CGFloat //Margin used to accept imperfect hits with a lesser score

    init(pb: PackedBubble) // Constructor
    //Creates the bubble node from the packedBubble (which only stores bubble data)
    {
        self.position = SPAWN_POS
        self.speed = pb.speed
        self.size = CGSize(width: pb.width, height: pb.height)
        self.hitMargin = pb.hitMargin
        self.color = pb.color
    }

    override func physicsProcess(dt : Double, db : Double)
    //Called by parent node every frame
    //Makes the bubble move
    {
        position.y -= db * speed
    }

    override func draw(in canvasSize: CGSize) -> AnyView
    //Renders the bubble; called by parent node
    {
        return AnyView(Rectangle()
            .fill(color)
            .frame(width: size.width * canvasSize.width, height: size.height * canvasSize.height)
            .position(x: position.x * canvasSize.width, y: position.y * canvasSize.height))
    }

    func hitAccuracy(popHeight : CGFloat) -> Double
    //Used to check if the bubble was hit by a shot
    //If bubble is in front of barrel, returns 1
    //If bubble is near barrel but still within hit margin, returns hit accuracy in range 1-0
    //If bubble is nowhere near barrel, returns 0
    {
        if(
            popHeight < position.y + (size.height/2)
            && popHeight > position.y - (size.height/2)
        ) {return 1.0}
        else if(
            popHeight < position.y + (size.height/2) + hitMargin
            && popHeight > position.y - (size.height/2) - hitMargin
        )
        {
            return (hitMargin - abs(popHeight + (size.height/2) - position.y))/hitMargin
        }
        else {return 0.0}
    }

    func getHit()
    {
        color = Color.red
        //TODO: smash the bubble to pieces or sth
    }
}
