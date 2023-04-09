import std.algorithm;
import std.typecons;
import std.stdio;

import core.math;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Shape2 : Shape2;
import SDL_Surfaces;

class Triangle : Shape2 {

    Surface* surf;

    this(Surface* surf) {
        this.surf = surf;
    }

    ~this() {}

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
        
        // surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
        // surf.lerp(p2[0], p2[1], p3[0], p3[1], brushSize, r, g, b);
        // surf.lerp(p1[0], p1[1], p3[0], p3[1], brushSize, r, g, b);
    }

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

        // int top = min(p1[1], p2[1], p3[1]), bottom = max(p1[1], p2[1], p3[1]), 
        //     left = min(p1[0], p1[0], p2[0]), right = max(p1[0], p2[0], p3[0]);
        fillTriangle(p1, p2, p3, brushSize, r, g, b);
    }
}