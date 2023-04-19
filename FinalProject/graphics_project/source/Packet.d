// @file Packet.d
import core.stdc.string;

/// NOTE: Consider the endianness of the target machine when you 
///       send packets. If you are sending packets to different
///       operating systems with different hardware, the
///       bytes may be flipped!
///       A test you can do is to when you send a packet to a
///       operating system is send a 'known' value to the operating system
///       i.e. some number. If that number is expected (e.g. 12345678), then
///       the byte order need not be flipped.
struct Packet{
	/** Items that can be added to the packet */
	char[16] user;  
    int x;///ditto
    int y;///ditto
    byte r;///ditto
    byte g;///ditto
    byte b;///ditto
	int s;///ditto
	int bs;///ditto
	int x2;///ditto
	int y2;///ditto
	int x3;///ditto
	int y3;///ditto
    char[64] message; ///ditto


	/** 
	* Name: GetPacketAsBytes
	* Description: Pack a bunch of bytes into an array for 'serialization' or otherwise ability to send back and forth across a server, or for otherwise saving to disk.	
	* Returns: Payload, packet with bytes of color data for each pixel
	*/
    char[Packet.sizeof] GetPacketAsBytes(){
		user = "test user\0";
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
		memmove(&payload[16],&x,x.sizeof);
		memmove(&payload[20],&y,y.sizeof);
		memmove(&payload[24],&r,r.sizeof);
		memmove(&payload[28],&g,g.sizeof);
		memmove(&payload[32],&b,b.sizeof);
		memmove(&payload[36],&s,s.sizeof);
		memmove(&payload[40],&bs,bs.sizeof);
		memmove(&payload[44],&x2,x2.sizeof);
		memmove(&payload[48],&y2,y2.sizeof);
		memmove(&payload[52],&x3,x3.sizeof);
		memmove(&payload[56],&y3,y3.sizeof);

        return payload;

	}

	
}
