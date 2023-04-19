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

    /***********************************
    * Name: GetSurface 
    * Description: gets the surface created
    * Returns: created surface
    */
    SDL_Surface* getSurface() {
        return imgSurface;
    }

    /***********************************
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

    /***********************************
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

    /***********************************
    * Name: Lerp
    * Description: Perform linear interpolation between two points.
    * Linear interpolation infers all points between two given points such that a line can be drawn between the two given points. Each point in the line will be filled at the stated  brush size and color.
    * Params:
        * x1 = x coordinate of the first point
        * y1 = y coordinate of the first point
        * x2 = x coordinate of the second point
        * y2 = y coordinate of the second point
        * brushSize = the height and width of each point in the interpolated line
        * redVal = red value on rgb scale
        * greenVal = green value on rgb scale
        * blueVal = blue value on rgb scale
        
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

    /***********************************
    * Name: GetNumPoints 
    * Description: Determine number of points needed for linear interpolation.
    * To perform linear interpolation between two points, and minimum number of points are needed
    * to form a continuous line. This number of points is the larger between the vertical distance
    * of the two points and the horizontal distance between the two points.
    * Params:
        * x1 = point 1 x-coordinate
        * y1 = point 1 y-coordinate 
        * x2 = point 2 x-coordinate
        * y2 = point 2 y-coordinate
    * Returns: tuple of distance between x values and y values
    */
    int getNumPoints(int x1, int y1, int x2, int y2) {
        return max(abs(x2 - x1), abs(y2 - y1));
    }

    /***********************************
    * Name: DrawLerpPoint 
    * Description: Draws an interpolated point between two actual points.
    * An interpolated point is found by calling lerpHelper to estimate an x coordinate and a y coordinate.
    * The point is colored according to the color parameters and at the specified brush size.
    * Params: 
        * x1 = point 1 x-coordinate
        * y1 = point 1 y-coordinate 
        * x2 = point 2 x-coordinate
        * y2 = point 2 y-coordinate
        * brushSize = size of the paintbrush
        * t =  fraction of line already drawn, from lerpHelper 
        * redVal = rgb red values of line 
        * greenVal = rgb green values of line 
        * blueVal = rgb blue values of line 
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

    /***********************************
    * Name: LerpHelper 
    * Description: Determine the value of interpolation.
    * Given a start and end value, determines the next interpolated value based on the fraction of the line that has already been drawn.
    * Params: 
        * start = start of the interpolation
        * end = end of the interpolation
        * t = fraction of the line that has been draw 
    * Returns: Float value of the next interpolated value point based on what has been drawn. 
    */
    float lerpHelper(int start, int end, float t) {
        return start * (1.0 - t) + end * t;
    }


}


/***********************************
* Test: Checks for the surface to be initialized to black, draws horizontal line
* and checks that intervening points have changed color
*/
@("Lerp test - horizontal line")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.lerp(1, 1, 3, 1, 1, 255, 128, 32);
    /// Parse values of new data struct
    assert(	s.PixelAt(2,1)[0] == 255 &&
    s.PixelAt(2,1)[1] == 128 &&
    s.PixelAt(2,1)[2] == 32, "error rgb value at x,y is wrong!");
}


/**
* Test: Checks for the surface to be initialized to black, draws diagonal line
* and checks that intervening points have changed color
*/
@("Lerp test - diagonal line")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    /// Draw diagonal line and make sure the change takes
    s.lerp(1, 1, 3, 3, 1, 32, 128, 255);
    /// Parse values of new data struct
    assert(	s.PixelAt(2,2)[0] == 32 &&
    s.PixelAt(2,2)[1] == 128 &&
    s.PixelAt(2,2)[2] == 255, "error rgb value at x,y is wrong!");
    /// Other pixels should have changed as well bc of how UpdatePixel is implemented
    assert(	s.PixelAt(0,0)[0] == 32 &&
    s.PixelAt(0,0)[1] == 128 &&
    s.PixelAt(0,0)[2] == 255, "error rgb value at x,y is wrong!");
    assert(	s.PixelAt(0,1)[0] == 32 &&
    s.PixelAt(0,1)[1] == 128 &&
    s.PixelAt(0,1)[2] == 255, "error rgb value at x,y is wrong!");
    assert(	s.PixelAt(3,2)[0] == 32 &&
    s.PixelAt(3,2)[1] == 128 &&
    s.PixelAt(3,2)[2] == 255, "error rgb value at x,y is wrong!");
    assert(	s.PixelAt(0,2)[0] == 0 &&
    s.PixelAt(0,2)[1] == 0 &&
    s.PixelAt(0,2)[2] == 0, "error rgb value at (1,2) is wrong!");
    assert(	s.PixelAt(4,3)[0] == 0 &&
    s.PixelAt(4,3)[1] == 0 &&
    s.PixelAt(4,3)[2] == 0, "error rgb value at (1,2) is wrong!");
}