import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

class Point {

    Tuple!(int, int) coordinates;
    SDL_Color color;

    this(int x, int y, SDL_Color color) {

        this.coordinates = tuple(x, y);
        this.color = color;
    }

    /**
    *   Returns the coordinates this point is located at as a 
    *   tuple of integers.
    */
    Tuple!(int, int) getCoordinates() {

        return this.coordinates;
    }

    /**
    *   Returns the color of this point as an SDL_Color object.
    */
    SDL_Color getColor() {

        return color;
    }
}