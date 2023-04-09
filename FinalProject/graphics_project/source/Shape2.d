import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

abstract class Shape2 {

    abstract void draw(int brushSize, ubyte r, ubyte g, ubyte b);
    // abstract SDL_Color[Tuple!(int, int)] getConstituentPoints();
    // abstract SDL_Color[Tuple!(int, int)] getUnderlyingPoints();
}
