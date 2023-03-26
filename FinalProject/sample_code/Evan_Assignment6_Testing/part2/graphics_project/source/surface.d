// Import D standard libraries
import std.stdio;
import std.string;
import std.math;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class Surface {

  private {
    SDL_Surface* imgSurface;
  }

  this(int width, int height) {
    imgSurface = SDL_CreateRGBSurface(0,width,height,32,0,0,0,0);
  }

  ~this() {
    SDL_FreeSurface(imgSurface);
    writeln("SDL Surface has been destroyed");
  }

  SDL_Color getPixelColorAt(int x, int y) {

    assert((x >= 0 && x <= 640) && (y >= 0 && y <= 480));

    // When we modify pixels, we need to lock the surface first
    SDL_LockSurface(this.imgSurface);
    // Make sure to unlock the surface when we are done.
    scope(exit) SDL_UnlockSurface(this.imgSurface);

    ubyte* pixelArray = cast(ubyte*) imgSurface.pixels;
    Uint8* currentPixel = cast(Uint8*) &pixelArray[y * imgSurface.pitch + x * imgSurface.format.BytesPerPixel];

    Uint32 pixelData = * cast(Uint32*)currentPixel;

    SDL_Color color = {0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE};

    SDL_GetRGB(pixelData, imgSurface.format, &color.r, &color.g, &color.b);

    return color;
  }

  int getSurfaceWidth() {
    return imgSurface.w;
  }

  int getSurfaceHeight() {
    return imgSurface.h;
  }

  void changePixelColor(int xPos, int yPos, ubyte b, ubyte g, ubyte r) {

    // When we modify pixels, we need to lock the surface first
    SDL_LockSurface(this.imgSurface);
    // Make sure to unlock the surface when we are done.
    scope(exit) SDL_UnlockSurface(this.imgSurface);

    // Retrieve the pixel arraay that we want to modify
    ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
    // Change the 'blue' component of the pixels
    pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = b;
    // Change the 'green' component of the pixels
    pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = g;
    // Change the 'red' component of the pixels
    pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = r;
  }

  void UpdateSurfacePixel(int xPos, int yPos) {

    // Set color used in the original implementation
    ubyte red = 32;
    ubyte green = 128;
    ubyte blue = 255; 

    changePixelColor(xPos, yPos, blue, green, red);
  }

  void blit(SDL_Window* window) {
    SDL_BlitSurface(this.imgSurface,null,SDL_GetWindowSurface(window),null);
  }

  void linearInterpolation(int x1, int y1, int x2, int y2, int brushSize) {

    if (x1 == x2 && y1 == y2) {
      return;
    }

    int rise = y2 - y1, run = x2 - x1, adjustedRise, adjustedRun;
    float slope;

    if (run != 0) {
      slope = cast(float) rise / cast(float) run;
    } else {
      adjustedRun = 0;
      if (rise < 0) {
        adjustedRise = -1;
      } else if (rise > 0) {
        adjustedRise = 1;
      }
    }

    if (rise == 0) {
      adjustedRise = 0;
      if (run < 0) {
        adjustedRun = -1;
      } else if (run > 0) {
        adjustedRun = 1;
      }
    }

    if (run != 0 && rise != 0) {
      adjustedRise = cast(int) round(slope);
      adjustedRun = 1;
      if (rise < 0) {
        if (adjustedRise > 0) {
          adjustedRise *= -1;
        }
      } else if (rise > 0) {
        if (adjustedRise < 0) {
          adjustedRise *= -1;
        }
      }
      if (run < 0) {
        if (adjustedRun > 0) {
          adjustedRun *= -1;
        }
      }
    }

    while (adjustedRun > 0) {
      ++x1;
      --adjustedRun;
      for(int w=-brushSize; w < brushSize; w++){
        for(int h=-brushSize; h < brushSize; h++){
          UpdateSurfacePixel(x1 + w, y1 + h);
        }
      }
    }

    while (adjustedRun < 0) {
      --x1;
      ++adjustedRun;
      for(int w=-brushSize; w < brushSize; w++){
        for(int h=-brushSize; h < brushSize; h++){
          UpdateSurfacePixel(x1 + w, y1 + h);
        }
      }
    }

    while (adjustedRise > 0) {
      ++y1;
      --adjustedRise;
      for(int w=-brushSize; w < brushSize; w++){
        for(int h=-brushSize; h < brushSize; h++){
          UpdateSurfacePixel(x1 + w, y1 + h);
        }
      }
    }

    while (adjustedRise < 0) {
      --y1;
      ++adjustedRise;
      for(int w=-brushSize; w < brushSize; w++){
        for(int h=-brushSize; h < brushSize; h++){
          UpdateSurfacePixel(x1 + w, y1 + h);
        }
      }
    }

    linearInterpolation(x1, y1, x2, y2, brushSize);

  }

}

@("Test background is black on load")
unittest {
  Surface s = new Surface(640, 480);

  import std.Random;
  auto rnd = Random(unpredictableSeed);

  int i = 100;
  while (i) {
    auto x = uniform(0, 640, rnd);
    auto y = uniform(0, 480, rnd);

    SDL_Color c = s.getPixelColorAt(x, y);
    assert(c.r == 0 && c.g == 0 && c.b == 0);

    --i;
  }
}

@("Test that pixel color can be changed")
unittest {
  Surface s = new Surface(640, 480);

  import std.Random;
  auto rnd = Random(unpredictableSeed);

  auto x = uniform(0, 640, rnd);
  auto y = uniform(0, 480, rnd);
  auto r = cast(ubyte) uniform(0, 255, rnd);
  auto g = cast(ubyte) uniform(0, 255, rnd);
  auto b = cast(ubyte) uniform(0, 255, rnd);

  s.changePixelColor(x, y, b, g, r);
  SDL_Color c = s.getPixelColorAt(x, y);
  assert(c.r == r && c.g == g && c.b == b);
}

@("Test that pixels outside of the surface area are inaccessable")
unittest {
  Surface s = new Surface(640, 480);

  bool passed1 = false;
  bool passed2 = false;

  try {
    s.getPixelColorAt(-1, 200);
  } catch(Error e) {
    passed1 = true;
  }

  try {
    s.getPixelColorAt(200, 500);
  } catch(Error e) {
    passed2 = true;
  }

  assert(passed1 && passed2);
}

@("Test dimensions of surface")
unittest {
  Surface s = new Surface(640, 480);

  assert(s.getSurfaceWidth == 640 && s.getSurfaceHeight == 480);
}