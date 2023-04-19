import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

/**
* A Shape is a geometric representation of colored pixels.
* The abstract Shape class must be inherited by concrete child classes.
*/
abstract class Shape {

    /**
    * Name: draw
    * Description: Draws a Shape. Shapes are drawn after a series of mouse clicks are 
    * registered from the user. Usually, a shape requires at least two and 
    * at most three clicks. All shapes will be drawn filled in.
    * Params:
    *   @param brushSize: size of the paintbrush
    *   @param r, g, b: the color value representing this Shape
    */
    abstract void draw(int brushSize, ubyte r, ubyte g, ubyte b);

    /**
    * Name: drawFromPoints
    * Description: Draws a Shape from a series of points entered as parameters. The Shape
    * will be drawn filled in.
    * Params:
    *   @param points: A minimal list of points needed to draw this Shape
    *   @param r, g, b: the color value representing this Shape
    *   @param brushSize: size of the paintbrush
    */
    abstract void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize);

    /**
    * Name: getPoints
    * Description: Returns the minimal set of points needed to draw this Shape.
    * Returns: An array of points that can be used to redraw this Shape. Returned as
    * as list of tuples of integers.
    */
    abstract Tuple!(int, int)[] getPoints();
    
    // abstract SDL_Color[Tuple!(int, int)] getConstituentPoints();
    // abstract SDL_Color[Tuple!(int, int)] getUnderlyingPoints();
}
