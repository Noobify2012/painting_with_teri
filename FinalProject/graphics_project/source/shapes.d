import std.stdio;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

class Shape {

  void fill(int x, int y) {
    
  }
  
  void drawShape() {
    SDL_Event e;
    // Handle events
    // Events are pushed into an 'event queue' internally in SDL, and then
    // handled one at a time within this loop for as many events have
    // been pushed into the internal SDL queue. Thus, we poll until there
    // are '0' events or a NULL event is returned.
    while(SDL_PollEvent(&e) !=0){
      if(e.type == SDL_QUIT){
          break;
      }
    }

    const ubyte* state = SDL_GetKeyboardState(null);
    if (state[SDL_SCANCODE_L]) {
      writeln("Line");
    }
  //   if (state[SDL_SCANCODE_R]) {
  //     writeln("Drawing a rectangle");
  //   } else if (state[SDL_SCANCODE_C]) {
  //     writeln("Drawing a circle");
  //   } else if (state[SDL_SCANCODE_T]) {
  //     writeln("Drawing a triangle");
  //   } else if (state[SDL_SCANCODE_L]) {
  //     writeln("Drawing a line");
      
  //     int numPoints = 0;
  //     int numPointsNeeded = 2;

  //     int x1 = -9999, y1 = -9999, x2 = -9999, y2 = -9999;
  //     SDL_Event p;
  //     while(SDL_PollEvent(&e) !=0 && numPoints < numPointsNeeded){
  //       writeln("hi");
  //       if(p.type == SDL_QUIT){
  //         break;
  //       } else if (p.type == SDL_MOUSEBUTTONDOWN) {
  //         writeln(p.button.x, " ", p.button.y, " ");
  //         if (x1 == -9999) {
  //           x1 = p.button.x;
  //           y1 = p.button.y;
  //         } else {
  //           x2 = p.button.x;
  //           y2 = p.button.y;
  //         }
  //         ++numPoints;
  //       }
  //     }

  //     writeln("x1:", x1, " y1:", y1, " x2:", x2, " y2:", y2);
  //   }
  // }
  }
}