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

    Action[] undoStack;
    Action[] redoStack;
    int undoPosition, redoPosition;
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

    void addAction(Action act) {

        // int[] initUndoColor = [0, 0, 0];
        // Action undoAction = new Action(act.getPoints(), initUndoColor, act.getActionType());
        undoStack ~= act;

        redoStack = [];
    }

    void undo() {

        if (undoStack.length > 0) {
            
            Action undone = undoStack[undoStack.length - 1];
            undoStack = undoStack[0 .. undoStack.length - 1];
            
            string aType = undone.getActionType();
            Tuple!(int, int)[] pts = undone.getPoints();

            if (aType == "circle") {

                Shape circle = new Circle(surf);
                circle.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "rectangle") {

                Shape rect = new Rectangle(surf);
                rect.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "triangle") {

                Shape tri = new Triangle(surf);
                tri.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);

            } else if (aType == "line") {

                Shape lin = new Line(surf);
                lin.drawFromPoints(pts, cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 0, 4);
                
            } else if (aType == "stroke") {

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

            redoStack ~= undone;

        } else {
            
            writeln("Undo stack is empty -- No action taken");
        }

        writeln(this.undoStack.length, this.redoStack.length);
    }

    void redo() {
        if (redoStack.length > 0) {
            
            Action redone = redoStack[redoStack.length - 1];
            redoStack = redoStack[0 .. redoStack.length - 1];
            
            string aType = redone.getActionType();
            Tuple!(int, int)[] pts = redone.getPoints();
            int[] undoColor = redone.getColor();

            if (aType == "circle") {

                Shape circle = new Circle(surf);
                circle.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "rectangle") {

                Shape rect = new Rectangle(surf);
                rect.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "triangle") {

                Shape tri = new Triangle(surf);
                tri.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);

            } else if (aType == "line") {

                Shape lin = new Line(surf);
                lin.drawFromPoints(pts, cast(ubyte) undoColor[0], cast(ubyte) undoColor[1], cast(ubyte) undoColor[2], 4);
                
            } else if (aType == "stroke") {

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
            
            writeln("Redo stack is empty -- No action taken");
        }
    }
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