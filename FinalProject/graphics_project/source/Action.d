
import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

abstract class Action {

    abstract void addPoint(Tuple!(int, int) p);
}