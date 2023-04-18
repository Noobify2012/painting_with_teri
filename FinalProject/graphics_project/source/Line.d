import std.algorithm;
import std.typecons;
import std.stdio;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape : Shape;
import SDL_Surfaces;

class Line : Shape {

    Surface* surf;
    Tuple!(int, int)[] points;

    this(Surface* surf) {
        this.surf = surf;
    }

    ~this() {};

    /**
    * Draws this Line based on the user's clicks. Exactly two mouse
    * clicks are required to draw a Line. The user's clicks represent
    * the endpoints of the Line.
    *
    * Example
    * --------------------
    * Shape lin = new Line();
    * lin.draw();   // Draw filled line upon two mouse clicks
    *
    *  Params:
    *  brushSize - the width and height of each drawn point
    *  r - red value in range [0, 255]
    *  g - green value in range [0, 255]
    *  b - blue value in range [0, 255]
    */
    override void draw(int brushSize, ubyte r, ubyte g, ubyte b) {

        int numPoints = 0, numPointsNeeded = 2;

        Tuple!(int, int) p1, p2;

            while (numPoints < numPointsNeeded) {
                SDL_Event e;
                while (SDL_PollEvent(&e) != 0) {
                    if (e.type == SDL_QUIT) {
                        return;
                    } else if (e.type == SDL_MOUSEBUTTONDOWN) {
                        if (numPoints == 0) {
                            p1 = tuple(e.button.x, e.button.y);
                        } else {
                            p2 = tuple(e.button.x, e.button.y);
                        }
                        ++numPoints;
                    }
                }
            }

        //Check to make sure the line doesn't draw within menu bounds
        if((p1[1] < 50) || (p2[1] < 50)){
            writeln("Try again, line to overlap menu");
        }
        //Draw the line
        else {
            this.points ~= p1;
            this.points ~= p2;
            
            int left = min(p1[0], p2[0]), right = max(p1[0], p2[0]);
            int top = min(p1[1], p2[1]), bottom = max(p1[1], p2[1]);

            surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
        }
    }

    override void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize) {

        assert(points.length == 2);

        this.surf.lerp(points[0][0], points[0][1], points[1][0], points[1][1], brushSize, r, g, b);
    }

    override Tuple!(int, int)[] getPoints() {

        return this.points;
    }
}

/**
* Test: Checks for the surface to be initialized to black, draws diagonal Line
* and checks that intervening points have changed color
*/
@("Line test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    Line li = new Line(&s);
    li.drawFromPoints([tuple(1, 1), tuple(3,3)], 255, 128, 32, 1);
    /// Draw diagonal line and make sure the change takes
    s.lerp(1, 1, 3, 3, 1, 32, 128, 255);
    /// Parse values of new data struct
    assert(	s.PixelAt(2,2)[0] == 32 &&
    s.PixelAt(2,2)[1] == 128 &&
    s.PixelAt(2,2)[2] == 255, "Line error rgb value at x,y is wrong!");
    /// Other pixels should have changed as well bc of how UpdatePixel is implemented
    assert(	s.PixelAt(0,0)[0] == 32 &&
    s.PixelAt(0,0)[1] == 128 &&
    s.PixelAt(0,0)[2] == 255, "Line error rgb value at x,y is wrong!");
    assert(	s.PixelAt(0,1)[0] == 32 &&
    s.PixelAt(0,1)[1] == 128 &&
    s.PixelAt(0,1)[2] == 255, "Line error rgb value at x,y is wrong!");
    assert(	s.PixelAt(3,2)[0] == 32 &&
    s.PixelAt(3,2)[1] == 128 &&
    s.PixelAt(3,2)[2] == 255, "Line error rgb value at x,y is wrong!");
    /// Parse values of new data struct
    // writeln("[0,0]", s.PixelAt(0,0));
    // writeln(s.PixelAt(1,0));
    // writeln(s.PixelAt(2,0));
    // writeln(s.PixelAt(3,0));
    // writeln("[0,1]", s.PixelAt(0,1));
    // writeln(s.PixelAt(1,1));
    // writeln(s.PixelAt(2,1));
    // writeln(s.PixelAt(3,1));
    // writeln(s.PixelAt(4,1));
    // writeln("[0,2]", s.PixelAt(0,2));
    // writeln(s.PixelAt(1,2));
    // writeln(s.PixelAt(2,2));
    // writeln(s.PixelAt(3,2));
    // writeln(s.PixelAt(4,2));
    // writeln("[0,3]", s.PixelAt(0,3));
    // writeln(s.PixelAt(1,3));
    // writeln(s.PixelAt(2,3));
    // writeln(s.PixelAt(3,3));
    // writeln(s.PixelAt(4,3));
    // writeln("[0,4]", s.PixelAt(0,4));
    // writeln(s.PixelAt(1,4));
    // writeln(s.PixelAt(2,4));
    // writeln(s.PixelAt(3,4));
    // writeln(s.PixelAt(4,4));
    /// Make sure other pixels were not colored
    assert(	s.PixelAt(0,2)[0] == 0 &&
    s.PixelAt(0,2)[1] == 0 &&
    s.PixelAt(0,2)[2] == 0, "Line error rgb value at (1,2) is wrong!");
    assert(	s.PixelAt(4,3)[0] == 0 &&
    s.PixelAt(4,3)[1] == 0 &&
    s.PixelAt(4,3)[2] == 0, "Line error rgb value at (1,2) is wrong!");
}