import Point : Point;

class Stroke {

    Point[] constituentPoints;
    Point[] underlyingPoints;

    this() {}

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