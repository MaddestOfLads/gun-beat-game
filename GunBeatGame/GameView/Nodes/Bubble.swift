
class Bubble : Node{
    
    let SPAWN_POS : CGPoint = CGPoint(x: 0.35, y: -0.5)
    var size : CGSize
    var position : CGPoint
    var color : Color

    var speed : Double //Measured in screens per beat

    var hitMargin : CGFloat //Margin used to accept imperfect hits with a lesser score

    init(pb: packedBubble) // Constructor
    //Creates the bubble node from the packedBubble (which only stores bubble data)
    {
        self.position = SPAWN_POS
        self.speed = pb.speed
        self.size = CGFloat(width: pb.width, height: pb.height)
        self.hitMargin = pb.hitMargin
        self.color = pb.color
    }

    func physicsProcess(dt : Double, db : Double) 
    //Called by parent node every frame
    //Makes the bubble move
    {
        position.y -= db * speed
    }

    func draw(in canvasSize: CGSize) -> AnyView?
    //Renders the bubble; called by parent node
    {
        return Rectangle()
            .fill(color)
            .frame(width: size.width * canvasSize.width, height: size.height * canvasSize.height)
            .position(x: position.x * canvasSize.width, y: position.y * canvasSize.height   )
    }

    func hitAccuracy(CGFloat popHeight) -> Double
    //Used to check if the bubble was hit by a shot
    //If bubble is in front of barrel, returns 1
    //If bubble is near barrel but still within hit margin, returns hit accuracy in range 1-0
    //If bubble is nowhere near barrel, returns 0
    {
        if(
            popHeight < position.height + (size.height/2)
            && popHeight > position.height - (size.height/2)
        ) {return 1.0}
        else if(
            popHeight < position.height + (size.height/2) + hitMargin
            && popheight > position.height - (size.height/2) - hitMargin
        )
        {
            return (hitMargin - abs(popHeight + (size.height/2) - position.height))/hitMargin
        }
        else return 0.0
    }

    func getHit()
    {
        color = Color.red
        //TODO: smash the bubble to pieces or sth
    }
}