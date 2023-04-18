// After starting server (rdmd server.d)
// then start as many clients as you like with "rdmd client.d"

import std.socket;
import std.stdio;
import std.conv;
import std.math;
import std.string;
import std.regex;
import std.container.array;
import core.thread.osthread;
 
/// Packet
import Packet : Packet;

/**
* Name: TCPClient
* Description: The purpose of the TCPClient class is to connect to a server and send messages.
*/
class TCPClient{
	/// The client socket connected to a server
	Socket mSocket;
    Packet inbound;
    string host;
    ushort port;
    // Deque incoming;


	/**
    Name: TCPClient Constructor
    Description: 
    */
	this(){
        // auto incoming = new Deque!(Packet);
	}

	/**
    Name: TCPClient Destructor
    Description: Closes client socket
    */ 
	~this(){
		// Close the socket
		mSocket.close();
	}

    void init() {
        host = getServerAddress();
        port = getServerPort();
        writeln("Starting client...attempt to create socket");
        writeln("Host: "~host);
        writeln("Port: "~to!string(port));
		/// Create a socket for connecting to a server
		/// Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
		/// Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
		///       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
        /// Attempt to create socket
		mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);

		/// Socket needs an 'endpoint', so we determine where we are going to connect to.
		/// NOTE: It's possible the port number is in use if you are not
		///       able to connect. Try another one.
		mSocket.connect(new InternetAddress(host, port));
		writeln("Client conncted to server");
		// Our client waits until we receive at least one message
		// confirming that we are connected
		// This will be something like "Hello friend\0"
		byte[Packet.sizeof] buffer;
		auto received = mSocket.receive(buffer);
		writeln("On Connect: ", buffer[0 .. received]);
        writeln(">");
    }

	// Purpose here is to run the client thread to constantly send data to the server.
	// This is your 'main' application code.
	// 
	// In order to make life a little easier, I will also spin up a new thread that constantly
	// receives data from the server.
	Packet run(Packet packet) {
		writeln("Preparing to run client");
		writeln("(me)",mSocket.localAddress(),"<---->",mSocket.remoteAddress(),"(server)");
		// Buffer of data to send out
		// Choose '80' bytes of information to be sent/received

		bool clientRunning=true;
		
		// Spin up the new thread that will just take in data from the server
            new Thread({
                        inbound = receiveDataFromServer();
                    }).start();
        
	
		writeln(">");
		while(clientRunning){
		    sendDataToServer(packet);

            // foreach(line; stdin.byLine){
			// 	write(">");
			// 	// Send the packet of information
			// 	mSocket.send(line);
			// }
				// Now we'll immedietely block and await data from the server
		}
        return inbound;

	}

    void sendDataToServer(Packet packet) {
        mSocket.send(packet.GetPacketAsBytes);
    }

    void closeSocket() {
        mSocket.close();
    }



	/// Purpose of this function is to receive data from the server as it is broadcast out.
	Action receiveDataFromServer(){
		while(true){	
			// Note: It's important to recreate or 'zero out' the buffer so that you do not
			// 			 get previous data leftover in the buffer.
			byte[Action.sizeof] buffer;
            auto fromServer = buffer[0 .. mSocket.receive(buffer)];
            writeln("buffer length    :", buffer.length);
            writeln("fromServer (raw bytes): ",fromServer);
            writeln();

            /// Format the packet. Note, I am doing this in a very
            /// verbosoe manner so you can see each step.
            Action formattedPacket;
            byte[16] field0        = fromServer[0 .. 16].dup;  // will probably need to change this
            formattedPacket.user = cast(char[])(field0);
            writeln("Server echos back user: ", formattedPacket.user);

            /// Get shape field
            byte[4] field1 = fromServer[16 .. 20].dup;
            int f1 = *cast(int*)&field1;
            formattedPacket.shape = f1;
            writeln("Shape from server: ", f1)


            // Get some fields
            byte[4] field2 = fromServer[20 .. 24].dup;
            byte[4] field3 = fromServer[24 .. 28].dup;
            byte[4] field4 = fromServer[28 .. 32].dup;
            byte[4] field5 = fromServer[32 .. 36].dup;
            byte[4] field6 = fromServer[36 .. 40].dup;
            byte[4] field7 = fromServer[40 .. 44].dup;
            // byte[64] messageField = fromServer[36 .. 100].dup;
            // byte[4] field6 = fromServer[100 .. 104].dup;
            int f2 = *cast(byte*)&field2;  // this will be r
            byte f3 = *cast(byte*)&field3;  // this will be g
            byte f4 = *cast(byte*)&field4;  // this will be b
            byte f5 = *cast(int*)&field5;  // this will be brush size
            // int f6 = *cast(int*)&field6;
            // int f7 = *cast(int*)&field7;

            formattedPacket.y = f2;
            formattedPacket.r = f3;
            formattedPacket.g = f4;
            formattedPacket.b = f5;
            formattedPacket.s = f6;
            formattedPacket.bs = f7;
            
            write(">");
            return formattedPacket;

		}
	}
	
}

/**
    * Name: getChangeForServer 
    * Description: takes pixel changes and packs them up into a packet to send the server. 
    * Params:    
        * @param xPos: x-coordinate of pixel, yPos: y-coordinate of pixel
        * @param blueVal: rgb blue value, greenVal: rgb green value, redVal: rgb red value
        * @param brushSize: integer value of the size of the brush that is currently being used
    * Turns the changes in pixel colors on the current users surface into a packet to send to other networked users. 
    */
Action getChangeForServer(int xPos, int yPos, ubyte redVal, ubyte greenVal, ubyte blueVal, int shape, int brushSize) {
    Action data;
		// The 'with' statement allows us to access an object
		// (i.e. member variables and member functions)
		// in a slightly more convenient way

		with (data) {
			s = shape;
			// Just some 'dummy' data for now
			// that the 'client' will continuously send
			x = xPos;
			y = yPos;
			r = *cast(byte*)&redVal;
			g = *cast(byte*)&greenVal;
			b = *cast(byte*)&blueVal;
            // s = shape;
            bs = brushSize;
			message = "update from user: " ~ 1 ~ " test\0";
		}
    return data;
}

/**
    * Name: getServerAddress 
    * Description: Prompts the user for a IP address to try and connect to for a painting party.  
    * Turns the changes in pixel colors on the current users surface into a packet to send to other networked users. 
    */
string getServerAddress() {
    /// Ask user what server they want to use
    bool good_addr = false;
    string user_addr = "localhost";
    while (!good_addr){
        writeln("what server would you like to connect to? If you are the host just press enter, otherwise Please enter the IP address in the following format ###.###.###.###");
        /// Get input
        string user_input = readln;
        /// Trim off carriage return
        user_input = user_input.strip;
    /// Validate input(check if characters are either an int or .)
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
    /// Return input as string formatted as ###.###.###.###
    return user_addr;
}


ushort getServerPort() {
    //ask user what port they want to use if not the default
    auto user_port = 50002;
    //bool used to loop until we have a good port
    bool good_port = false;
    while(!good_port){
        writeln("what port would you like to connect to? press enter for default(50002)");
        // get input
        string user_in = readln;
        //string off carriage return and other nonsense
        user_in = strip(user_in);
        // writeln(user_in.length);
        //check if the user either gave an empty string or requested their own port
        if (((user_in == "") | isNumeric(user_in))) {
            good_port = true;
            //check if port is numeric
            if (isNumeric(user_in)){
                //if numeric, is it a legal port number
                if ((to!int(user_in) >= 0) & (to!int(user_in) <= 65535)) {
                    //legal, set to return variable
                    user_port = to!int(user_in);
                } else {
                    //illegal port loop again
                    good_port = false;
                }
            }
        }
    }
    //convert to proper data type before returning
    return to!ushort(user_port);
}

// Entry point to client
// void main(){
// 	TCPClient client = new TCPClient();
// 	client.run();
// }