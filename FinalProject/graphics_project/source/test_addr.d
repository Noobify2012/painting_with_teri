import std.socket;
import std.stdio;
import std.conv;
import std.random;
 
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
    //  writeln(socket.hostName);
    //  writeln("My IP address is  : ", socket.localAddress);
    //  writeln("the remote address is: ", socket.remoteAddress);
     scope(exit) socket.close();
    //  writeln("Connected");
    return socket.localAddress;
 
    //  // Buffer of data to send out
    //  byte[Packet.sizeof] buffer;
    //  auto received = socket.receive(buffer);s
}
///Find a randomly selected port, check if it is avaialbe and if so return the port number else, find another one
ushort findPort() {
    ushort port = 1;

    int min = 49152;
    int max = 65535;
    bool ready = false;
    auto rnd = Random(69);
    while(!ready) {
        auto ports = uniform(min, max, rnd);
        // writeln("checking :" ~ to!string(ports));
        auto socket = new Socket(AddressFamily.INET, SocketType.STREAM);
        auto address = find();
        // socket.bind(new InternetAddress(address.toAddrString.dup, to!ushort(ports)));
        try {
            socket.bind(new InternetAddress(address.toAddrString.dup, to!ushort(ports)));
            socket.close();
            port = to!ushort(ports);
            ready = true;
        } catch (SocketException e) {
            writeln(to!string(ports) ~ " is not available.");
        }
        
    }

    //grab a random port from that list and return it
    return port;
}