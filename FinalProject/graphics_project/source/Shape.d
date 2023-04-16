import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

abstract class Shape {

    abstract void draw(int brushSize, ubyte r, ubyte g, ubyte b);
    abstract void drawFromPoints(Tuple!(int, int)[] points, ubyte r, ubyte g, ubyte b), int brushSize;
    // abstract SDL_Color[Tuple!(int, int)] getConstituentPoints();
    // abstract SDL_Color[Tuple!(int, int)] getUnderlyingPoints();
}
