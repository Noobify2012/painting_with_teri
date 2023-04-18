
import std.stdio;
import std.typecons;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

class Action {

    Tuple!(int, int)[] points;
    int[] color;
    string actionType;

    this(Tuple!(int, int)[] _points, int[] _color, string _actionType) {
        
        this.actionType = _actionType;
        this.points = _points;
        this.color = _color;
    }

    Tuple!(int, int)[] getPoints() {
        writeln("made it here");
        return this.points;
    }

    int[] getColor() {

        return this.color;
    }

    void setColor(int[] newColor) {

        this.color = newColor;
    }

    string getActionType() {

        return this.actionType;
    }

    void addPoint(Tuple!(int, int) pt) {

        this.points ~= pt;
    }

	/** 
	* Name: GetPacketAsBytes
	* Description: Purpose of this function is to pack a bunch of
	*	bytes into an array for 'serialization' or otherwise
	*	ability to send back and forth across a server, or for
	*	otherwise saving to disk.	
	* Returns: Payload, packet with bytes of color data for each pixel TODO: confirm
	*/
    char[Action.sizeof] GetPacketAsBytes(){
        byte[4] s;
        byte[4] r;
        byte[4] g;
        byte[4] b;
		actn = "test user\0";
        message = "test message\0";
        char[Packet.sizeof] payload;
		/// Populate the payload with some bits
		/// I used memmove for this to move the bits.
		memmove(&payload,&user,user.sizeof);
		/// Populate the color with some bytes
		import std.stdio;
		// writeln("x is:",x);
		// writeln("y is:",y);
		// writeln("r is:",r);
		// writeln("g is:",g);
		// writeln("b is:",b);

        memmove(&payload[16],&s,s.sizeof);
        memmove(&payload[20],&b,b.sizeof);
		memmove(&payload[28],&g,g.sizeof);
		memmove(&payload[32],&b,b.sizeof);
        // get coordinates - how?

        this.color = [r, b, g]
        if (s == 0) {
            thisactionType = "circle"
            // get coordinates - how?

        }

		// memmove(&payload[16],&x,x.sizeof);
		// memmove(&payload[20],&y,y.sizeof);
		// memmove(&payload[24],&r,r.sizeof);
		// memmove(&payload[28],&g,g.sizeof);
		// memmove(&payload[32],&b,b.sizeof);
		// memmove(&payload[36],&s,s.sizeof);
		// memmove(&payload[40],&bs,bs.sizeof);

        return payload;

	}

}