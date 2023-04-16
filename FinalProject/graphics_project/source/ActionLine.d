import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import Action : Action;

class ActionLine : Action {

    Tuple!(int, int)[] points;
    int[] color;

    this(Tuple!(int, int)[] _points, int[] _color) {
        
        this.points = _points;
        this.color = _color;
    }

    ~this(){}
}
