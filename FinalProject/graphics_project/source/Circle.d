import std.algorithm;
import std.typecons;
import std.math;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape2 : Shape2;
import SDL_Surfaces;

class Circle : Shape2 {

    Surface* surf;

    this(Surface* surf) {
        this.surf = surf;
    }

    ~this() {}

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

        // Find circle radius and midpoint
        int radius = cast(int) sqrt(cast(float) ((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]))) / 2;
        midpoint = tuple(cast(int) ((p1[0] + p2[0]) / 2), cast(int) ((p1[1] + p2[1]) / 2));

        // Fill points in circle
        fillCircle(midpoint, radius, r, g, b);
    }
}