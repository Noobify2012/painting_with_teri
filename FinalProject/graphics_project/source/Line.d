import std.algorithm;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape2 : Shape2;
import SDL_Surfaces;

class Line : Shape2 {

    Surface* surf;

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

        int left = min(p1[0], p2[0]), right = max(p1[0], p2[0]);
        int top = min(p1[1], p2[1]), bottom = max(p1[1], p2[1]);

        surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
    }
}