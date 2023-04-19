import std.algorithm;
import std.typecons;
import std.stdio;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape : Shape;
import SDL_Surfaces;

/**
* A Rectangle is a Shape. It is filled, has four sides, and four right corners.
* Two points are needed to draw a Rectangle.
*/
class Rectangle : Shape {

    Surface* surf;
    Tuple!(int, int)[] points;

    /**
    * Constructor. A Rectangle requires a Surface to draw on.
    */
    this(Surface* surf) {

        this.surf = surf;
    }

    /**
    * Destructor.
    */
    ~this() {}

    /**
    * Name: fillRectangle
    * Description: Helper for 'draw' function that fills rectangle based on user-chosen points.
    * Params:
    *   left = the left bound of the rectangle; no points to the left of this will be filled
    *   right = the right bound of the rectangle; no points to the right of this will be filled
    *   top = the upper bound of the rectangle; no points physically above it will be filled
    *   bottom = the lower of the of the rectangle; no points physically below it will be filled
    *   r = red color value in range [0, 255]
    *   g = green color value in range [0, 255]
    *   b = blue colover value in range [0, 255]
    */
    void fillRectangle(int left, int right, int top, int bottom, ubyte r, ubyte g, ubyte b) {

        for (int i = left; i <= right; ++i) {
            for (int j = top; j <= bottom; ++j) {
                this.surf.UpdateSurfacePixel(i, j, cast(ubyte) r, cast(ubyte) g, cast(ubyte) b);
            }
        }
    }

    /**
    * Name: draw
    * Description: Draws this Rectangle based on the user's clicks. Exactly two mouse
    * clicks are required to draw a Rectangle. The clicks must be opposites 
    * of each other (e.g. bottom left and top right, top left and bottom 
    * right, top right and bottom left, or bottom right and top left).
    * Params:
    *   brushSize = the width and height of each drawn point
    *   r = red value in range [0, 255]
    *   g = green value in range [0, 255]
    *   b = blue value in range [0, 255]
    */
    override void draw(int brushSize, ubyte r, ubyte g, ubyte b) {

        // Need two points for opposing mouse clicks
        int numPoints = 0, numPointsNeeded = 2;

        // Create 4 points to later use lerp on
        Tuple!(int, int) p1, p2, p3, p4;

        // Begin loop to register clicks
        while (numPoints < numPointsNeeded) {
            SDL_Event e;

            while (SDL_PollEvent(&e) != 0) {
                if (e.type == SDL_QUIT) {
                    return;    // EXIT_SUCCESS if quit is registered
                } else if (e.type == SDL_MOUSEBUTTONDOWN) {
                    if (numPoints == 0) {
                        p1 = tuple(e.button.x, e.button.y);
                    } else {
                        p3 = tuple(e.button.x, e.button.y);
                    }
                    ++numPoints;
                }
            }
        }
        //Check that rectangle drawing doesn't overlap menu bounds 
        if((p1[1] < 50) || (p3[1] < 50)){
            writeln("Try again, rectangle set to overlap menu");
        }
        //Draw the rectangle 
        else {
            // Declare remaining outstanding points
            p2 = tuple(p3[0], p1[1]);
            p4 = tuple(p1[0], p3[1]);

            points ~= p1;
            points ~= p3;

            // Declare remaining outstanding points
            p2 = tuple(p3[0], p1[1]);
            p4 = tuple(p1[0], p3[1]);

            // Find left, right, top and bottom most points to iterate over
            int minX = min(p1[0], p3[0]);
            int maxX = max(p1[0], p3[0]);

            int minY = min(p1[1], p3[1]);
            int maxY = max(p1[1], p3[1]);

            // Fill rectangle
            fillRectangle(minX, maxX, minY, maxY, r, g, b);
        }
    }

    /**
    * name: drawFromPoints
    * description: Draws a Rectangle from an array of two points. The points should be opposites
    * of each other. The Rectangle will drawn filled.
    * params:
    *   @param points: Array of points 
    *   @param r, g, b: red, blue, green color values
    *   @brushSize: Not used in rectangle
    */
    override void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize) {

        assert(points.length == 2);

        Tuple!(int, int) p1 = points[0], p3 = points[1], p2 = tuple(p3[0], p1[1]), p4 = tuple(p1[0], p3[1]);

        // Find left, right, top and bottom most points to iterate over
        int minX = min(p1[0], p3[0]);
        int maxX = max(p1[0], p3[0]);

        int minY = min(p1[1], p3[1]);
        int maxY = max(p1[1], p3[1]);

        // Fill rectangle
        fillRectangle(minX, maxX, minY, maxY, r, g, b);
    }

    /**
    * name: getPoints
    * description: Gets and returns the points that are needed to draw this Rectangle.
    * If getPoints is invoked before the Rectangle is drawn, an empty array is
    * returned.
    * returns: An array of two integer tuples.
    */
    override Tuple!(int, int)[] getPoints() {

        return this.points;
    }

}


/**
* Test: Checks for the surface to be initialized to black, draw red square
* Ensure interior points are red, exterior remain black
*/
@("Draw rectangle test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    Rectangle rect = new Rectangle(&s);
    rect.drawFromPoints([tuple(1, 1), tuple(3, 3)], 255, 128, 32, 1);
    /// Check midpoint
    assert(	s.PixelAt(2,2)[0] == 255 &&
    s.PixelAt(2,2)[1] == 128 &&
    s.PixelAt(2,2)[2] == 32, "error rgb value at 2,2 is wrong!");
    /// Check top left corner
    assert(	s.PixelAt(1,1)[0] == 255 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 32, "error rgb value at 1,1 is wrong!");
    /// Check bottom left corner    /// Check top right corner
    assert(	s.PixelAt(3,1)[0] == 255 &&
    s.PixelAt(3,1)[1] == 128 &&
    s.PixelAt(3,1)[2] == 32, "error rgb value at 3,1 is wrong!");
    /// Check bottom left corner
    assert(	s.PixelAt(1,3)[0] == 255 &&
    s.PixelAt(1,3)[1] == 128 &&
    s.PixelAt(1,3)[2] == 32, "error rgb value at 1,3 is wrong!");
    /// Check bottom right corner
    assert(	s.PixelAt(3,3)[0] == 255 &&
    s.PixelAt(3,3)[1] == 128 &&
    s.PixelAt(3,3)[2] == 32, "error rgb value at 3,3 is wrong!");
    /// Check outside square wasn't changed
    assert(	s.PixelAt(0,0)[0] == 0 &&
    s.PixelAt(0,0)[1] == 0 &&
    s.PixelAt(0,0)[2] == 0, "error rgb value at 3,3 is wrong!");    
    /// Check outside square wasn't changed
    assert(	s.PixelAt(4,4)[0] == 0 &&
    s.PixelAt(4,4)[1] == 0 &&
    s.PixelAt(4,4)[2] == 0, "error rgb value at 3,3 is wrong!");
}