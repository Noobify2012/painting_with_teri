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

/**
    The following is an interface for a Deque data structure.
    Generally speaking we call these containers.
    
    Observe how this interface is a templated (i.e. Container(T)),
    where 'T' is a placeholder for a data type.
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

/**
    *A Deque is a double-ended queue in which we can push and
    *pop elements.
    
    *Note: Remember we could implement Deque as either a class or
     *     a struct depending on how we want to extend or use it.
      *    Either is fine for this assignment.
*/
class Deque(T) : Container!(T) {
    ///DLL here
    ///instance of list inside class
    ///nidhi satish pai
    T[] s;
    auto frontI = -1;
    auto backI = -1;
    int sizeI = 0;
    auto isEmpty = true;


    /***********************************
    * This is the push front method.
    * Params:
    *       X=  a generic data type that is pushed into the deque on the front of the deque.
    */

    override void push_front(T x) {
        ++s.length;
    /**    initial case, nothing in the array */
        if (frontI == -1 && isEmpty == true) {
            isEmpty = false;
            frontI += 1;
    /**         second case, where the front index is away from zero, push towards 0 */
        } else if(frontI > 0) {
            s[frontI - 1] = x;
    /**     final case, front index is zero bubble everything towards back and insert at front. */
        } else {
    /**     bubble all indexes up 1 */
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
        * This is the push back method.
        * Params:
        *       X=  a generic data type that is pushed into the deque on the back of the deque.
        */

    override void push_back(T x) {
        ++s.length;
    /** check if array is empty, reset indexes*/
        if (frontI == -1 && isEmpty == true) {
            isEmpty = false;
            frontI += 1;
        }
        s[backI + 1] = x;
        backI += 1;
        sizeI += 1;
    }

    /***********************************
    * This is the pop front method the removes and return the element from the front of the Deque.
    * Returns: the item at the front of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override T pop_front() {
        assert(sizeI >= 0);
        ///return thing at current front index
        T returnValFront = s[frontI];
        ///non-empty case
        if (frontI != backI) {
            sizeI -= 1;
            frontI += 1;
            ///if deque is about to be empty, reset indexes and boolean
        } else {
            sizeI = 0;
            backI = -1;
            frontI = -1;
            isEmpty = true;
        }
        return returnValFront;
    }

    /***********************************
    * This is the pop front method the removes and return the element from the back of the Deque.
    * Returns: the item at the back of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override T pop_back() {
        assert(sizeI >= 0);
        T returnVal = s[backI];
        ///standard condition: front is greater than back, reduce front
        if (backI > 0 && backI > frontI) {
            backI -= 1;
        } else if (frontI == backI) {
            /// if there is only 1 element in the array and it is being popped, reset the deque
            frontI = -1;
            backI = -1;
            isEmpty = true;
        }
        sizeI -= 1;
        return returnVal;
    }

    /***********************************
    * This is the retrieve at method that returns the element from the deque at the position given.
    * Params:
    *       pos= the integer position that the user is looking for
    * Returns: the item at the given index of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less or the position passed is out of bounds
    */
    override ref T at(size_t pos) {
        assert(sizeI > 0 && pos <= backI && pos >= frontI);
        T posVal = void;
        return s[pos];
    }

/***********************************
    * This is the back method that returns the element from the deque at the back.
    * Returns: the item at the back of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    /// Retrieve reference to element at back of position
    /// assert size > 0 before operation
    override ref T back() {
        assert(sizeI > 0);
        T retValBack;
        return s[backI];
    }

    /***********************************
    * This is the front method that returns the element from the deque at the front.
    * Returns: the item at the front of the Deque
    * Throws: AssertException if the size of the Deque is 0 or less
    */
    override ref T front() {
        assert(sizeI > 0);
        T retValFront;
        return s[frontI];

    }
    /***********************************
    * This is the size method that returns the size of the deque.
    * Returns: the size of the deque
    */
    override size_t size() {
        return sizeI;
    }

}

/// An example unit test that you may consider.
/// Try writing more unit tests in separate blocks
/// and use different data types.
///Testing: push_front, size, pop_front all with only 1 operation
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_front(1);
    auto sizeP = myDeque.size();
    assert(sizeP == 1);
    auto element = myDeque.pop_front();
    assert(element == 1);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 0);
    writeln("END of first test\n");
}
///
///Testing: push_back, size, pop_back all with only 1 operation
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    auto sizeP = myDeque.size();
    assert(sizeP == 1);
    auto element = myDeque.pop_back();
    assert(element == 1);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 0);
    writeln("END of second test\n");
}
///
///Testing: push_front x 2, size, pop_front x2 all with only 1 operation
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_front(1);
    myDeque.push_front(2);
    auto sizeP = myDeque.size();
    assert(sizeP == 2);
    auto element = myDeque.pop_front();
    assert(element == 2);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 1);
    auto element2 = myDeque.pop_front();
    assert(element2 == 1);
    auto sizeEl2 = myDeque.size();
    assert(sizeEl2 == 0);
    writeln("END of third test\n");
}
///
///Testing: push_back, size, pop_front
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    auto backEL = myDeque.front();
    auto sizeP = myDeque.size();
    assert(sizeP == 1);
    auto element = myDeque.pop_front();
    assert(element == 1);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 0);
    writeln("END of fourth test\n");
}
///
///Testing: push_front x2, size, pop_back x2
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_front(1);
    myDeque.push_front(2);
    auto backEL = myDeque.front();
    auto sizeP = myDeque.size();
    assert(sizeP == 2);
    auto element = myDeque.pop_back();
    assert(element == 1);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 1);
    auto element2 = myDeque.pop_back();
    assert(element2 == 2);
    auto sizeEl2 = myDeque.size();
    assert(sizeEl2 == 0);
    writeln("END of fifth test\n");
}
///
///Testing: push_back, push_back, size, pop_back
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    myDeque.push_back(2);
    auto sizeP = myDeque.size();
    assert(sizeP == 2);
    auto element = myDeque.pop_back();
    assert(element == 2);
    auto sizeEl = myDeque.size();
    assert(sizeEl == 1);
    writeln("END of sixth test\n");
}
///
///Testing: push_front, get front
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_front(1);
    auto element = myDeque.front();
    assert(element == 1);
    writeln("END of seventh test\n");
}

///Testing: push_back, get back
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    auto element = myDeque.back();
    assert(element == 1);
    writeln("END of eighth test\n");
}

///Testing: push_back, push_back, get at index 0 and get at index 1
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    myDeque.push_back(2);
    auto element = myDeque.at(0);
    assert(element == 1);
    auto element2 = myDeque.at(1);
    assert(element2 == 2);
    writeln("END of ninth test\n");
}
///Testing: push_back x 6, check size
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    myDeque.push_back(1);
    myDeque.push_back(2);
    myDeque.push_back(1);
    myDeque.push_back(2);
    myDeque.push_back(1);
    myDeque.push_back(2);
    auto element = myDeque.size();
    assert(element == 6);
    auto element2 = myDeque.at(1);
    assert(element2 == 2);
    writeln("END of tenth test\n");
}

///Testing: check all assertian errors
///Status: Passed
unittest{
    auto myDeque = new Deque!(int);
    assertThrown!AssertError(myDeque.pop_back());
    assertThrown!AssertError(myDeque.pop_front());
    assertThrown!AssertError(myDeque.front());
    assertThrown!AssertError(myDeque.back());
    assertThrown!AssertError(myDeque.at(23));
    writeln("END of eleventh test\n");
}


// void main(){
//     /// No need for a 'main', use the unit test feature.
//     /// Note: The D Compiler can generate a 'main' for us automatically
//     ///       if we are just unit testing, and we'll look at that feature
//     ///       later on in the course.
// }
