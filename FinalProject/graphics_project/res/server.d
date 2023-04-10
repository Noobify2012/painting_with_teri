// @file server.d
import std.socket;
import std.stdio;
import std.conv;
import std.array;

import Packet : Packet;
import test_addr;

import Deque: Deque;



void main(){

	Address serverAddr = test_addr.find();
	// writeln(serverAddr);
	string[] dumb = to!string(serverAddr).split(":");

	auto reflect = new Deque!(Packet);
	
	// string servAddr = "";
	// bool colonPassed = false;
	// string foo = to!string(serverAddr);	
	// for(int i=0; i<foo.length; i++){
	// 	if(foo[i] == ":") {
	// 		colonPassed = true;
	// 	} else if (colonPassed == false){
	// 		servAddr = servAddr ~ foo[i];
	// 	}
	// }
	// serverAddr = serverAddr.split(":")[0];
	// writeln(serverAddr);

	writeln("Starting server...");
	writeln("Server must be started before clients may join");
    auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
	// writeln("this is the family and socket stream: " ~ AddressFamily.INET, SocketType.STREAM);
	scope(exit) listener.close();

	// Set the hostname and port for the socket
    string host = dumb[0];
    ushort port = test_addr.findPort();
	writeln("Server Address: " ~ to!string(dumb[0]));
	writeln("Server Port: " ~ to!string(port));
	// NOTE: It's possible the port number is in use if you are not able
	//  	 to connect. Try another one.
    listener.bind(new InternetAddress(host,port));
    // Allow 4 connections to be queued up
    listener.listen(4);

	// A SocketSet is equivalent to 'fd_set'
	// https://linux.die.net/man/3/fd_set
	// What SocketSet is used for, is to allow 
	// 'multiplexing' of sockets -- or put another
	// way, the ability for multiple clients
	// to connect a socket to this single server
	// socket.
    auto readSet = new SocketSet();
    Socket[] connectedClientsList;

    // Message buffer will be large enough to send/receive Packet.sizeof
    byte[Packet.sizeof] buffer;

    bool serverIsRunning=true;
	// int userID = 1;

    // Main application loop for the server
	writeln("Awaiting client connections");
    while(serverIsRunning){
		// Clear the readSet
        readSet.reset();
		// Add the server
        readSet.add(listener);
        foreach(client ; connectedClientsList){
            readSet.add(client);
        }
//         // Handle each clients message
//         if(Socket.select(readSet, null, null)){
//             foreach(client; connectedClientsList){
// 				// Check to ensure that the client
// 				// is in the readSet before receving
// 				// a message from the client.
//                 if(readSet.isSet(client)){
// 					// Server effectively is blocked
// 					// until a message is received here.
// 					// When the message is received, then
// 					// we send that message from the 
// 					// server to the client
//                     auto got = client.receive(buffer);
					
// 					// Setup a packet to echo back
// 					// to the client
// 					Packet p;
// 				    p.user 	= "connecting...";
// 					byte[4] field1 =  buffer[16 .. 20].dup;
// 					byte[4] field2 =  buffer[20 .. 24].dup;
// 					int f1 = *cast(int*)&field1;
// 					int f2 = *cast(int*)&field2;
// 					p.x = f1;
// 					p.y = f2;
        // Handle each clients message
        if(Socket.select(readSet, null, null)){
            foreach(client; connectedClientsList){
				// Check to ensure that the client
				// is in the readSet before receving
				// a message from the client.
                if(readSet.isSet(client)){
					// Server effectively is blocked
					// until a message is received here.
					// When the message is received, then
					// we send that message from the 
					// server to the client
                    auto got = client.receive(buffer);
					// writeln("value of ")
					
					// Setup a packet to echo back
					// to the client
					Packet p;
				    p.user 	= "connecting...";
					byte[4] field1 = buffer[16 .. 20].dup;
					byte[4] field2 = buffer[20 .. 24].dup;
					byte[4] field3 = buffer[24 .. 28].dup;
					byte[4] field4 = buffer[28 .. 32].dup;
					byte[4] field5 = buffer[32 .. 36].dup;
					int f1 = *cast(int*)&field1;
					int f2 = *cast(int*)&field2;
					byte f3 = *cast(byte*)&field3;
					byte f4 = *cast(byte*)&field4;
					byte f5 = *cast(byte*)&field5;
					p.x = f1;
					p.y = f2;
					p.r = f3;
					p.g = f4;
					p.b = f5;
					// writeln("server sets packet values of x: " ~to!string(p.x) ~ " y: " ~ to!string(p.y) ~ " r: " ~to!string(p.r) ~ " g: " ~ to!string(p.g) ~ " b: " ~ to!string(p.b));
					
					// Send raw bytes from packet,
					reflect.push_front(p);
					reflectPacket(connectedClientsList, reflect, client);
                    // client.send(p.GetPacketAsBytes());
					// writeln("readset is set for client");
                }
            }
			// The listener is ready to read
			// Client wants to connect so we accept here.
			if(readSet.isSet(listener)){
				auto newSocket = listener.accept();
				// Based on how our client is setup,
				// we need to send them an 'acceptance'
				// message, so that the client can
				// proceed forward.
				newSocket.send("Welcome from server, you are now in our connectedClientsList");
				// Add a new client to the list
				connectedClientsList ~= newSocket;
				writeln("> client",connectedClientsList.length," added to connectedClientsList");
				writeln("readset is set for listener");

			}
    	}
	}
}

//TODO: Method for sending packets to every other client
// get packet from user
// loop through all other users and send packet(think broadcast)

void reflectPacket(Socket[] connectedClientsList, Deque!(Packet) packets, Socket socket){
	while(packets.size() > 0) {
		auto packet = packets.pop_back;
		foreach(client; connectedClientsList) {
			// writeln("Sending Packet to: " ~ to!string(client));
			client.send(packet.GetPacketAsBytes);
		}
	}
}
