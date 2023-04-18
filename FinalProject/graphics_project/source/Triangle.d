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

class Triangle : Shape {

    Surface* surf;
    Tuple!(int, int)[] points;

    this(Surface* surf) {
        this.surf = surf;
    }

    ~this() {}

    bool isLine(Tuple!(int, int) p1, Tuple!(int, int) p2, Tuple!(int, int) p3, int brushSize, ubyte r, ubyte g, ubyte b) {

        bool isSamePoints = (p1[0] == p2[0] && p1[1] == p2[1]) || (p2[0] == p3[0] && p2[1] == p3[1]) || (p1[0] == p3[0] && p1[1] == p3[1]);

        bool isAligned = (p1[0] == p2[0] && p1[0] == p3[0]) || (p1[1] == p2[1] && p1[1] == p3[1]);

        return isSamePoints || isAligned;
    }

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
        
        // if (isLine(p1, p2, p3, brushSize, r, g, b)) {

        //     surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
        //     surf.lerp(p2[0], p2[1], p3[0], p3[1], brushSize, r, g, b);
        //     surf.lerp(p1[0], p1[1], p3[0], p3[1], brushSize, r, g, b);
        // }
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
        
        //Check that drawing triangle doesn't overlap menu bounds 
        if((p1[1] < 50) || (p2[1] < 50) || (p3[1] < 50)){
            writeln("Try again, circle set to overlap menu");
        }
        //Draw the triangle 
        else {

            this.points ~= p1;
            this.points ~= p2;
            this.points ~= p3;

            // int top = min(p1[1], p2[1], p3[1]), bottom = max(p1[1], p2[1], p3[1]), 
            //     left = min(p1[0], p1[0], p2[0]), right = max(p1[0], p2[0], p3[0]);
            fillTriangle(p1, p2, p3, brushSize, r, g, b);
        }
    }

    override void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b, int brushSize) {

        assert(points.length == 3);

        fillTriangle(points[0], points[1], points[2], brushSize, r, g, b);
    }

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