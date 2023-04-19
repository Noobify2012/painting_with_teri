/***********************************
 * Author: Matthew Greene, Greene.Matthew@northeastern.edu
 * Date: February 7, 2023
 */

import std.stdio;
import std.container;
import std.range;
import std.conv;
import std.exception;
import core.exception;

/***********************************
    Name: Container 
    Description: Interface for a Deque data structure. Generally speaking we call these containers. Observe how this interface is a templated (i.e. Container(T)), where 'T' is a placeholder for a data type.
*/
interface Container(T){
    /// Element is on the front of collection
    void push_front(T x);

    /// Element is on the back of the collection
    void push_back(T x);

    /// Element is removed from front and returned
    /// assert size > 0 before operation
    T pop_front();

    /// Element is removed from back and returned
    /// assert size > 0 before operation
    T pop_back();

    /// Retrieve reference to element at position at index
    /// assert pos is between [0 .. $] and size > 0
    ref T at(size_t pos);

    /// Retrieve reference to element at back of position
    /// assert size > 0 before operation
    ref T back();

    /// Retrieve element at front of position
    /// assert size > 0 before operation
    ref T front();
    
    /// Retrieve number of elements currently in container
    size_t size();
}

/***********************************
    * Name: Deque 
    * Description: A Deque is a double-ended queue in which we can push and pop elements.
*/
class Deque(T) : Container!(T) {
    /// DLL here
    /// instance of list inside class
    /// Acknowledgement: Nidhi Satish Pai
    T[] s;
    auto frontI = -1;
    auto backI = -1;
    int sizeI = 0;
    auto isEmpty = true;


    /***********************************
    * Name: push_front 
    * Description: pushes an item to the front of the deque
    * Params:
    *    x = the item you want to push
    */
    override void push_front(T x) {
        ++s.length;
        /// initial case, nothing in the array 
        if (frontI == -1 && isEmpty == true) {
            isEmpty = false;
            frontI += 1;
        /// second case, where the front index is away from zero, push towards 0 
        } else if(frontI > 0) {
            s[frontI - 1] = x;
        /// final case, front index is zero bubble everything towards back and insert at front.
        } else {
            ///bubble all indexes up 1
            int temp = backI + 1;
            for ( int i = 0; i <= backI; i++) {
                s[temp - i] = s[backI - i];
            }
        }
        s[frontI] = x;
        backI += 1;
        sizeI += 1;
    }


    /***********************************
    * Name: push_back 
    * Description: pushes an item to the back of the deque
    * Params:
    *    x = the item you want to push
    */
    override void push_back(T x) {
        ++s.length;
        /// check if array is empty, reset indexes
        if (frontI == -1 && isEmpty == true) {
            isEmpty = false;
            frontI += 1;
        }
        s[backI + 1] = x;
        backI += 1;
        sizeI += 1;
    }

    /***********************************
    * Name: pop_front
    * Description:  removes and returns the element from the front of the Deque.
    * Returns: the item at the front of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override T pop_front() {
        assert(sizeI >= 0);
        /// Return thing at current front index
        T returnValFront = s[frontI];
        /// Non-empty case
        if (frontI != backI) {
            sizeI -= 1;
            frontI += 1;
            /// If deque is about to be empty, reset indexes and boolean
        } else {
            sizeI = 0;
            backI = -1;
            frontI = -1;
            isEmpty = true;
        }
        return returnValFront;
    }

    /***********************************
    * Name: pop_back
    * Description:  removes and returns the element from the back of the Deque.
    * Returns: the item at the back of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override T pop_back() {
        assert(sizeI >= 0);
        T returnVal = s[backI];
        /// Standard condition: front is greater than back, reduce front
        if (backI > 0 && backI > frontI) {
            backI -= 1;
        } else if (frontI == backI) {
            /// If there is only 1 element in the array and it is being popped, reset the deque
            frontI = -1;
            backI = -1;
            isEmpty = true;
        }
        sizeI -= 1;
        return returnVal;
    }

    /***********************************
    * Name: at
    * Description: Returns the element from the deque at the position given.
    * Params:
    *     pos = the integer position that the user is looking for
    * Returns: the item at the given index of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less or the position passed is out of bounds
    */
    override ref T at(size_t pos) {
        assert(sizeI > 0 && pos <= backI && pos >= frontI);
        T posVal = void;
        return s[pos];
    }

    /***********************************
    * Name: back
    * Description: Returns the element from the deque at the back.
    * Returns: the item at the back of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override ref T back() {
        /// assert size > 0 before operation
        assert(sizeI > 0);
        T retValBack;
        /// Retrieve reference to element at back of position
        return s[backI];
    }

    /***********************************
    * Name: front
    * Description: Returns the element from the deque at the front.
    * Returns: the item at the front of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override ref T front() {
        assert(sizeI > 0);
        T retValFront;
        return s[frontI];

    }

    /************************************
    * Name: size 
    * Description: Returns the size of the deque.
    * Returns: the size of the deque
    */
    override size_t size() {
        return sizeI;
    }
}