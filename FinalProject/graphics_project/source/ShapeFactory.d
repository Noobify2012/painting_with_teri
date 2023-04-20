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


/***********************************
* Name: ShapeFactory
* Descripton: This is a design pattern that outputs the appropriate shape based on the type of shape that is being created. It just helps to organize the files better. 
*/
class ShapeFactory {

    /***********************************
    * Name: constructor
    * Description: default constructor 
    */
    this() {}

    /***********************************
    * Name: Destructor
    * Description: default destructor 
    */
    ~this() {}

   
    /***********************************
    * Name: createShape
    * Description: based on the shape being passed in, export to correct shape class to make an object 
    * Params:
    *    sh = type of shape being passed to class 
    *    surf = surface to draw the shape on
    * Returns: the shape that is created from its class constructor 
    */
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