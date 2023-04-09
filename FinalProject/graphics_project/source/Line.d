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

    override void draw() {
        
    }
}