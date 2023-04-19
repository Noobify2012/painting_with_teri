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
import state;
import Action : Action;

class ShapeListener {
  string quadrant;
  int brushSize; 

  Action action;

  this() {
  }

  this(string quad, int brushSize){
    this.quadrant = quad;
    this.brushSize = brushSize;
  }

  ~this() {

  }

  Action getAction() {
    
    return this.action;
  }
  
  void drawShape(Surface* surf, int brushSize, ubyte r, ubyte g, ubyte b) {

    DrawingUtility d = new DrawingUtility();

    ShapeFactory shapeFactory = new ShapeFactory();
    SDL_Event e;

    string shapeType;
    // Handle events
    
    bool shapeIsDrawn = false;
    Shape sh;
    while (!shapeIsDrawn) {
      while(SDL_PollEvent(&e) !=0){
        if(e.type == SDL_QUIT){
          ///Reset if user quits 
            shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_r || this.quadrant == "TR") {
          writeln("Drawing rectangle");

          shapeType = "rectangle";
          sh = shapeFactory.createShape("rectangle", surf);
          sh.draw(brushSize, r, g, b);
          writeln("RECTANGLE: Finished drawing");
          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_l || this.quadrant == "TL") {
          writeln("Drawing line");

          shapeType = "line";
          sh = shapeFactory.createShape("line", surf);
          sh.draw(brushSize, r, g, b);
          writeln("LINE: Finished drawing");
          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_c || this.quadrant == "BL") {
          writeln("Drawing circle");

          shapeType = "circle";
          sh = shapeFactory.createShape("circle", surf);
          sh.draw(brushSize, r, g, b);
          writeln("CIRCLE: Finished drawing");
          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_t || this.quadrant == "BR") {
          writeln("Drawing triangle");

          shapeType = "triangle";
          sh = shapeFactory.createShape("triangle", surf);
          sh.draw(brushSize, r, g, b);
          writeln("TRIANGLE: Finished drawing");
          shapeIsDrawn = true;
        }
      }
    }
    int[3] color = [r, g, b];
    this.action = new Action(sh.getPoints(), color, shapeType);
  }
}