import std.algorithm;
import std.math.rounding;
import std.math.algebraic;

import Point : Point;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

import drawing_utilities;

class Stroke {

    Point[] constituentPoints;
    Point[] underlyingPoints;
    Surface *surface;
    DrawingUtility du;

    this(Surface *surf) {
        this.surface = surf;
        this.du = new DrawingUtility();
    }

    ~this() {}

    /**
    *   Returns all points that constitute a stroke as an array of Points.
    *
    *   return: array of points
    */
    Point[] getConstituentPoints() {

        return this.constituentPoints;
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
            for(int h=-brushSize; h < brushSize; h++) {
                this.underlyingPoints ~= new Point(x + w, y + h, this.du.getPixelColorAt(x + w, y + h, this.surface.getSurface()));
                this.surface.UpdateSurfacePixel(x + w, y + h, redVal, greenVal, blueVal);
                this.constituentPoints ~= new Point(x + w, y + h, this.du.getPixelColorAt(x + w, y + h, this.surface.getSurface()));
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
}