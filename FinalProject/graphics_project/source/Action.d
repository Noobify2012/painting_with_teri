
import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;



/***********************************
* Name: Action
* Descripton: stores prior actions for undo/redo deque
*/
class Action {
    ///Tuple: points passed
    Tuple!(int, int)[] points;
    ///Color: RGB color 
    int[] color;
    ///ActionType for the action passed
    string actionType;

    /***********************************
    * Name: constructor
    * Description: Takes your points, color, and actiontype to build an action  
    * Params:
    *    _points = the points that begin and end your action
    *    _color = the color your action is 
    *    _actionType = what you are doing, ex. shape, line, etc.  
    */
    this(Tuple!(int, int)[] _points, int[] _color, string _actionType) {
        this.points = _points;
        this.color = _color;
        this.actionType = _actionType;
    }

    /***********************************
    * Name: getPoints
    * Description: getter function for testing/checking. 
    * Returns: The points that the action is referencing. 
    */
    Tuple!(int, int)[] getPoints() {
        writeln("made it here");
        return this.points;
    }

    /***********************************
    * Name: getColor
    * Description: getter function for testing/checking. 
    * Returns: The color that the action is created in . 
    */
    int[] getColor() {

        return this.color;
    }

    /***********************************
    * Name: setColor
    * Description: setter function for action color
    * Params: 
    *     newColor = color you want to set that action to 
    */
    void setColor(int[] newColor) {

        this.color = newColor;
    }

    /***********************************
    * Name: getActionType 
    * Description: getter function for testing/checking. 
    * Returns: The type of action (line, rectangle, circle, etc). 
    */
    string getActionType() {

        return this.actionType;
    }

    /***********************************
    * Name: addPoint
    * Description: getter function for testing/checking. 
    * Params:  
    *    pt = the point that you want to add to the action 
    */
    void addPoint(Tuple!(int, int) pt) {

        this.points ~= pt;
    }
}