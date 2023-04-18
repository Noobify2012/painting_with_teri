// @file multithreaded_chat/server.d
//
// Start server first: rdmd server.d
import std.socket;
import std.stdio;
import std.conv;
import std.array;
import core.thread.osthread;
import std.uni;
import std.string;
/// Load the SDL2 library
// import bindbc.sdl;
// import loader = bindbc.loader.sharedlib;


import Packet : Packet;
import test_addr;

import Deque: Deque;

/// The purpose of the TCPServer is to accept
/// multiple client connections. 
/// Every client that connects will have its own thread
/// for the server to broadcast information to each client.
class TCPServer{
				/// Instantiate vars;
				/// The listening socket is responsible for handling new client connections.
				Socket 		mListeningSocket;
				/// Stores the clients that are currently connected to the server.
				Socket[] 	mClientsConnectedToServer;

				/// Stores all of the data on the server. Ideally, we'll 
				/// use this to broadcast out to clients connected.
				byte[Packet.sizeof][] mServerData;
				/// Keeps track of the last message that was broadcast out to each client.
				uint[] 			mCurrentMessageToSend;
				// auto reflect = new Deque!(Packet);  // I think this is supposed to replace mServerData

				/**
				/// Get server public address
				Address serverAddr = test_addr.find();
				string[] dumb = to!string(serverAddr).split(":");
				/// Set the hostname and port for the socket
				string theHost = dumb[0];
				ushort thePort = test_addr.findPort();
				// writeln("Server Address: " ~ to!string(dumb[0]));
				// writeln("Server Port: " ~ to!string(port));*/
				

				/**
				* Name: ServerConstructor
				* Description: Connects listening socket
				* Params:
					* @param: host = host address
					* @param: port = socket address
					* @param: maxConnectionsBacklog = number of clients who can connect
				*/
				this(string host = to!string(test_addr.find()).split(":")[0], ushort port = test_addr.findPort(), ushort maxConnectionsBacklog=4){
					writeln("Starting server...");
					writeln("Server Address: "~ host);
					writeln("Server Port: "~ to!string(port));
					writeln("Server must be started before clients may join");
					// Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
					// Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
					//       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
					mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
					// Set the hostname and port for the socket
					// NOTE: It's possible the port number is in use if you are not able
					//  	 to connect. Try another one.
					// When we 'bind' we are assigning an address with a port to a socket.
					mListeningSocket.bind(new InternetAddress(host,port));
					// 'listen' means that a socket can 'accept' connections from another socket.
					// Allow 4 connections to be queued up in the 'backlog'
					mListeningSocket.listen(maxConnectionsBacklog);
				}

				/// Destructor
				~this(){
					// Close our server listening socket
					// TODO: If it was never opened, no need to call close
					mListeningSocket.close();
				}

				/// Call this after the server has been created
				/// to start running the server
				void run(){
					// SDL_Event e;
					bool serverIsRunning=true;
					writeln("Awaiting client connections");

					while(serverIsRunning){
						// if(e.type == SDL_KEYUP) {
						// 	if (e.key.keysym.sym == SDLK_q) {
						// 		serverIsRunning = false;
						
						// 	}

						// }
						// The servers job now is to just accept connections
						writeln("Waiting to accept more connections");
						/// accept is a blocking call.
						auto newClientSocket = mListeningSocket.accept();
						// After a new connection is accepted, let's confirm.
						writeln("Hey, a new client joined!");
						writeln("(me)",newClientSocket.localAddress(),"<---->",newClientSocket.remoteAddress(),"(client)");
						// Now pragmatically what we'll do, is spawn a new
						// thread to handle the work we want to do.
						// Per one client connection, we will create a new thread
						// in which the server will relay messages to clients.
						mClientsConnectedToServer ~= newClientSocket;
						// Set the current client to have '0' total messages received.
						// NOTE: You may not want to start from '0' here if you do not
						//       want to send a client the whole history.
						mCurrentMessageToSend ~= 0;

						writeln("Friends on server = ",mClientsConnectedToServer.length);
						// Let's send our new client friend a welcome message
						newClientSocket.send("Hello friend\0");

						// Now we'll spawn a new thread for the client that
						// has recently joined.
						// The server will now be running multiple threads and
						// handling a chat here with clients.
						//
						// NOTE: The index sent indicates the connection in our data structures,
						//       this can be useful to identify different clients.
						new Thread({
								clientLoop(newClientSocket);
							}).start();

						// After our new thread has spawned, our server will now resume 
						// listening for more client connections to accept.
						// serverIsRunning = getServerCommands(serverIsRunning);
						writeln("have a checked for a command?");
					}	
				}

				// Function to spawn from a new thread for the client.
				// The purpose is to listen for data sent from the client 
				// and then rebroadcast that information to all other clients.
				// NOTE: passing 'clientSocket' by value so it should be a copy of 
				//       the connection.
				void clientLoop(Socket clientSocket){
						writeln("\t Starting clientLoop:(me)",clientSocket.localAddress(),"<---->",clientSocket.remoteAddress(),"(client)");
					
					bool runThreadLoop = true;

					while(runThreadLoop){
						// Check if the socket isAlive
						if(!clientSocket.isAlive){
							// Then remove the socket
							runThreadLoop=false;
							break;
						}

						// Message buffer will size of packet
    					byte[Packet.sizeof] buffer;
						// Server is now waiting to handle data from specific client
						// We'll block the server awaiting to receive a message. 	
						auto got = clientSocket.receive(buffer);					
						// writeln("Received some data (bytes): ",got);
					
						// Setup a packet to echo back
						// to the client
						Packet p;
						p.user 	= "connecting...";
						byte[4] field1 = buffer[16 .. 20].dup;
						byte[4] field2 = buffer[20 .. 24].dup;
						byte[4] field3 = buffer[24 .. 28].dup;
						byte[4] field4 = buffer[28 .. 32].dup;
						byte[4] field5 = buffer[32 .. 36].dup;
						byte[4] field6 = buffer[36 .. 40].dup;
						byte[4] field7 = buffer[32 .. 36].dup;
						int f1 = *cast(int*)&field1;
						int f2 = *cast(int*)&field2;
						byte f3 = *cast(byte*)&field3;
						byte f4 = *cast(byte*)&field4;
						byte f5 = *cast(byte*)&field5;
						int f6 = *cast(int*)&field6;
						int f7 = *cast(int*)&field7;
						p.x = f1;
						p.y = f2;
						p.r = f3;
						p.g = f4;
						p.b = f5;
						p.s = f6;
						p.bs = f7;

						// Store data that we receive in our server.
						// We append the buffer to the end of our server
						// data structure.
						// NOTE: Probably want to make this a ring buffer,
						//       so that it does not grow infinitely.
						mServerData ~= buffer;

						/// After we receive a single message, we'll just 
						/// immedietely broadcast out to all clients some data.
						// if (f1 == -9999 && f2 == -9999) {
						// 	// clientSocket.shutdown(SocketShutdown.both);
						// 	clientSocket.close();
						// 	writeln("socket should have closed");
						// } else {
						broadcastToAllClients();
						// }
						
					}
									
				}

				/// The purpose of this function is to broadcast
				/// messages to all of the clients that are currently
				/// connected.
				void broadcastToAllClients(){
					writeln("Broadcasting to :", mClientsConnectedToServer.length);
					foreach(idx,serverToClient; mClientsConnectedToServer){
						// Send whatever the latest data was to all the 
						// clients.
						while(mCurrentMessageToSend[idx] <= mServerData.length-1){
							byte[Packet.sizeof] msg = mServerData[mCurrentMessageToSend[idx]];
							serverToClient.send(msg);	
							// Important to increment the message only after sending
							// the previous message to as many clients as exist.
							mCurrentMessageToSend[idx]++;
						}
					}
				}
	bool getServerCommands(bool commandBool) {
		/// Ask user what server they want to use
		bool goodCom = false;
		bool running = true;
		// string user_addr = "localhost";
		while (!goodCom){
			writeln("Enter a command:");
			/// Get input
			string user_input = readln;
			/// Trim off carriage return
			user_input = user_input.strip;
			/// Validate input(check if characters are either an int or .)
			// string ip_regex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$";
			if (std.uni.toLower(user_input) == "quit") {
				goodCom = true;
				running = false;						
			} else {
				writeln("Invalid command, please try again");
			}
		}
		return running;
		/// Return input as string formatted as ###.###.###.###
	}

}



// Entry point to Server
void main(){
	// Note: I'm just using the defaults here.
	TCPServer server = new TCPServer;
	server.run();
}
