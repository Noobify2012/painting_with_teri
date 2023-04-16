
import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

class Action {

    Tuple!(int, int)[] points;
    int[] color;
    string actionType;

    this(Tuple!(int, int)[] _points, int[] _color, string _actionType) {
        
        this.points = _points;
        this.color = _color;
        this.actionType = _actionType;
    }

    Tuple!(int, int)[] getPoints() {
        writeln("made it here");
        return this.points;
    }

    int[] getColor() {

        return this.color;
    }

    string getActionType() {

        return this.actionType;
    }

    void addPoint(Tuple!(int, int) pt) {

        this.points ~= pt;
    }
}