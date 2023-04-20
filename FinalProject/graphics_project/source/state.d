import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;
import Point : Point;
import SDL_Surfaces;

import Action : Action;
import Shape : Shape;
import Circle : Circle;
import Rectangle : Rectangle;
import Line : Line;
import Triangle : Triangle;


/***********************************
* Name: State
* Descripton: This is the current undo and redo stack, accessed for local and networked undo and redo. Holds all previous actions by users. 
*/
class State {
    ///The stack of completed actions 
    Action[] undoStack;

    /// The stack of popped actions 
    Action[] redoStack;

    ///Pointers for each stack 
    int undoPosition, redoPosition;

    /// The surface the actions are being undone/redone on 
    Surface *surf;

    /***********************************
    * Name: constructor
    * Description: Makes a new state  
    * Params:
    *    surf = the surface we need to draw on 
    */
    this(Surface *surf) {
        this.undoPosition = -1;
        this.redoPosition = -1;
        this.surf = surf;
    }

    /***********************************
    * Name: Destructor
    * Description: default destructor 
    */
    ~this() {}

    /***********************************
    * Name: addAction
    * Description: Add the action to the stack and clear the redo stack 
    * Params: 
    *    act = the action to add to the stack 
    */
    void addAction(Action act) {
        
        undoStack ~= act;

        redoStack = [];
    }

    /***********************************
    * Name: undo
    * Description: Pop the action off the stack and add it to the redo stack. Remove that action from the surface. 
    */
    void undo() {

        if (undoStack.length > 0) {
            /// Assign the action to be the last action on the stack 
            Action undone = undoStack[undoStack.length - 1];

            /// Remove the action from the stack 
            undoStack = undoStack[0 .. undoStack.length - 1];
            
            /// Look at what type of action to undo 
            string aType = undone.getActionType();

            /// Get points to undo drawing from 
            Tuple!(int, int)[] pts = undone.getPoints();

            if (aType == "circle") {
                /// Undo a circle 
                Shape circle = new Circle(surf);
                circle.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "rectangle") {
                /// Undo a rectangle 
                Shape rect = new Rectangle(surf);
                rect.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "triangle") {
                /// Undo a triangle 
                Shape tri = new Triangle(surf);
                tri.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "line") {
                /// Undo a line 
                Shape lin = new Line(surf);
                lin.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);
                
            } else if (aType == "stroke") {
                /// Undo a drawn stroke 
                Shape lin = new Line(surf);

                if (pts.length > 1) {
                    int currentPoint = 1;

                    while (currentPoint < pts.length) {
                        Tuple!(int, int)[] ptsTuple = [pts[currentPoint], pts[currentPoint - 1]];

                        lin.drawFromPoints(ptsTuple, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);
                        currentPoint++;
                    }
                }
            }
            /// Add the action to the redo stack once you undo it 
            redoStack ~= undone;

        } else {
            /// There is nothing to undo
            writeln("Undo stack is empty -- No action taken");
        }

        /// Updated stack sizes 
        writeln(this.undoStack.length, this.redoStack.length);
    }

    /***********************************
    * Name: redo
    * Description: Redo the action that you have already undone 
    */
    void redo() {
        if (redoStack.length > 0) {
            /// Set redo action as most recent undone action 
            Action redone = redoStack[redoStack.length - 1];

            /// Adjust redo stack to remove the redo action 
            redoStack = redoStack[0 .. redoStack.length - 1];
            
            /// Look at action to get its type 
            string aType = redone.getActionType();

            /// Get the points to redo the action at 
            Tuple!(int, int)[] pts = redone.getPoints();

            /// Get the color to redo the action in 
            int[] undoColor = redone.getColor();

            if (aType == "circle") {
                /// The action was a circle 
                Shape circle = new Circle(surf);
                circle.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "rectangle") {
                /// The action was a rectangle 
                Shape rect = new Rectangle(surf);
                rect.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "triangle") {
                /// The action was a triangle 
                Shape tri = new Triangle(surf);
                tri.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "line") {
                /// The action was a line 
                Shape lin = new Line(surf);
                lin.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);
                
            } else if (aType == "stroke") {
                /// the action was a drawn stroke 
                Shape lin = new Line(surf);

                if (pts.length > 1) {

                    int currentPoint = 1;

                    while (currentPoint < pts.length) {
                        Tuple!(int, int)[] ptsTuple = [pts[currentPoint], pts[currentPoint - 1]];

                        lin.drawFromPoints(ptsTuple, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);
                        currentPoint++;
                    }
                }
            }

            undoStack ~= redone;
        } else {
            /// There is nothing undone to redo 
            writeln("Redo stack is empty -- No action taken");
        }
    }
    
    /***********************************
    * Name: getRedoStack 
    * Description: Get the length of the current redo stack (already undone actions)
    * Returns: the length of the redo stack 
    */
    ulong getRedoStack() {
    return redoStack.length;
    }
}

/**
* Test: Checks for the surface to be initialized to black, draws diagonal Line
* and checks that intervening points have changed color
*/
@("Undo test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    State sta = new State(&s);
    Action a1 = new Action([tuple(1,1), tuple(3,3)], [32,128,255], "rectangle");
    /// Check that undo and redo stack sizes are 0
    assert( sta.undoStack.length == 0, "Initial undo stack length <>0");
    assert( sta.redoStack.length == 0, "Initial redo stack length <>0");
    /// Add action to state and check it increases undo stack by 1
    sta.addAction(a1);
    assert(	sta.undoStack.length == 1, "Undo stack after adding 1 <>1");
    /// Undo action and check it decreases undo stack and increases redo stack by 1
    sta.undo();
    assert( sta.undoStack.length == 0, "After undo, undo stack length <>0");
    assert( sta.redoStack.length == 1, "After undo, redo stack length <>1");
    /// Redo action and check it increases undo stack and decreases redo stack by 1
    sta.redo();
    assert( sta.undoStack.length == 1, "Initial undo stack length <>1");
    assert( sta.redoStack.length == 0, "Initial redo stack length <>0");

    /// Check that what's been added, removed, and re-added to undo stack is a1
    assert( sta.undoStack[0] == a1, "a1 not in undo stack");
}