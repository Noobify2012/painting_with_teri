import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import SDL_Surfaces;

class DrawingUtility {

  this() {

  }

  ~this() {

  }

  SDL_Color getPixelColorAt(int x, int y, SDL_Surface* imgSurface) {

    assert((x >= 0 && x <= 640) && (y >= 0 && y <= 480));

    // When we modify pixels, we need to lock the surface first
    SDL_LockSurface(imgSurface);
    // Make sure to unlock the surface when we are done.
    scope(exit) SDL_UnlockSurface(imgSurface);

    ubyte* pixelArray = cast(ubyte*) imgSurface.pixels;
    Uint8* currentPixel = cast(Uint8*) &pixelArray[y * imgSurface.pitch + x * imgSurface.format.BytesPerPixel];

    Uint32 pixelData = * cast(Uint32*)currentPixel;

    SDL_Color color = {0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE};

    SDL_GetRGB(pixelData, imgSurface.format, &color.r, &color.g, &color.b);

    return color;
  }

  bool isSameColor(SDL_Color c1, SDL_Color c2) {
    return c1.r == c2.r && c1.g == c2.g && c1.b == c1.b;
  }

  void dfs(int x, int y, Surface *surf, ubyte r, ubyte g, ubyte b) {

    SDL_Color startingColor = getPixelColorAt(x, y, surf.getSurface());
    writeln("Starting Color: red - ", startingColor.r, " green - ", startingColor.g, " blue - ", startingColor.b);
    writeln("Performing dfs at x: ", x, ", y: ", y);

    Tuple!(int, int)[] pts;
    pts ~= tuple(x, y);

    int[Tuple!(int, int)] visited;


    while (pts.length > 0) {
      writeln(pts.length);
      Tuple!(int, int) currentPoint = pts[pts.length - 1];
      pts = pts[0 .. pts.length - 1];

      int* hasBeenVisited = currentPoint in visited;
      if (currentPoint[0] > 0 && currentPoint[0] < 640 && currentPoint[1] > 0 && currentPoint[1] < 480 && hasBeenVisited is null) {
        if (isSameColor(startingColor, getPixelColorAt(currentPoint[0] + 1, currentPoint[1], surf.getSurface()))) {
          pts ~= tuple(currentPoint[0] + 1, currentPoint[1]);
        }
        if (isSameColor(startingColor, getPixelColorAt(currentPoint[0] - 1, currentPoint[1], surf.getSurface()))) {
          pts ~= tuple(currentPoint[0] - 1, currentPoint[1]);
        }
        if (isSameColor(startingColor, getPixelColorAt(currentPoint[0], currentPoint[1] + 1, surf.getSurface()))) {
          pts ~= tuple(currentPoint[0], currentPoint[1] + 1);
        }
        if (isSameColor(startingColor, getPixelColorAt(currentPoint[0], currentPoint[1] - 1, surf.getSurface()))) {
          pts ~= tuple(currentPoint[0], currentPoint[1] - 1);
        }
      }

      visited[currentPoint] = 1;
      surf.UpdateSurfacePixel(currentPoint[0], currentPoint[1], r, g, b);
    }
  }
}