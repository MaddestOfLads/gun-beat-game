//Node - base class from which all game objects (bubbles, buttons, etc) should inherit.

/*
HOW TO USE THIS CLASS: make another class that extends it, and then override enterTree(), physicsProcess() and draw() (explained below) to give it custom behaviour. 
If you want examples, open the Bubble class and look at enterTree, physicsProcess, and draw.
    PROPERTIES:
        
        parent:
            The parent node, which created this node and manages it.
        
        children:
            An array of child nodes, which are managed by this node.
            ORDER OF CHILDREN MATTERS BECAUSE OF TREE ORDER - see below

    FUNCTIONS:
        
        enterTree():
            Override it to make a node do something at the start of its lifetime (AKA when it is added to another node with AddChild()).
        
        physicsProcess(dt, db):
            Override it to make a node do something every frame.
            dt = time passed since last frame in seconds.
            db = time passed since last frame in beats.
        
        draw(in canvasSize: CGSize):
            Override it to make this node draw itself on the canvas. It should return a view.
            canvasSize = dimensions of the screen. Multiply by this value to convert from 0-1 coordinates to actual on-screen pixel coordinates.
        
        addChild(node):
            Don't override.
            Call this every time you create a node to make it a child node of this one.
                As a result, the child node will also start calling physicsProcess() and draw() automatically at appropriate times.
            Also triggers the child node's enterTree() instantly, because it just entered the tree.

        removeChild(node):
            Don't override.
            Removes a node from the list of children and marks it for deletion.
        
        physicsProcessSelfThenChildren() and drawSelfThenChildren():
            Wrappers for physicsProcess() and draw().
            Don't worry about them, don't override them, they just execute physicsProcess() and draw() in tree order.
    
    Explanation of tree order:
        Nodes are arranged in a tree (each node has children) which lets them do things recursively, in tree order.
        Tree order means: first trigger function on self, then recursively on children.
        This way, only the root node triggers each frame on a timer, and all of its children trigger the behaviour after it, avoiding having a bunch of unrelated timers for everything.
        Tree order applies to draw() (used for rendering) and physicsProcess() (used to do things each frame).

    Notes:
        You can do pretty much anything by overriding enterTree(), physicsProcess() and draw().
            enterTree() - does something at the start of the node's life
            physicsProcess() - does something every frame
            draw() - renders the node
        Don't try to implement tree order inside these functions.
            That's already handled by the wrappers.
            You just need to implement their behaviour, for example extending physicsProcess() to move a node every frame.
        Remember to add the node with AddChild() after you create it.
            If you don't, other nodes won't see it and won't call enterTree(), physicsProcess(), or draw()
        Avoid making nodes overly reliant on other nodes if it isn't necessary.
        Not every node needs to draw() something, some nodes may not have any appearance.
*/

import SwiftUI

class Node {

    weak var parent: Node?
        //If it was not marked weak, it could cause memory leaks - Swift could try storing parent.child.parent.child... endlessly and waste memory that way.
        //Or at least that's what chatgpt says.
    
    var children: [Node] = []
    
    final func addChild(_ node: Node) -> Void {
        node.parent = self
        children.append(node)
        node.enterTree()
    }

    final func removeChild(_ node: Node) -> Void {
        if let index = children.firstIndex(where: { $0 === node }) {
            children.remove(at: index)
            node.parent = nil
        }
    }

    func enterTree() -> Void {
        //Triggers when the node is added to another node with addChild().
        //Overridable.
    }
    func physicsProcess(dt: Double, db : Double) -> Void
    {
        //Overridable.
    }
    func draw(in canvasSize: CGSize) -> AnyView {
        return AnyView(EmptyView())
        //Overridable.
    }

    final func physicsProcessSelfThenChildren(dt: Double, db: Double) -> Void {
        //Calls physicsProcess on self and then recursively on children.
        //This is a separate function so that you can override physicsProcess() without messing this part up.
        physicsProcess(dt: dt, db: db)
        for child in children {
            child.physicsProcessSelfThenChildren(dt: dt, db: db)
        }
    }

    final func drawSelfThenChildren(in canvasSize: CGSize) -> AnyView
        //Draws self and recursively draws children.
        //This is a separate function so that you can override draw() without messing this part up.
    {
        // Start with the current node's view
        var views: [AnyView] = [draw(in: canvasSize)]

        // Recursively append children's views
        for child in children {
            views.append(child.drawSelfThenChildren(in: canvasSize))
        }

        // Return a single AnyView with a ZStack of all views
        return AnyView(
            ZStack {
                ForEach(Array(views.enumerated()), id: \.offset) { _, view in
                    view
                }
            }
        )
    }
}
