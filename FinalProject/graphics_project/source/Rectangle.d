import std.algorithm;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape2 : Shape2;
import SDL_Surfaces;

class Rectangle : Shape2 {

    Surface* surf;

    this(Surface* surf) {

        this.surf = surf;
    }

    ~this() {}

    /**
    * Helper for 'draw' function that fills rectangle based on user-chosen points. 
    */
    void fillRectangle(int left, int right, int top, int bottom, int r, int g, int b) {

        for (int i = left; i <= right; ++i) {
            for (int j = top; j <= bottom; ++j) {
                this.surf.UpdateSurfacePixel(i, j, cast(ubyte) r, cast(ubyte) g, cast(ubyte) b);
            }
        }
    }

    /**
    * Draws this Rectangle based on the user's clicks. Exactly two mouse
    * clicks are required to draw a Rectangle. The clicks must be opposites 
    * of each other (e.g. bottom left and top right, top left and bottom 
    * right, top right and bottom left, or bottom right and top left).
    *
    * Example
    * --------------------
    * Shape rec = new Rectangle();
    * rec.draw();   // Draw filled rectangle upon two mouse clicks
    *
    *  Params:
    *  brushSize - the width and height of each drawn point
    *  r - red value in range [0, 255]
    *  g - green value in range [0, 255]
    *  b - blue value in range [0, 255]
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