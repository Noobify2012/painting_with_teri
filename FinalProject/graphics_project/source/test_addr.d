import std.socket;
import std.stdio;
import std.conv;
 
 // Packet
import Packet : Packet;
// import my/test_addr.d;

Address find(){
    // test_addr.main();
     writeln("Starting client...attempt to create socket");
     // Create a socket for connecting to a server
     auto socket = new Socket(AddressFamily.INET, SocketType.STREAM);
     //CITATION: https://forum.dlang.org/post/hlougompegdwwviahdek@forum.dlang.org
     auto r = getAddress("8.8.8.8" , 53);
     const char[] address = r[0].toAddrString().dup;
     ushort port = to!ushort(r[0].toPortString());
     // Socket needs an 'endpoint', so we determine where we
     // are going to connect to.
     // NOTE: It's possible the port number is in use if you are not
     //       able to connect. Try another one.
     socket.connect(new InternetAddress(address, port));
     writeln(socket.hostName);
     writeln("My IP address is  : ", socket.localAddress);
     writeln("the remote address is: ", socket.remoteAddress);
     scope(exit) socket.close();
    //  writeln("Connected");
    return socket.localAddress;
 
    //  // Buffer of data to send out
    //  byte[Packet.sizeof] buffer;
    //  auto received = socket.receive(buffer);s
}