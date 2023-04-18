import std.algorithm;
import std.typecons;
import std.math;
import std.stdio;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape : Shape;
import SDL_Surfaces;

class Circle : Shape {

    Surface* surf;
    Tuple!(int, int)[] points;

    this(Surface* surf) {
        this.surf = surf;
    }

    ~this() {}

    /**
    * Helper for 'draw' function that fills circle based on user-chosen points.
    *
    * Params:
    * midpoint - midpoint of the line formed by connecting user's points
    * radius - half the length of the line formed by connecting user's points
    * r - red color value in range [0, 255]
    * g - green color value in range [0, 255]
    * b - blue colover value in range [0, 255]
    */
    void fillCircle(Tuple!(int, int) midpoint, int radius, ubyte r, ubyte g, ubyte b) {

        int top, bottom, left, right;
            top = max(0, midpoint[1] - radius);
            bottom = min(480, midpoint[1] + radius);
            left = max(0, midpoint[0] - radius);
            right = min(640, midpoint[0] + radius);

            for (int i = top; i <= bottom; ++i) {
                for (int j = left; j <= right; ++j) {
                    if ((j - midpoint[0]) * (j - midpoint[0]) + (i - midpoint[1]) * (i - midpoint[1]) <= radius * radius) {
                        surf.UpdateSurfacePixel(j, i, r, g, b);
                    }
                }
            }
    }

    /**
    * Draws this Circle based on the user's clicks. Exactly two mouse
    * clicks are required to draw a Circle. The user's clicks represent
    * the diameter of the Circle, regardless of the orientation the line is
    * drawn at.
    *
    * Example
    * --------------------
    * Shape cir = new Circle();
    * cir.draw();   // Draw filled circle upon two mouse clicks
    *
    *  Params:
    *  brushSize - the width and height of each drawn point
    *  r - red value in range [0, 255]
    *  g - green value in range [0, 255]
    *  b - blue value in range [0, 255]
    */
    override void draw(int brushSize, ubyte r, ubyte g, ubyte b) {

        // The two points required represent the circle's diameter
        // The midpoint of the circle is the midpoint of the line formed from the two points
        int numPoints = 0, numPointsNeeded = 2;

        // Create 2 points representing diameter
        // Also create tuple to hold midpoint
        Tuple!(int, int) p1, p2, midpoint;

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
                        p2 = tuple(e.button.x, e.button.y);
                    }
                    ++numPoints;
                }
            }
        }

        points ~= p1;
        points ~= p2;

        //Stops the shape from drawing if you try to draw within the menu bounds 
        if((p1[1] < 50) || (p2[1] < 50)){
            writeln("Try again, circle set to overlap menu");
        }
        else{ 
            // Find circle radius and midpoint
            int radius = cast(int) sqrt(cast(float) ((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]))) / 2;
            midpoint = tuple(cast(int) ((p1[0] + p2[0]) / 2), cast(int) ((p1[1] + p2[1]) / 2));

            // Fill points in circle
            fillCircle(midpoint, radius, r, g, b);
        }
    }

    override void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize) {

        assert(points.length == 2);

        Tuple!(int, int) p1 = points[0], p2 = points[1];

        int radius = cast(int) sqrt(cast(float) ((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]))) / 2;
        Tuple!(int, int) midpoint = tuple(cast(int) ((p1[0] + p2[0]) / 2), cast(int) ((p1[1] + p2[1]) / 2));

        fillCircle(midpoint, radius, r, g, b);
    }

    override Tuple!(int, int)[] getPoints() {

        return this.points;
    }

}


/**
* Test: Checks for the surface to be initialized to black, draw red circle
* Ensure interior points are red, exterior remain black
*/
@("Draw circle test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    Circle cir = new Circle(&s);
    cir.drawFromPoints([tuple(1, 1), tuple(12,12)], 255, 128, 32, 1);
    /// Check leftmost edge
    assert(	s.PixelAt(1,6)[0] == 255 &&
    s.PixelAt(1,6)[1] == 128 &&
    s.PixelAt(1,6)[2] == 32, "error rgb value at 1,6 is wrong!");
    /// Check top left corner
    assert(	s.PixelAt(13,6)[0] == 255 &&
    s.PixelAt(13,6)[1] == 128 &&
    s.PixelAt(13,6)[2] == 32, "error rgb value at 13,6 is wrong!");
    /// Check topmost edge
    assert(	s.PixelAt(6,1)[0] == 255 &&
    s.PixelAt(6,1)[1] == 128 &&
    s.PixelAt(6,1)[2] == 32, "error rgb value at 6,1 is wrong!");
    /// Check bottommost edge
    assert(	s.PixelAt(13,6)[0] == 255 &&
    s.PixelAt(6,13)[1] == 128 &&
    s.PixelAt(6,13)[2] == 32, "error rgb value at 6,13 is wrong!");
    /// Check top right corner
    assert(	s.PixelAt(14,6)[0] == 0 &&
    s.PixelAt(14,6)[1] == 0 &&
    s.PixelAt(14,6)[2] == 0, "error rgb value at 14,6 is wrong!");
    assert(	s.PixelAt(6,14)[0] == 0 &&
    s.PixelAt(6,14)[1] == 0 &&
    s.PixelAt(6,14)[2] == 0, "error rgb value at 6,14 is wrong!");
    /// Check rounded courners weren't changed
    writeln("(1,1): ", s.PixelAt(1,1));
    assert(	s.PixelAt(1,1)[0] == 0 &&
    s.PixelAt(1,1)[1] == 0 &&
    s.PixelAt(1,1)[2] == 0, "error rgb value at 1,1 is wrong!");
    assert(	s.PixelAt(13,13)[0] == 0 &&
    s.PixelAt(13,13)[1] == 0 &&
    s.PixelAt(13,13)[2] == 0, "error rgb value at 13,13 is wrong!");
}