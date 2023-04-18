import std.stdio;
import std.string;
import std.math;
import std.algorithm;

import SDL_Initial :SDLInit;

/// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;


/**
* Name: Surface 
* Description: Surface class creates an SDL surface on which to draw and includes drawing methods
*/

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

    /**
    * Name: Surface Constructor 
    * Description: constructs surface of given size and color
    * Params: 
        * flags = SLD flags,
        * width = width, 
        * height = height,
        * depth = surface width, height, and depth, 
        * Rmask = red,
        * Gmask = green, 
        * Bmask = blue, 
        * Amask = red, green, blue, and alpha mask for pixels
    */
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
        /// Free a surface...
        scope(exit) {
            SDL_FreeSurface(imgSurface);
        }
    }

    /**
    * Name: GetSurface 
    * Description: gets the surface created
    * Returns: created surface
    */
    SDL_Surface* getSurface() {
        return imgSurface;
    }

    /**
    * Name: UpdateSurfacePixel 
    * Description: Changes color of selected pixel
    * Params:    
        * xPos = x-coordinate of pixel, 
        * yPos = y-coordinate of pixel
        * blueVal = rgb blue value, 
        * greenVal = rgb green value, 
        * redVal = rgb red value
    * Changes pixel color at xPos, yPos
    */
    void UpdateSurfacePixel(int xPos, int yPos, ubyte blueVal, ubyte greenVal, ubyte redVal){
        /// When we modify pixels, we need to lock the surface first
        SDL_LockSurface(imgSurface);
        /// Make sure to unlock the surface when we are done.
        scope(exit) SDL_UnlockSurface(imgSurface);
        /// Retrieve the pixel arraay that we want to modify
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        /// Change the 'blue' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = blueVal;
        /// Change the 'green' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = greenVal;
        /// Change the 'red' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = redVal;
    }

    /// Int array for fetching the colors of a pixel
    int[3] colors;

    /**
    * Name: PixelAt 
    * Description: Method for getting the RGB values of the pixel passed in
    * Returns: array of rgb values for given pixel
    */
    int[] PixelAt(int xPos, int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int index = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        int blue = pixelArray[index + 0];
        int green = pixelArray[index + 1];
        int red = pixelArray[index + 2];
        colors = [blue, green, red];
        return colors;

    }

    /**
    * Name: Lerp
    * Description: Perform linear interpolation between two points.
    * Linear interpolation infers all points between two given points such that a line can be
    * drawn between the two given points. Each point in the line will be filled at the stated 
    * brush size and color.
    * Params:
        * @param x1 - x coordinate of the first point
        * @param y1 - y coordinate of the first point
        * @param x2 - x coordinate of the second point
        * @param y2 - y coordinate of the second point
        * @param brushSize - the height and width of each point in the interpolated line
        * @param red - red value on rgb scale
        * @param green - green value on rgb scale
        * @param blue - blue value on rgb scale
        
    Reference: https://www.redblobgames.com/grids/line-drawing.html
    */
    void lerp(int x1, int y1, int x2, int y2, int brushSize, ubyte redVal, ubyte greenVal, ubyte blueVal) {
        
        int numPoints = getNumPoints(x1, y1, x2, y2);
        for (int i = 0; i <= numPoints; ++i) {
            float t = 0.0f;
            if (numPoints > 0) {
                t = cast(float) i / cast(float) numPoints;
            }
            drawLerpPoint(x1, y1, x2, y2, t, brushSize, redVal, greenVal, blueVal);
        }
    }

    /**
    * Name: GetNumPoints 
    * Description: Determine number of points needed for linear interpolation.
    * To perform linear interpolation between two points, and minimum number of points are needed
    * to form a continuous line. This number of points is the larger between the vertical distance
    * of the two points and the horizontal distance between the two points.
    * Params:
        * @param x1, y1, x2, y2: x and y coords of point1 and point2
    Returns: tuple of distance between x values and y values
    */
    int getNumPoints(int x1, int y1, int x2, int y2) {
        return max(abs(x2 - x1), abs(y2 - y1));
    }

    /**
    * Name: DrawLerpPoint 
    * Description: Draws an interpolated point between two actual points.
    * An interpolated point is found by calling lerpHelper to estimate an x coordinate and a y coordinate.
    * The point is colored according to the color parameters and at the specified brush size.
    * Params: 
        * @param x1, y1, x2, y2: x and y coordinates of start and end points
        * @param brushSize: size of the paintbrush
        * @param t: TODO what is this?
        * @param redVal, greenVal, blueVal: rgb values of line 
    */
    void drawLerpPoint(int x1, int y1, int x2, int y2, float t, int brushSize, ubyte redVal, ubyte greenVal, ubyte blueVal) {
        int x = cast(int) round(lerpHelper(x1, x2, t));
        int y = cast(int) round(lerpHelper(y1, y2, t));
        for(int w=-brushSize; w < brushSize; w++){
            for(int h=-brushSize; h < brushSize; h++){
                UpdateSurfacePixel(x + w, y + h, redVal, greenVal, blueVal);
            }
        }
    }

    /**
    * Name: LerpHelper 
    * Description: Determine the value of interpolation.
    * Given a start and end value, determines the next interpolated value based on the fraction of the line that has
    * already been drawn.
    * Params: 
        * @param start - start of the interpolation
        * @param end - end of the interpolation
        * @param t - fraction of the line that has been draw 
    */
    float lerpHelper(int start, int end, float t) {
        return start * (1.0 - t) + end * t;
    }

    // void linearInterpolation(int x1, int y1, int x2, int y2, int brushSize, ubyte red, ubyte green, ubyte blue) {

    //     if (x1 == x2 && y1 == y2) {
    //         return;
    //     }

    //     int rise = y2 - y1, run = x2 - x1, adjustedRise, adjustedRun;
    //     float slope;

    //     if (run != 0) {
    //         slope = cast(float) rise / cast(float) run;
    //     } else {
    //         adjustedRun = 0;
    //         if (rise < 0) {
    //             adjustedRise = -1;
    //         } else if (rise > 0) {
    //             adjustedRise = 1;
    //         }
    //     }

    //     if (rise == 0) {
    //         adjustedRise = 0;
    //         if (run < 0) {
    //             adjustedRun = -1;
    //         } else if (run > 0) {
    //             adjustedRun = 1;
    //         }
    //     }

    //     if (run != 0 && rise != 0) {
    //         adjustedRise = cast(int) round(slope);
    //         adjustedRun = 1;
    //         if (rise < 0) {
    //             if (adjustedRise > 0) {
    //                 adjustedRise *= -1;
    //             }
    //         } else if (rise > 0) {
    //             if (adjustedRise < 0) {
    //                 adjustedRise *= -1;
    //             }
    //         }
    //         if (run < 0) {
    //             if (adjustedRun > 0) {
    //                 adjustedRun *= -1;
    //             }
    //         }
    //     }

    //     while (adjustedRun > 0) {
    //         ++x1;
    //         --adjustedRun;
    //         for(int w=-brushSize; w < brushSize; w++){
    //             for(int h=-brushSize; h < brushSize; h++){
    //                 UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
    //             }
    //         }
    //     }

    //     while (adjustedRun < 0) {
    //         --x1;
    //         ++adjustedRun;
    //         for(int w=-brushSize; w < brushSize; w++){
    //             for(int h=-brushSize; h < brushSize; h++){
    //                 UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
    //             }
    //         }
    //     }

    //     while (adjustedRise > 0) {
    //         ++y1;
    //         --adjustedRise;
    //         for(int w=-brushSize; w < brushSize; w++){
    //             for(int h=-brushSize; h < brushSize; h++){
    //                 UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
    //             }
    //         }
    //     }

    //     while (adjustedRise < 0) {
    //         --y1;
    //         ++adjustedRise;
    //         for(int w=-brushSize; w < brushSize; w++){
    //             for(int h=-brushSize; h < brushSize; h++){
    //                 UpdateSurfacePixel(x1 + w, y1 + h, red, green, blue);
    //             }
    //         }
    //     }

    //     linearInterpolation(x1, y1, x2, y2, brushSize, red, green, blue);

    // }


}


/**
* Test: Checks for the surface to be initialized to black, change the pixel color of 1,1 to blue, verify its blue,
* change it to red, ensure that the color of 1,1 is now red 
*/
@("Lerp test - straight line")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.lerp(1, 1, 3, 1, 1, 255, 128, 32);
    /// Parse values of new data struct
    assert(	s.PixelAt(2,1)[0] == 255 &&
    s.PixelAt(2,1)[1] == 128 &&
    s.PixelAt(2,1)[2] == 32, "error rgb value at x,y is wrong!");
    /// Change the color of the pixel and make sure the change takes
    s.lerp(1, 1, 3, 3, 1, 32, 128, 255);
    /// Parse values of new data struct
    assert(	s.PixelAt(2,2)[0] == 32 &&
    s.PixelAt(2,2)[1] == 128 &&
    s.PixelAt(2,2)[2] == 255, "error rgb value at x,y is wrong!");
    /// Parse values of new data struct
    writeln("[0,0]", s.PixelAt(0,0));
    writeln(s.PixelAt(1,0));
    writeln(s.PixelAt(2,0));
    writeln(s.PixelAt(3,0));
    writeln("[0,1]", s.PixelAt(0,1));
    writeln(s.PixelAt(1,1));
    writeln(s.PixelAt(2,1));
    writeln(s.PixelAt(3,1));
    writeln(s.PixelAt(4,1));
    writeln("[0,2]", s.PixelAt(0,2));
    writeln(s.PixelAt(1,2));
    writeln(s.PixelAt(2,2));
    writeln(s.PixelAt(3,2));
    writeln(s.PixelAt(4,2));
    writeln("[0,3]", s.PixelAt(0,3));
    writeln(s.PixelAt(1,3));
    writeln(s.PixelAt(2,3));
    writeln(s.PixelAt(3,3));
    writeln(s.PixelAt(4,3));
    writeln("[0,4]", s.PixelAt(0,4));
    writeln(s.PixelAt(1,4));
    writeln(s.PixelAt(2,4));
    writeln(s.PixelAt(3,4));
    writeln(s.PixelAt(4,4));
    assert(	s.PixelAt(1,2)[0] == 0 &&
    s.PixelAt(1,2)[1] == 0 &&
    s.PixelAt(1,2)[2] == 0, "error rgb value at (1,2) is wrong!");
}