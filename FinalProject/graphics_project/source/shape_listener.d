import std.stdio;
import std.typecons;
import std.algorithm.comparison;
import std.string;

import core.math;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import drawing_utilities;
import Shape : Shape;
import Rectangle : Rectangle;
import Circle : Circle;
import Line : Line;
import Triangle : Triangle;
import ShapeFactory : ShapeFactory;

class ShapeListener {

  this() {

  }

  ~this() {

  }
  
  void drawShape(Surface* surf, int brushSize, ubyte r, ubyte g, ubyte b) {

    DrawingUtility d = new DrawingUtility();

    ShapeFactory shapeFactory = new ShapeFactory();
    SDL_Event e;
    // Handle events
    // Events are pushed into an 'event queue' internally in SDL, and then
    // handled one at a time within this loop for as many events have
    // been pushed into the internal SDL queue. Thus, we poll until there
    // are '0' events or a NULL event is returned.
    bool shapeIsDrawn = false;
    while (!shapeIsDrawn) {
      Shape sh;
      while(SDL_PollEvent(&e) !=0){
        if(e.type == SDL_QUIT){
            shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_r) {
          writeln("Drawing rectangle");

          sh = shapeFactory.createShape("rectangle", surf);
          sh.draw(brushSize, r, g, b);

          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_l) {
          writeln("Drawing line");

          sh = shapeFactory.createShape("line", surf);
          sh.draw(brushSize, r, g, b);

          writeln("Line has been drawn");
          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_c) {
          writeln("Drawing circle");

          sh = shapeFactory.createShape("circle", surf);
          sh.draw(brushSize, r, g, b);

          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_t) {
          writeln("Drawing triangle");

          sh = shapeFactory.createShape("triangle", surf);
          sh.draw(brushSize, r, g, b);
          shapeIsDrawn = true;
        }
      }
    }
  }
}