import std.stdio;
import std.string;

// import bindbc.sdl;
// import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
// import SDL_Initial :SDLInit;

import Shape : Shape;
import Line : Line;
import Rectangle : Rectangle;
import Circle : Circle;
import Triangle : Triangle;

class ShapeFactory {

    this() {}
    ~this() {}

    Shape createShape(string sh, Surface *surf) {

        Shape outputShape;

        if (sh == "line") {
            outputShape = new Line(surf);
        } else if (sh == "rectangle") {
            outputShape = new Rectangle(surf);
        } else if (sh == "circle") {
            outputShape = new Circle(surf);
        } else if (sh == "triangle") {
            outputShape = new Triangle(surf);
        }

        return outputShape;
    }
}