import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

/***********************************
* Name: Point 
* Descripton: An x,y coordinate. 
*/
class Point {
    /// Point coordinates 
    Tuple!(int, int) pnt;

    /// Point colors 
    SDL_Color color;

    /***********************************
    * Name: constructor
    * Description: takes the surface to put Circle on 
    * Params:
    *    x = the x coordinate of point 
    *    y = the y coordinate of point 
    *    color = the color of the point 
    */
    this(int x, int y, SDL_Color color) {
        this.pnt = tuple(x, y);
        this.color = color;
    }

    /***********************************
    * Name: getPoint
    * Description: A getter method to get the point  
    * Returns: the point 
    */
    Tuple!(int, int) getPoint() {
        return pnt;
    }

    /***********************************
    * Name: getColor
    * Description: A getter method to get the point's color values 
    * Returns: the color of the point 
    */
    SDL_Color getColor() {
        return color;
    }
}