import std.stdio;
import std.typecons;
import std.algorithm.comparison;

import core.math;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import drawing_utilities;

class Shape {

  this() {

  }

  ~this() {

  }
  
  void drawShape(Surface* surf, int brushSize, ubyte r, ubyte g, ubyte b) {

    // !!!!!
    int[Tuple!(int, int)] pixelMap;
    // !!!!!

    DrawingUtility d = new DrawingUtility();
    SDL_Event e;
    // Handle events
    // Events are pushed into an 'event queue' internally in SDL, and then
    // handled one at a time within this loop for as many events have
    // been pushed into the internal SDL queue. Thus, we poll until there
    // are '0' events or a NULL event is returned.
    bool shapeIsDrawn = false;
    while (!shapeIsDrawn) {
      while(SDL_PollEvent(&e) !=0){
        if(e.type == SDL_QUIT){
            shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_r) {
          writeln("Drawing rectangle");

          int numPoints = 0;
          int numPointsNeeded = 2;

          Tuple!(int, int) p1, p2, p3, p4;

          while (numPoints < numPointsNeeded) {
            SDL_Event f;
            while (SDL_PollEvent(&f) != 0) {
              if (f.type == SDL_QUIT) {
                shapeIsDrawn = true;
                break;
              } else if (f.type == SDL_MOUSEBUTTONDOWN) {
                if (numPoints == 0) {
                  p1 = tuple(f.button.x, f.button.y);
                  surf.lerp(p1[0], p1[1], p1[0], p1[1], brushSize, r, g, b);
                } else {
                  p3 = tuple(f.button.x, f.button.y);
                  surf.UpdateSurfacePixel(p3[0], p3[1], r, g, b);
                }
                ++numPoints;
              }
            }
          }

          p2 = tuple(p3[0], p1[1]);
          p4 = tuple(p1[0], p3[1]);

          surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
          surf.lerp(p2[0], p2[1], p3[0], p3[1], brushSize, r, g, b);
          surf.lerp(p3[0], p3[1], p4[0], p4[1], brushSize, r, g, b);
          surf.lerp(p4[0], p4[1], p1[0], p1[1], brushSize, r, g, b);

          int midX = (p1[0] + p3[0]) / 2;
          int midY = (p1[1] + p3[1]) / 2;

          int minX = min(p1[0], p3[0]);
          int maxX = max(p1[0], p3[0]);

          int minY = min(p1[1], p3[1]);
          int maxY = max(p1[1], p3[1]);

          for (int i = minX; i <= maxX; ++i) {
            for (int j = minY; j <= maxY; ++j) {
              surf.UpdateSurfacePixel(i, j, r, g, b);
            }
          }

          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_l) {
          writeln("Drawing line");

          int numPoints = 0;
          int numPointsNeeded = 2;

          Tuple!(int, int) p1, p2;

          while (numPoints < numPointsNeeded) {
            SDL_Event f;
            while (SDL_PollEvent(&f) != 0) {
              if (f.type == SDL_QUIT) {
                shapeIsDrawn = true;
                break;
              } else if (f.type == SDL_MOUSEBUTTONDOWN) {
                if (numPoints == 0) {
                  p1 = tuple(f.button.x, f.button.y);
                } else {
                  p2 = tuple(f.button.x, f.button.y);
                }
                ++numPoints;
              }
            }
          }

          int left = min(p1[0], p2[0]), right = max(p1[0], p2[0]);
          int top = min(p1[1], p2[1]), bottom = max(p1[1], p2[1]);

          surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);

          writeln("Line has been drawn");
          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_c) {
          writeln("Drawing circle");

          int numPoints = 0;
          int numPointsNeeded = 2;

          Tuple!(int, int) p1, p2, midpoint;

          while (numPoints < numPointsNeeded) {
            SDL_Event f;
            while (SDL_PollEvent(&f) != 0) {
              if (f.type == SDL_QUIT) {
                shapeIsDrawn = true;
                break;
              } else if (f.type == SDL_MOUSEBUTTONDOWN) {
                if (numPoints == 0) {
                  p1 = tuple(f.button.x, f.button.y);
                } else {
                  p2 = tuple(f.button.x, f.button.y);
                }
                ++numPoints;
              }
            }
          }

          int radius = cast(int) sqrt(cast(float) ((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]))) / 2;
          midpoint = tuple(cast(int) ((p1[0] + p2[0]) / 2), cast(int) ((p1[1] + p2[1]) / 2));

          int top, bottom, left, right;
          top = max(0, midpoint[1] - radius);
          bottom = min(480, midpoint[1] + radius);
          left = max(0, midpoint[0] - radius);
          right = min(640, midpoint[0] + radius);

          for (int i = top; i <= bottom; ++i) {
            for (int j = left; j <= right; ++j) {
              if ((j - midpoint[0]) * (j - midpoint[0]) + (i - midpoint[1]) * (i - midpoint[1]) <= radius * radius) {
                surf.UpdateSurfacePixel(j, i, r, g, b);
              }
            }
          }

          shapeIsDrawn = true;

        } else if (e.key.keysym.sym == SDLK_t) {
          writeln("Drawing triangle");

          int numPoints = 0;
          int numPointsNeeded = 3;

          Tuple!(int, int) p1, p2, p3;

          while (numPoints < numPointsNeeded) {
            SDL_Event f;
            while (SDL_PollEvent(&f) != 0) {
              if (f.type == SDL_QUIT) {
                shapeIsDrawn = true;
                break;
              } else if (f.type == SDL_MOUSEBUTTONDOWN) {
                if (numPoints == 0) {
                  p1 = tuple(f.button.x, f.button.y);
                } else if (numPoints == 1) {
                  p2 = tuple(f.button.x, f.button.y);
                } else {
                  p3 = tuple(f.button.x, f.button.y);
                }
                ++numPoints;
              }
            }
          }

          // if (fabs(cast(float) (p2[0] - p1[0]))) {
          //   continue;
          // }

          // (a, b), (c, d)
          // y - b = (d - b)/(c - a) * (x - a)

          int top = min(p1[1], p2[1], p3[1]), bottom = max(p1[1], p2[1], p3[1]), left = min(p1[0], p1[0], p2[0]), right = max(p1[0], p2[0], p3[0]);

          surf.lerp(p1[0], p1[1], p2[0], p2[1], brushSize, r, g, b);
          surf.lerp(p2[0], p2[1], p3[0], p3[1], brushSize, r, g, b);
          surf.lerp(p1[0], p1[1], p3[0], p3[1], brushSize, r, g, b);

          Tuple!(int, int) centroid = tuple((p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3);

          surf.lerp(centroid[0], centroid[1], centroid[0], centroid[1], brushSize, r, g, b);

          shapeIsDrawn = true;
        }
      }
    }
  }
}