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

 
    /***********************************
    * Name: getConstituentPoints 
    * Description: Get the array of points that constitute a stroke  
    * Returns: array of points in stroke
    */
    Point[] getConstituentPoints() {

        return this.constituentPoints;
    }

    /***********************************
    * Name: getUnderlyingPoints 
    * Description: Returns all points that originally occupied the space this stroke has drawn over.
    * Returns: array of underlying points 
    */
    Point[] getUnderlyingPoints() {

        return this.underlyingPoints;
    }
}