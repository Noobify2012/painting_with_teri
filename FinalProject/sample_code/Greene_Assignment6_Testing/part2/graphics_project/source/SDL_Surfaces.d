import std.stdio;
import std.string;

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

}


