import Point : Point;
import std.typecons;


/***********************************
* Name: Stroke
* Descripton: This is an array of points that is used to create a smooth stroke. 
*/
class Stroke {

    Point[] constituentPoints;
    Point[] underlyingPoints;

    /***********************************
    * Name: constructor
    * Description: default constructor 
    */
    this() {}

    /***********************************
    * Name: Destructor
    * Description: default destructor 
    */
    ~this() {}

    /**
    *   Returns all points that constitute a stroke as an array of Points.
    *
    *   return: array of Points
    */
    Point[] getConstituentPoints() {

        return this.constituentPoints;
    }

    /**
    *   Returns all points that originally occupied the space this Stroke has
    *   drawn over.
    *
    *   return: array of Points
    */
    Point[] getUnderlyingPoints() {

        return this.underlyingPoints;
    }
}