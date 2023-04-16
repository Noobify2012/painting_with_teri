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

class State {

    Action[] undoStack;
    Action[] redoStack;
    int undoPosition, redoPosition;
    Surface *surf;

    this(Surface *surf) {
        this.undoPosition = -1;
        this.redoPosition = -1;
        this.surf = surf;
    }

    ~this() {}

    void addAction(Action act) {

        int[] initUndoColor = [0, 0, 0];
        Action undoAction = new Action(act.getPoints(), initUndoColor, act.getActionType());
        undoStack ~= undoAction;
        redoStack ~= act;

        ++undoPosition;
        ++redoPosition;
        writeln(undoStack, redoStack[redoStack.length - 1].getActionType());
    }

    void undo() {

        if (undoStack.length > 0) {
            
            Action undone = undoStack[undoStack.length - 1];
            undoStack = undoStack[0 .. undoStack.length - 1];
            
            string aType = undone.getActionType();
            Tuple!(int, int)[] pts = undone.getPoints();
            int[] undoColor = undone.getColor();

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
                
            }

            --undoPosition;
            --redoPosition;

        } else {
            
            writeln("Undo stack is empty -- No action taken");
        }

        writeln(this.undoStack.length, this.redoStack.length);
    }

    void redo() {
        if (redoStack.length > 0) {
            
            Action redone = redoStack[0];
            redoStack = redoStack[1 .. redoStack.length];
            
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
                
            }

            ++undoPosition;
        } else {
            
            writeln("Redo stack is empty -- No action taken");
        }
    }
}