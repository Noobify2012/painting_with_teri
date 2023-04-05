import std.stdio;
import std.string;
import std.math;
import std.algorithm;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class Surface{
    uint flags;
    int width;
    int height;
    int depth;
    uint Rmask;
    uint Gmask;
    uint Bmask;
    uint Amask;
    SDL_Surface* imgSurface;

    this(uint flags, int width, int height, int depth,
        uint Rmask, uint Gmask, uint Bmask, uint Amask) {
        this.flags = flags;
        this.width = width;
        this.height = height;
        this.depth = depth;
        this.Rmask = Rmask;
        this.Gmask = Gmask;
        this.Bmask = Bmask;
        this.Amask = Amask;
        imgSurface = SDL_CreateRGBSurface(flags, width, height, depth,
            Rmask, Gmask, Bmask, Amask);

    }
    ~this(){
        // Free a surface...
        scope(exit) {
            SDL_FreeSurface(imgSurface);
        }
    }

    SDL_Surface* getSurface() {
        return imgSurface;
    }


    void UpdateSurfacePixel(int xPos, int yPos, ubyte blueVal, ubyte greenVal, ubyte redVal){
        // When we modify pixels, we need to lock the surface first
        SDL_LockSurface(imgSurface);
        // Make sure to unlock the surface when we are done.
        scope(exit) SDL_UnlockSurface(imgSurface);
        // Retrieve the pixel arraay that we want to modify
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        // Change the 'blue' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = blueVal;
        // Change the 'green' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = greenVal;
        // Change the 'red' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = redVal;
    }

    //int array for fetching the colors of a pixel
    int[3] colors;
    //method for getting the RGB values of the pixel passed in
    int[] PixelAt(int xPos, int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int index = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        int blue = pixelArray[index + 0];
        int green = pixelArray[index + 1];
        int red = pixelArray[index + 2];
        colors = [blue, green, red];
        return colors;

    }

    /// https://www.redblobgames.com/grids/line-drawing.html
    void lerp(int x1, int y1, int x2, int y2, int brushSize, ubyte red, ubyte green, ubyte blue) {
        
        int numPoints = getNumPoints(x1, y1, x2, y2);
        for (int i = 0; i <= numPoints; ++i) {
            float t = 0.0f;
            if (numPoints > 0) {
                t = cast(float) i / cast(float) numPoints;
            }
            drawLerpPoint(x1, y1, x2, y2, t, brushSize, red, green, blue);
        }
    }

    int getNumPoints(int x1, int y1, int x2, int y2) {
        return max(abs(x2 - x1), abs(y2 - y1));
    }

    void drawLerpPoint(int x1, int y1, int x2, int y2, float t, int brushSize, ubyte red, ubyte green, ubyte blue) {
        int x = cast(int) round(lerpHelper(x1, x2, t));
        int y = cast(int) round(lerpHelper(y1, y2, t));
        for(int w=-brushSize; w < brushSize; w++){
            for(int h=-brushSize; h < brushSize; h++){
                UpdateSurfacePixel(x + w, y + h, red, green, blue);
            }
        }
    }

    float lerpHelper(int start, int end, float t) {
        return start * (1.0 - t) + end * t;
    }

    void linearInterpolation(int x1, int y1, int x2, int y2, int brushSize, ubyte red, ubyte green, ubyte blue) {

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
                    UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
                }
            }
        }

        while (adjustedRun < 0) {
            --x1;
            ++adjustedRun;
            for(int w=-brushSize; w < brushSize; w++){
                for(int h=-brushSize; h < brushSize; h++){
                    UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
                }
            }
        }

        while (adjustedRise > 0) {
            ++y1;
            --adjustedRise;
            for(int w=-brushSize; w < brushSize; w++){
                for(int h=-brushSize; h < brushSize; h++){
                    UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
                }
            }
        }

        while (adjustedRise < 0) {
            --y1;
            ++adjustedRise;
            for(int w=-brushSize; w < brushSize; w++){
                for(int h=-brushSize; h < brushSize; h++){
                    UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
                }
            }
        }

        linearInterpolation(x1, y1, x2, y2, brushSize, red, green, blue);

    }


}


