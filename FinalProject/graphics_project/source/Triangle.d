import std.algorithm;
import std.typecons;
import std.stdio;

import core.math;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape : Shape;
import SDL_Surfaces;


/***********************************
* Name: Triangle 
* Descripton: A shape which takes three points and returns a filled triangle shape on the surface. 
*/
class Triangle : Shape {

    Surface* surf;
    Tuple!(int, int)[] points;

    /***********************************
    * Name: constructor
    * Description: takes the surface to put Circle on 
    * Params:
    *    surf = the surface we need to draw on 
    */
    this(Surface* surf) {
        this.surf = surf;
    }

    /***********************************
    * Name: Destructor
    * Description: default destructor 
    */
    ~this() {}

    /***********************************
    * Name: isLine 
    * Description: Look at some points and see if they are on a straight line 
    * Params: 
    *    p1 = the first point passed
    *    p2 = the second point passed
    *    p3 = the third point passed
    *    r = red color value in range [0, 255]
    *    g = green color value in range [0, 255]
    *    b = blue colover value in range [0, 255]
    * Returns: Whether the points form a line or not 
    */
    bool isLine(Tuple!(int, int) p1, Tuple!(int, int) p2, Tuple!(int, int) p3, int brushSize, ubyte r, ubyte g, ubyte b) {

        bool isSamePoints = (p1[0] == p2[0] && p1[1] == p2[1]) || (p2[0] == p3[0] && p2[1] == p3[1]) || (p1[0] == p3[0] && p1[1] == p3[1]);

        bool isAligned = (p1[0] == p2[0] && p1[0] == p3[0]) || (p1[1] == p2[1] && p1[1] == p3[1]);

        return isSamePoints || isAligned;
    }

    /***********************************
    * Name: fillTriangle 
    * Description: Given three points and an RGB value, draw a filled, colored shape 
    * Params: 
    *    p1 = the first point passed
    *    p2 = the second point passed
    *    p3 = the third point passed
    *    brushSize = the brush size currently selected 
    *    r = red color value in range [0, 255]
    *    g = green color value in range [0, 255]
    *    b = blue colover value in range [0, 255]
    */
    void fillTriangle(Tuple!(int, int) p1, Tuple!(int, int) p2, Tuple!(int, int) p3, int brushSize, ubyte r, ubyte g, ubyte b) {

        int top = min(p1[1], p2[1], p3[1]), bottom = max(p1[1], p2[1], p3[1]), 
            left = min(p1[0], p1[0], p2[0]), right = max(p1[0], p2[0], p3[0]);

        for (int i = left; i <= right; i++) {
            for (int j = top; j <= bottom; j++) {

                double a = cast(double) ((p2[1] - p3[1])*(i - p3[0]) + (p3[0] - p2[0])*(j - p3[1])) / cast(double) ((p2[1] - p3[1])*(p1[0] - p3[0]) + (p3[0] - p2[0])*(p1[1] - p3[1]));
                double d = cast(double) ((p3[1] - p1[1])*(i - p3[0]) + (p1[0] - p3[0])*(j - p3[1])) / cast(double) ((p2[1] - p3[1])*(p1[0] - p3[0]) + (p3[0] - p2[0])*(p1[1] - p3[1]));
                double c = 1.0 - a - d;
                
                if (a >= 0 && a <= 1 && d >= 0 && d <= 1 && c >= 0 && c <= 1) {
                    surf.UpdateSurfacePixel(i, j, r, g, b);
                }
            }
        }
    }

    /***********************************
    * Name: draw 
    * Description: Draw the lines of a triangle 
    * Params: 
    *    brushSize = current size of brush 
    *    r = red color value in range [0, 255]
    *    g = green color value in range [0, 255]
    *    b = blue colover value in range [0, 255]
    */
    override void draw(int brushSize, ubyte r, ubyte g, ubyte b) {

        int numPoints = 0, numPointsNeeded = 3;

        Tuple!(int, int) p1, p2, p3;

        while (numPoints < numPointsNeeded) {
            SDL_Event f;
            while (SDL_PollEvent(&f) != 0) {
                if (f.type == SDL_QUIT) {
                    return;
                } else if (f.type == SDL_MOUSEBUTTONDOWN) {
                    if (numPoints == 0) {
                        p1 = tuple(f.button.x, f.button.y);
                    } else if (numPoints == 1) {
                        p2 = tuple(f.button.x, f.button.y);
                    } else {
                        p3 = tuple(f.button.x, f.button.y);
                    }
                    ++numPoints;
                }
            }
        }
        
        //Check that drawing triangle doesn't overlap menu bounds 
        if((p1[1] < 50) || (p2[1] < 50) || (p3[1] < 50)){
            writeln("Try again, circle set to overlap menu");
        }
        //Draw the triangle 
        else {

            this.points ~= p1;
            this.points ~= p2;
            this.points ~= p3;

            fillTriangle(p1, p2, p3, brushSize, r, g, b);
        }
    }

   /***********************************
    * Name: drawFromPoints
    * Description: Draw the lines of a triangle given three coordinates tuples 
    * Params: 
    *    points = an array of three coordinate tuples 
    *    r = red color value in range [0, 255]
    *    g = green color value in range [0, 255]
    *    b = blue colover value in range [0, 255]
    */
    override void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize) {

        assert(points.length == 3);

        fillTriangle(points[0], points[1], points[2], brushSize, r, g, b);
    }

    /***********************************
    * Name: getPoints 
    * Description: Get the points of thisx triangle 
    * Returns: a tuple of the coordinates of the triagle 
    */
    override Tuple!(int, int)[] getPoints() {
        return this.points;
    }
}

/**
* Test: Checks for the surface to be initialized to black, draw red triangle
* Ensure interior points are red, exterior remain black
*/
@("Draw triangle test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    Triangle tri = new Triangle(&s);
    tri.drawFromPoints([tuple(1, 1), tuple(1,30), tuple(30,30)], 255, 128, 32, 1);
    /// Check leftmost edge
    assert(	s.PixelAt(1,30)[0] == 255 &&
    s.PixelAt(1,30)[1] == 128 &&
    s.PixelAt(1,30)[2] == 32, "error rgb value at 1,30 is wrong!");
    /// Check that external pixel close to line is still red
    assert(	s.PixelAt(3,1)[0] == 0 &&
    s.PixelAt(3,1)[1] == 0 &&
    s.PixelAt(3,1)[2] == 0, "error rgb value at 3,1 is wrong!");
}