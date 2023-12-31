import std.socket;
import std.stdio;
import std.conv;
import std.math;
import std.string;
import std.regex;
import std.container.array;

 
 /// Packet
import Packet : Packet;
//method for recieving coloring to change
//method to connect to server
//method to send
//method to recieve changes from server

// TODO: break out method for connecting to a server - Complete
//TODO: break out method to send packets
//TODO: break out method to recieve color changes from user
//TODO: method to recieve color changes from server
//

/***********************************
* Name: Initialize
* Description: Method to create a socket connection to the server; Catches the  exception if the client fails to connect, loops infinitely if a connection can't be made.
* Returns: A socket that is connected to the server
*/
Socket initialize() {
	writeln("Starting client...attempt to create socket");
    // Create a socket for connecting to a server
    auto socket = new Socket(AddressFamily.INET, SocketType.STREAM);
    bool connected = false;
        // auto r = getAddress("8.8.8.8" , 53);
        //  const char[] address = r[0].toAddrString().dup;
        //  ushort port = to!ushort(r[0].toPortString());
	/// Socket needs an 'endpoint', so we determine where we are going to connect to.
	/// NOTE: It's possible the port number is in use if you are not
	///       able to connect. Try another one.

    // TODO: add try catch to handle if the connection is refused. 
    while (!connected) {
        /// get an address to connect to from the user
        string serverAddress = getServerAddress();
        //get a port to connect to from the user
        ushort serverPort = getServerPort();
        writeln("attempting to connect to : " ~ to!string(serverAddress) ~ " on port: " ~to!string(serverPort));
        socket.connect(new InternetAddress(serverAddress.dup, serverPort));
        connected = true;

        // try {
        //     socket.connect(new InternetAddress(serverAddress.dup, serverPort));
        //     connected = true;
        // } 
        // catch (SocketException e) 
        // {
        //     writeln("Failed to connect, please check the address and port and try again.");
        // }
    }
    
    // writeln(socket.hostName);
    //  writeln("My IP address is  : ", socket.localAddress);
    //  writeln("the remote address is: ", socket.remoteAddress);
	// scope(exit) socket.close();
	writeln("Connected");
    return socket;
}

/***********************************
* Name: sendConnectionHandshake
* Description: When the connection is made, send the packet and make sure you can receive it 
* Params: 
*   socket = A socket that is connected to the server
* Returns: a packet of bytes 
*/
byte[Packet.sizeof] sendConnectionHandshake(Socket socket) {
    byte[Packet.sizeof] buffer;
    auto received = socket.receive(buffer);

    writeln("On Connect: ", buffer[0 .. received]);
	write(">");
    return buffer;
}

/***********************************
* Name: sendToServer
* Description: send your packet to the server as a collection of bytes 
* Params: 
*    packet = packet of data to make into bytes 
*    socket = A socket that is connected to the server
*/
void sendToServer(Packet packet, Socket socket) {
    socket.send(packet.GetPacketAsBytes());
}

/***********************************
* Name: receiveFromServer 
* Description: When a packet comes over the server, get it and open it up into bytes 
* Params: 
*    socket = A socket that is connected to the server
*    buffer = a buffer that can hold incoming bytes before adding to surface 
* Returns: a formatted packet of bytes 
*/
Packet recieveFromServer(Socket socket, byte[Packet.sizeof] buffer) {
    auto fromServer = buffer[0 .. socket.receive(buffer)];
		writeln("sizeof fromServer:",fromServer.length);
		// writeln("sizeof Packet    :", Packet.sizeof);
		writeln("buffer length    :", buffer.length);
		writeln("fromServer (raw bytes): ",fromServer);
		writeln();


		/// Format the packet. Note, I am doing this in a very verbose manner so you can see each step.
		Packet formattedPacket;
		byte[16] field0        = fromServer[0 .. 16].dup;
		formattedPacket.user = cast(char[])(field0);
        writeln("Server echos back user: ", formattedPacket.user);

		/// Get some of the fields
		byte[4] field1 = fromServer[16 .. 20].dup;
		byte[4] field2 = fromServer[20 .. 24].dup;
        byte[4] field3 = fromServer[24 .. 28].dup;
		byte[4] field4 = fromServer[28 .. 32].dup;
        byte[4] field5 = fromServer[32 .. 36].dup;
        // byte[64] messageField = fromServer[36 .. 100].dup;
        // byte[4] field6 = fromServer[100 .. 104].dup;
		int f1 = *cast(int*)&field1;
		int f2 = *cast(int*)&field2;
        byte f3 = *cast(byte*)&field3;
        byte f4 = *cast(byte*)&field4;
        byte f5 = *cast(byte*)&field5;
		formattedPacket.x = f1;
		formattedPacket.y = f2;
        formattedPacket.r = f3;
        formattedPacket.g = f4;
        formattedPacket.b = f5;

		// writeln("what is field1(x): ",formattedPacket.x);
		// writeln("what is field2(y): ",formattedPacket.y);
        // writeln("what is field3(r): ",formattedPacket.r);
		// writeln("what is field4(g): ",formattedPacket.g);
        // writeln("what is field5(b): ",formattedPacket.b);
		// NOTE: You may want to explore std.bitmanip, if you
		//       have different endian machines.
//		int value = peek!(int,Endian.littleEndian)(field1);

		write(">");

        return formattedPacket;

}

/***********************************
* Name: getChangeForServer
* Description: get the data that you need to add to the server from your surface 
* Params: 
*    xPos = the x coordinate to change 
*    yPos = the y coordinate to change 
*    redVal = the red RGB value 
*    blueVal = the blue RGB value 
*    greenVal = the green RGB value 
* Returns: a packet of bytes 
*/
Packet getChangeForServer(int xPos, int yPos, ubyte redVal, ubyte greenVal, ubyte blueVal) {
    Packet data;
		// The 'with' statement allows us to access an object
		// (i.e. member variables and member functions)
		// in a slightly more convenient way
        // writeln("Input for get change x: " ~to!string(xPos) ~ " y: " ~ to!string(yPos) ~ " r: " ~to!string(redVal) ~ " g: " ~ to!string(greenVal) ~ " b: " ~ to!string(blueVal));
        // writeln("Inside Packet values x: " ~to!string(data.x) ~ " y: " ~ to!string(data.y) ~ " r: " ~to!string(data.r) ~ " g: " ~ to!string(data.g) ~ " b: " ~ to!string(data.b));
        
        byte red = cast(byte) redVal;
        int redInt = to!int(red);
        byte block = cast(byte) 256;

        if (redInt >=128){
            red = cast(byte) redInt;
            // red = red + block;
        } else { 
            red = cast(byte) redInt;
        }
        
        
        // writeln("red = " ~ to!string(red));
        // writeln("redVal = " ~ to!string(redVal));
        // writeln("redInt = " ~ to!string(redInt));

		with (data) {
			user = "clientName\0";
			// Just some 'dummy' data for now
			// that the 'client' will continuously send
			x = xPos;
			y = yPos;
			r = *cast(byte*)&redVal;
			g = *cast(byte*)&greenVal;
			b = *cast(byte*)&blueVal;
			message = "update from user: " ~ 1 ~ " test\0";
            // writeln("Inside Packet values x: " ~to!string(data.x) ~ " y: " ~ to!string(data.y) ~ " r: " ~to!string(data.r) ~ " g: " ~ to!string(data.g) ~ " b: " ~ to!string(data.b));
		}
        // writeln("value of data: " ~ to!string(data));

	// Send the packet of information breaks, can't send socket from SDLApp
    // socket.send(data.GetPacketAsBytes());
    return data;
}

/***********************************
* Name: getServerAddress 
* Description: When the server is made, provide the address for clients to join 
* Returns: the address of the server as a string
*/
string getServerAddress() {
    /// ask user what server they want to use
    bool good_addr = false;
    string user_addr = "localhost";
    while (!good_addr){
        writeln("what server would you like to connect to? If you are the host just press enter, otherwise Please enter the IP address in the following format ###.###.###.###");
        /// get input
        string user_input = readln;
        /// trim off carriage return
        user_input = user_input.strip;

    ///validate input(check if characters are either an int or .) regex for ip address ^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$
        string ip_regex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$";
        if (auto m = std.regex.matchFirst(user_input, ip_regex)) {
            good_addr = true;
            user_addr = user_input;
        } else if(user_input == "") {
            good_addr = true;
        } else {
            writeln("Invalid IP address recieved");
        }
    }

    /// return input as string formatted as ###.###.###.###
    return user_addr;
}

/***********************************
* Name: getServerPort
* Description: When the connection is made, get the port number so client can join 
* Returns: the port number 
*/
ushort getServerPort() {
    /// ask user what port they want to use if not the default
    auto user_port = 50002;
    /// bool used to loop until we have a good port
    bool good_port = false;
    while(!good_port){
        writeln("what port would you like to connect to? press enter for default(50002)");
        /// get input
        string user_in = readln;
        /// string off carriage return and other nonsense
        user_in = strip(user_in);
        // writeln(user_in.length);
        /// check if the user either gave an empty string or requested their own port
        if (((user_in == "") | isNumeric(user_in))) {
            good_port = true;
            /// check if port is numeric
            if (isNumeric(user_in)){
                /// if numeric, is it a legal port number
                if ((to!int(user_in) >= 0) & (to!int(user_in) <= 65535)) {
                    /// legal, set to return variable
                    user_port = to!int(user_in);
                } else {
                    /// illegal port loop again
                    good_port = false;
                }
            }
        }
    }
    /// convert to proper data type before returning
    return to!ushort(user_port);
}