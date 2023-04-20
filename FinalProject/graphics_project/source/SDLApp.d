/// Import D standard libraries
import std.stdio;
import std.string;
import std.process;
import std.conv;
import std.socket;
import std.parallelism;
import core.thread.osthread;
import std.math;
import std.typecons;
import std.random;
import core.thread.threadbase;

/// Load the SDL2 library
import bindbc.sdl;
import bindbc.sdl.image;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;

/// Networking imports 
import test_client;
import Packet : Packet;
import Deque : Deque;
import test_addr;
import mClient;
import shape_listener;
import Action : Action;
import state;

/// Import shape classes 
import drawing_utilities;
import Rectangle : Rectangle;
import Triangle : Triangle; 
import Circle : Circle;
import Line : Line;

/***********************************
* Name: SDLApp 
* Descripton: the main access to the application's running loop. This holds all the working methods of the window. 
*/
class SDLApp{

    /// global variable for sdl;
    const SDLSupport ret;
    TCPClient client = new TCPClient();

    /// RGB Values that get passed into drawing functions & methods
    /// Defaults to white if for some reason your colors are not working 
    ubyte red = 255; ///ditto
    ubyte green = 255; ///ditto
    ubyte blue = 255; ///ditto 

    bool erasing = false;
    auto traffic = new Deque!(Packet);
    Socket sendSocket;
    byte[Packet.sizeof] buffer;

    Packet inbound;
    bool tear_down = false;
    auto received = new Deque!(Packet);
    Action shapeAction;
    State state;

    /**
    Starts when you run the application and ends automatically 
    when you destroy the window. This is the main loop which 
    runs all of the primary app functionality. 
    **/
    void MainApplicationLoop(){
        /// Create an SDL window
        SDL_Window* window= SDL_CreateWindow("The Teri Chadbourne Experience",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480,
            SDL_WINDOW_SHOWN);

        /// Load the bitmap surface
        Surface imgSurface = new Surface(0,640,480,32,0,0,0,0);

        /// Initialize variables
        /// Application running flag for determing if we are running the main application loop
        bool runApplication = true;
        /// Drawing flag for determining if we are 'drawing'
        bool drawing = false;

        /// Networking defaults 
        bool change = false;
        bool networked = false; ///ditto 

        /// Default brush
        int brush = 1;

        /// Default color 
        int color = 1;

        /// Default brushsize 
        int brushSize = 4;

        /// For erasing function 
        int temp_color = 0;

        /// User isn't currently drawing 
        int prevX = -9999;
        int prevY = -9999;///ditto 

        /// Create a blank state 
        state = new State(&imgSurface);

        /// Create drawing and shape capabilities 
        DrawingUtility du = new DrawingUtility();
        ShapeListener sh = new ShapeListener(); ///Ditto 

        /// Open a socket for networking 
        Socket recieveSocket;

        /// Create the menu interface, draw it on the screen on launch 
        createMenu(imgSurface);

        /// Test action to add to state 
        Action act = new Action([], [red, green, blue], "stroke");
        
        ///Default brush size
        brush = 2;
   
        /***********************************
        * runApplication is the main application loop that will run until a
        * quit event has occurred. This is the 'main graphics loop'.
        */
        while(runApplication){
            SDL_Event e;
            /// Handle events
            /// NOTE: Events are pushed into an 'event queue' internally in SDL, and then handled one at a time within this loop for as many events have been pushed into the internal SDL queue. Thus, we poll until there are '0' events or a NULL event is returned.
            while(SDL_PollEvent(&e) !=0){

                if(e.type == SDL_QUIT){
                    runApplication= false;
                }
                else if(e.type == SDL_MOUSEBUTTONDOWN){
                    drawing=true;
                    int xPos = e.button.x;
                    int yPos = e.button.y;
                    int h2 = 640/6;


                    ///**BEGIN MENU BUTTON SELECTOR**
                    /// Button one: change brush size 
                    if (yPos < 50 && xPos < h2){
                        /// writeln("button1: Change brush size");

                        if (xPos > 10 && xPos < 18){
                            /// writeln("Brush Size 2");
                            brush = 2;
                        } 
                        else if (xPos > 20 && xPos < 29){
                            /// writeln("Brush Size 4");
                            brush = 4;
                        }
                        else if (xPos > 30 && xPos < 45){
                            /// writeln("Brush Size 6");
                            brush = 6;
                        }
                        else if (xPos > 50 && xPos < 65){
                            /// writeln("Brush Size 8");
                            brush = 8;
                        }
                        else if (xPos > 69 && xPos < 89){
                            /// writeln("Brush Size 12");
                            brush = 12;
                        }
                    }

                    /// Button two: change brush color                     
                    if(yPos < 50 && xPos > h2 && xPos < h2 * 2){
                        if(erasing == true){
                            writeln("ERASER: Deactivated");
                            erasing = false;
                        }
                        if(xPos > 112 && xPos < 124){
                            writeln("You selected: color RED");
                            color = 1;
                        }
                        else if(xPos > 130 && xPos < 142){
                            writeln("You selected: color ORANGE");
                            color = 2;
                        }
                        else if(xPos > 146 && xPos < 158){
                            writeln("You selected: color YELLOW");
                            color = 3;
                        }
                        else if(xPos > 162 && xPos < 174){
                            writeln("You selected: color GREEN");
                            color = 4;
                        }
                        else if(xPos > 178 && xPos < 190){
                            writeln("You selected: color BLUE");
                            color = 5;
                        }else if(xPos > 194 && xPos < 206){
                            writeln("You selected: color VIOLET");
                            color = 6;
                        }
                    }

                    /// Based on color selected, update the RGB values using colorValueSetter
                    if (color == 1 && !erasing) {
                        /// Set brush color to red
                        colorValueSetter(1);
                    } else if (color == 2 && !erasing) {
                        /// Set brush color to orange
                        colorValueSetter(2);
                    }  else if (color == 3 && !erasing) {
                        /// Set brush color to yellow
                        colorValueSetter(3);
                    } else if (color == 4 && !erasing) {
                        /// Set brush color to green
                        colorValueSetter(4);
                    } else if (color == 5 && !erasing) {
                        /// Set brush color to blue
                        colorValueSetter(5);
                    } else if (color == 6 && !erasing) {
                        /// Set brush color to violet
                        colorValueSetter(6);
                    } else if (erasing) {
                        /// Erase: set color to black
                        red = 0;
                        green = 0;
                        blue = 0;
                    }

                    /// Button three:
                    // /**TECH DEBT: pull this out into a separate function. Code is duplicate of key presses 
                    if(yPos < 50 && xPos > h2 * 2 + 1 && xPos < h2 * 3){
                        eraserToggle(erasing, color);
                    }

                    ///Button four: Shape Activator 
                    ///Splits the 4 quadrants of B4 into shape assignments  
                    if(yPos < 50 && xPos > h2 * 3 + 1 && xPos < h2 * 4){
                        string quadrant; 
                        ///Top Left: Line
                        if(yPos < 24 && xPos < 373){
                            // writeln("You selected: Draw LINE");
                            // writeln("LINE: Click start and end points");
                            quadrant = "TL";
                        }
                        ///Top Right: Rectangle 
                        else if(yPos < 24 && xPos > 373){
                            // writeln("You selected: Draw RECTANGLE");
                            // writeln("RECTANGLE: Click two corner points");
                            quadrant = "TR";
                        }
                        ///Bottom Left: Circle 
                        else if(yPos > 24 && xPos < 373){
                            // writeln("You selected: Draw CIRCLE");
                            // writeln("CIRCLE: Click two points");
                            quadrant = "BL";
                        }
                        ///Bottom Right: Triangle
                        else if(yPos > 24 && xPos > 373){
                            // writeln("You selected: Draw TRIANGLE");
                            // writeln("TRIANGLE: Click three corner points");
                            quadrant = "BR";
                        }
                        writeln("Drawing shape");
                        
                        writeln("Type 'r' for rectangle", "\nType 'c' for circle",
                                "\nType 'l' for line", "\nType 'r' for rectangle");

                        // ShapeListener sh = new ShapeListener(quadrant);
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);

                        /// Add the shape to the stack and unpack it 
                        shapeAction = sh.getAction();
                        shapeAction.setColor([cast(int) red, cast(int) green, cast(int) blue]);
                        state.addAction(sh.getAction());

                        
                        /// unpack the points
                        int x,y,x2,y2,x3,y3;
                        for(int i=0; i < shapeAction.getPoints.length; i++) {
                            for (int j=0; j < 2; j++) {
                                if(i == 0 && j == 0) {
                                    x = shapeAction.getPoints[0][0];
                                } else if (i == 0 && j == 1) {
                                    y = shapeAction.getPoints[i][1];
                                } else if (i == 1 && j == 0) {
                                    x2 = shapeAction.getPoints[i][0];
                                } else if (i == 1 && j == 1) {
                                    y2 = shapeAction.getPoints[i][1];
                                } else if (i == 2 && j == 0) {
                                    x3 = shapeAction.getPoints[i][0];
                                } else {
                                    y3 = shapeAction.getPoints[i][1];
                                }
                            }
                        }

                        /// unpack type
                        writeln("shape action type: " ~to!string(shapeAction.getActionType()));
                        int st = 0;
                        if (shapeAction.getPoints().length == 3) {
                            ///do triangle
                            /// Triangle is shape type 3
                            st = 3;
                        } else {
                            /// circle is shape type 1
                            if (shapeAction.getActionType() == "circle") {
                                st = 1;
                            } else if (shapeAction.getActionType() == "rectangle") {
                                /// rectangle is shape type 2
                                st = 2;
                            } else {
                                /// line is shape type 4
                                st = 4;
                            }
                        }

                        //unpack rgb values 
                        // ubyte redU = *cast(byte*)&red;
                        // ubyte greenU = *cast(byte*)&green;
                        // ubyte blueU = *cast(byte*)&blue;

                        int shapeBrush = 4;
                        // writeln(shapeAction.getPoints[]);
                        // writeln(shapeAction.getPoints[0][0]);
                        // writeln(shapeAction.getPoints[0][1]);
                        // writeln(shapeAction.getPoints[1][0]);
                        // writeln(shapeAction.getPoints[1][1]);
                        if (networked == true) {
                            Packet shapePacket = mClient.getChangeForServer(x,y,red, green, blue, st, shapeBrush, x2, y2, x3, y3);
                            client.sendDataToServer(shapePacket);
                        }
                        // Send the selected shape to the ShapeListener so the user can draw it. 
                        // ShapeListener shQ = new ShapeListener(quadrant, brushSize);
                        // // shQ.setRGB(red, green, blue);
                        // shQ.drawShape(&imgSurface, brush, red, green, blue);
                    }

                    ///Button five: UNDO 
                    if(yPos < 50 && xPos > h2 * 4 + 1 && xPos < h2 * 5){
                        writeln("You selected: UNDO");
                        state.undo();
                        if (networked) {
                            Packet undoPack = mClient.getChangeForServer(0,0,0,0,0, -10, 0,0,0,0,0);
                            client.sendDataToServer(undoPack);
                        }
                    }
                    ///Button six: REDO
                    if(yPos < 50 && xPos > h2 * 5 + 1 && xPos < h2 * 6){
                        writeln("You selected: REDO");
                        state.redo();
                        if (networked) {
                            Packet rePack = mClient.getChangeForServer(0,0,0,0,0, 10, 0,0,0,0,0);
                            client.sendDataToServer(rePack);
                        }
                    }
                    /// **END MENU BUTTON SELECTOR**

                /// The user has released the mouse, not currently clicking or drawing. 
                }else if(e.type == SDL_MOUSEBUTTONUP){
                    if (drawing) {
                        /// Add the completed line to the stack 
                        act.setColor([cast(int) red, cast(int) green, cast(int) blue]);
                        state.addAction(act);
                        act = new Action([], [red, green, blue], "stroke");
                    }
                    drawing=false;
                    prevX = -9999;
                    prevY = -9999;

                /// The user is currently drawing a line or shape. 
                } else if(e.type == SDL_MOUSEMOTION && drawing) {
                    /// Get position of the mouse when drawing
                    int xPos = e.button.x;
                    int yPos = e.button.y;

                    /// Add point to the stack 
                    act.addPoint(tuple(xPos, yPos));
                    /// Loop through and update specific pixels
                    /// NOTE: this seems like it is repetitive code, we use both variables but could probably refactor to use just one of these. 
                    if (brush == 2) {
                        brushSize = 2;
                    } else if (brush == 4) {
                        brushSize = 4;
                    } else if (brush == 6) {
                        brushSize = 6;
                    } else if (brush == 8) {
                        brushSize = 8;
                    } else if (brush == 12) {
                        brushSize = 12;
                    }

                    /// Change brush:
                    for(int w=-brushSize; w < brushSize; w++){
                        for(int h=-brushSize; h < brushSize; h++){
                            if (color == 1 && !erasing) {
                                /// Set brush color to red
                                colorValueSetter(1);

                            } else if (color == 2 && !erasing) {
                                /// Set brush color to orange
                                colorValueSetter(2);

                            }  else if (color == 3 && !erasing) {
                                /// Set brush color to yellow
                                colorValueSetter(3);
                
                            } else if (color == 4 && !erasing) {
                                /// Set brush color to green
                                colorValueSetter(4);

                            } else if (color == 5 && !erasing) {
                                /// Set brush color to blue
                                colorValueSetter(5);

                            } else if (color == 6 && !erasing) {
                                /// Set brush color to violet
                                colorValueSetter(6);

                            } else if (erasing) {
                                /// Erase: set color to black
                                red = 0;
                                green = 0;
                                blue = 0;
                            }

                            /// Send change from user to deque
                            if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 52 && prevY > 52)
                                /// Make sure user is within the window and not on the menu space 
                                imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            
                            /// Check if the client is networked
                            if(networked == true) {
                                Packet packet;
                            }
                        }
                    }

                    /// This is where we draw the line!
                    /// --This is also imposing bounds for drawing lines - the xPos & yPos limitations keep you from overflowing pixels
                    if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 50 && prevY > 51) {
                        /// Create a packet to send over server 
                        Packet linePacket = mClient.getChangeForServer(prevX, prevY, red, green, blue, 4, brushSize, xPos, yPos,0,0);

                        /// Add all points into the line 
                        Line newLine = new Line(&imgSurface);

                        ///Draw/build the line 
                        newLine.drawFromPoints(buildShape(linePacket), red, green, blue, brushSize);

                        /// Actually display the line on your surface 
                        imgSurface.lerp(prevX, prevY, xPos, yPos, brushSize, red, green, blue);

                        /// Send packet to the server traffic 
                        if (networked == true) {
                            traffic.push_front(linePacket);
                        }
                        // writeln("are we hitting lerp?");
                    }
                    /// Reset the x and y values
                    prevX = xPos;
                    prevY = yPos;
                    
                /// If keyboard is pressed check for change event
                } else if(e.type == SDL_KEYDOWN) { 
                    /// Listener for key being currently pressed - not currently in use. 

                } else if(e.type == SDL_KEYUP) {
                    printf("key released: ");
                    //, to!string(e.key.keysym.sym));

                    if (e.key.keysym.sym == SDLK_b){
                        /// User pressed letter b, cycle through the 3 brush sizes and update on each press. 
                        brush = brushSizeChanger(brush);

                    } else if (e.key.keysym.sym == SDLK_c) {
                        ///User pressed letter c, cycle through the colors and update on each press. 
                        color = colorChanger(color);
                        writeln("CHANGE COLOR KEY PRESSED");


                    } else if (e.key.keysym.sym == SDLK_e) {
                        /// User pressed letter e, either activate or deactivate the eraser. 
                        writeln("E");
                        eraserToggle(erasing, color);

                    } else if (e.key.keysym.sym == SDLK_n) {
                        /// User pressed the n key, begin process to join a network 
                        if (networked == false) {
                            /// Create a new client listener. 
                            client.init();
                            getNewData();
                            writeln("started new listener");
                            networked = true;
                        } else {
                            tear_down = true;
                        }

                     } else if (e.key.keysym.sym == SDLK_s) {
                        /// User pressed the s key, create a new shape listener and draw the shape when they select one. 
                        writeln("Drawing shape");
                        writeln("Type 'r' for rectangle", "\nType 'c' for circle", 
                                "\nType 'l' for line", "\nType 'r' for rectangle");
                       
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                        shapeAction = sh.getAction();
                        shapeAction.setColor([cast(int) red, cast(int) green, cast(int) blue]);
                        state.addAction(sh.getAction());

                        /// unpack the points
                        int x,y,x2,y2,x3,y3;
                        for(int i=0; i < shapeAction.getPoints.length; i++) {
                            for (int j=0; j < 2; j++) {
                                if(i == 0 && j == 0) {
                                    x = shapeAction.getPoints[0][0];
                                } else if (i == 0 && j == 1) {
                                    y = shapeAction.getPoints[i][1];
                                } else if (i == 1 && j == 0) {
                                    x2 = shapeAction.getPoints[i][0];
                                } else if (i == 1 && j == 1) {
                                    y2 = shapeAction.getPoints[i][1];
                                } else if (i == 2 && j == 0) {
                                    x3 = shapeAction.getPoints[i][0];
                                } else {
                                    y3 = shapeAction.getPoints[i][1];
                                }
                            }
                        }

                        /// unpack type
                        writeln("shape action type: " ~to!string(shapeAction.getActionType()));
                        int st = 0;
                        if (shapeAction.getPoints().length == 3) {
                            st = 3;
                            ///do triangle, shape type 3 
                        } else {
                            ///circle is shape type 1
                            if (shapeAction.getActionType() == "circle") {
                                st = 1;
                            } else if (shapeAction.getActionType() == "rectangle") {
                                ///rectangle is shape type 2
                                st = 2;
                            } else {
                                ///line is shape type 4
                                st = 4;
                            }
                        }

                        int shapeBrush = 4;
                        ///Send the shape over the network 
                        if (networked == true) {
                            Packet shapePacket = mClient.getChangeForServer(x,y,red, green, blue, st, shapeBrush, x2, y2, x3, y3);
                            client.sendDataToServer(shapePacket);
                        }

                    } else if (e.key.keysym.sym == SDLK_u) {
                        /// User pressed the u key, they want to undo the last action 
                        if (networked) {
                            Packet undoPack = mClient.getChangeForServer(0,0,0,0,0, -10, 0,0,0,0,0);
                            traffic.push_front(undoPack);
                        } else {
                            state.undo();
                        }

                    } else if (e.key.keysym.sym == SDLK_r) {
                        /// User pressed the r key, they want to redo the last action 
                        if (networked) {
                            Packet rePack = mClient.getChangeForServer(0,0,0,0,0, 10, 0,0,0,0,0);
                            traffic.push_front(rePack);
                            // client.sendDataToServer(rePack);
                        } else {
                            state.redo();
                        }
                    }
                }
            }

            ///Networking Block:
            ///if we have turned networking on, check if there is traffic and that we are not in the tear down process. 
            if (networked == true) {
                if (traffic.size > 0 && !tear_down) {
                    writeln(">");
                    ///send traffic to the server
                    client.sendDataToServer(traffic.pop_back);
                } else if (tear_down) {
                    ///initiate a grace full tear down with the server by sendings and empty packet. 
                    auto packet = mClient.getChangeForServer(-9999,-9999, 0, 0, 0,0,0,0,0,0,0);
                    client.sendDataToServer(packet);
                    ///close the socket
                    client.closeSocket();
                    tear_down = false;
                    networked = false;
                } else if (received.size() > 0){
                    /// if we have traffic that came in from the server, add it to the surface. 
                    drawInbound(received, imgSurface);
                }   
            }
            
            /// Blit the surace (i.e. update the window with another surfaces pixels by copying those pixels onto the window).
            SDL_BlitSurface(imgSurface.getSurface(),null,SDL_GetWindowSurface(window),null);
            /// Update the window surface
            SDL_UpdateWindowSurface(window);
            /// Delay for 16 milliseconds
            /// Otherwise the program refreshes too quickly
            SDL_Delay(16);
        }
        /// Destroy our window
        SDL_DestroyWindow(window);

    /// End main application loop
    }

    /***********************************
    * Name: colorValueSetter 
    * Description: Color list with RGB values to iterate through and make the color change. 
    * Params: 
    *     colorNum = current color setting 
    */
    void colorValueSetter(int colorNum) { 
        if (colorNum == 1) {
            /// Set brush color to red
            red = 24;
            green = 20;
            blue = 195;

        } else if (colorNum == 2) {
            /// Set brush color to orange
            red = 14;
            green = 106;
            blue = 247;

        }  else if (colorNum == 3) {
            /// Set brush color to yellow
            red = 30;
            green = 190;
            blue = 234;

        } else if (colorNum == 4) {
            /// Set brush color to green
            red = 75;
            green = 128;
            blue = 0;

        } else if (colorNum == 5) {
            /// Set brush color to blue
            red = 224;
            green = 125;
            blue = 19;

        } else if (colorNum == 6) {
            /// Set brush color to violet
            red = 181;
            green = 9;
            blue = 136;
        }
    }

    /***********************************
    * Name: getNewData 
    * Description: Establishes a new thread with a listener to get all incoming changes when we are networked. Listens for incoming data from the server and adds it to the queue for inbound traffic to be added to the surface.
    */
    void getNewData() {
        new Thread({
            while (!tear_down) {
                inbound = client.receiveDataFromServer();
                // writeln("inbound x: " ~ to!string(inbound.x) ~ " inbound y: " ~ to!string(inbound.y)~ " inbound shape: " ~ to!string(inbound.s));
                received.push_front(inbound);
                writeln("Size of Received: " ~to!string(received.size()));
            } 
        }).start();
    }

    /***********************************
    * Name: drawInbound
    * Description: Adds all networked painting pixels and adds them to the users surface. Creates a seperate thread and removes all of the packets of pixel changes from the server from the queue and adds them to the surface. 
    * Params:    
        * traffic = Deque of packets from the server that contains pixel changes from the server
        * imgSurface = The users image surface that needs to be updated
    */
    void drawInbound(Deque!(Packet) traffic, Surface imgSurface) {
        new Thread({
            Action nextAct;
            while(traffic.size() > 0) {
            
                auto curr = traffic.pop_back();
                
                red = cast(char)(curr.r & 0xff);
                blue = cast(char)(curr.b & 0xff);
                green = cast(char)(curr.g & 0xff);
                
                /// build tuple for drawing network points and adjusting state
                Tuple!(int, int)[] shapePoints = buildShape(curr);
                /// build color array for state update
                int[3] color = buildColor(curr);
                string actType;
                if (curr.s == 0) {
                    imgSurface.UpdateSurfacePixel(curr.x, curr.y, curr.r, curr.g, curr.b);
                    writeln("i got a pixel");
                } else if (curr.s == 1) {
                    /// circle
                    Circle inboundCircle = new Circle(&imgSurface);
                    inboundCircle.drawFromPoints(shapePoints, red, green, blue, curr.bs);
                    nextAct = new Action(shapePoints,color, "circle");
                    state.addAction(nextAct); 
                    writeln("i got a circle");
                } else if (curr.s == 2) {
                    /// rectangle
                    Rectangle inboundRec = new Rectangle(&imgSurface);
                    inboundRec.drawFromPoints(shapePoints, red, green, blue, curr.bs);
                    nextAct = new Action(shapePoints,color, "rectangle");
                    state.addAction(nextAct);
                    writeln("i got a rectangle");
                } else if (curr.s == 3) {
                    /// triangle
                    Triangle inboundTri = new Triangle(&imgSurface);
                    inboundTri.drawFromPoints(shapePoints, red, green, blue, curr.bs);
                    nextAct = new Action(shapePoints,color, "triangle");
                    state.addAction(nextAct);
                    writeln("i got a triangle");
                } else if (curr.s == -10) {
                    state.undo();
                } else if (curr.s == 10) {
                    writeln("inbound redo");
                    writeln("size of redo: " ~ to!string(state.getRedoStack()));
                } else {
                    /// line
                    Line inboundLine = new Line(&imgSurface);
                    inboundLine.drawFromPoints(shapePoints, red, green, blue, curr.bs);
                    nextAct = new Action(shapePoints,color, "line");
                    state.addAction(nextAct);
                    writeln("i got a line");
                } 
        }}).start();
    }

    /***********************************
    * Name: redoMethod
    * Description: redo the latest action popped from the state. 
    */
    void redoMethod() {
        state.redo();
    }

    /***********************************
    * Name: buildShape
    * Description: Makes a shape that can be drawn from point coordinates. 
    * Params:    
        * packet = the packet being sent/received on the server 
    * Returns: A coordinate tuple array 
    */
    Tuple!(int, int)[] buildShape(Packet packet) {
        Tuple!(int, int)[] points;
        Tuple!(int, int) point1, point2, point3;
        point1[0] = packet.x;
        point1[1] = packet.y;
        point2[0] = packet.x2;
        point2[1] = packet.y2;
        point3[0] = packet.x3;
        point3[1] = packet.y3;
        points ~= point1;
        points ~= point2;
        if (packet.s == 3) {
            points ~= point3;
        }
        return points; 
    }

    /***********************************
    * Name: buildColor 
    * Description: get a color array from a packet 
    * Params:    
        * packet = the packet being sent or received on network 
    * Returns: an array of RGB values in int
    */
    int[3] buildColor(Packet packet) {
        int[3] colors;
        colors[0] = packet.r;
        colors[1] = packet.g;
        colors[2] = packet.b;
        return colors; 
    }

    /***********************************
    * Name: brushSizeChanger
    * Description: iterate through the available brushes by keystroke 
    * Params: 
        * curBrush = the current brush size 
    * Returns: the new brush size 
    */
    int brushSizeChanger(int curBrush){
        if (curBrush < 8) {
            curBrush += 2;
            writeln(curBrush);
        }
        else if (curBrush == 8){
            curBrush = 12;
        } else {
            curBrush = 2;
        }
        writeln("Changing to brush size: " , to!string(curBrush));
        return curBrush;
    }

    /***********************************
    * Name: colorChanger
    * Description: iterate through the available colors by keystroke 
    * Params: 
        * curColor = the current color 
    * Returns: the new color value 
    */
    int colorChanger(int curColor){
        if (curColor < 6) {
            writeln("CHANGE COLOR KEY PRESSED");
            curColor++;
        } else {
            curColor=1;
            writeln("CHANGE COLOR KEY PRESSED");
        }

        /// Create an array of names to display color name to the user 
        string[6] colorNameArr;
        colorNameArr = ["Red", "Orange", "Yellow", 
                                "Green", "Blue", "Violet"];
        writeln("Changing to color : ", colorNameArr[curColor - 1]);
        return curColor; 
    }

    /***********************************
    * Name: eraserToggle
    * Description: Turn on or off the eraser by button click or keystroke. 
    * Params: 
        * eraseBool = whether the eraser is currently on or off 
        * color = the color being used when eraser is activated
    */
    void eraserToggle(bool eraseBool, int color){
        int temp_color = 0;
        /// Activate eraser 
        if (eraseBool == false) {
            erasing = true;
            temp_color = color;
            color = -1;
            writeln("You selected: ERASER ACTIVATE");
        /// Deactivate eraser and restore previous color
        } else {
            erasing = false;
            color = temp_color;
            writeln("You selected: ERASER DEACTIVATE");
        }
    }


    /***********************************
    * Name: createMenu
    * Description: An encapsulation method that you can call only once in the application loop instead of calling each method individually 
    * Params: 
        * imgSurface = the surface to draw the menu on 
    */
    void createMenu(Surface imgSurface){
        ///Draw bottom bar of menu skeleton
        menuBarSetup(imgSurface);

        ///Setting up brush size button display (Button 1)
        button1Setup(imgSurface);

        ///Setting up color button display (Button 2)
        button2Setup(imgSurface);

        ///Setting up eraser button display (Button 3)
        button3Setup(imgSurface);

        ///Setting up shape button display (Button 4)
        button4Setup(imgSurface);

        ///Setting up undo button display (Button 5)
        button5Setup(imgSurface);

        ///Setting up redo button display (Button 6)
        button6Setup(imgSurface);
    }

    /***********************************
    * Name: menuBarSetup 
    * Description: Creates the bounding boxes for the menu buttons 
    * Params: 
        * imgSurface = the surface to draw the menu on 
    */
    void menuBarSetup(Surface imgSurface){
        /// Draw the bottom of the menu bar 
        int b1;
            for(b1 = 1; b1 <= 640; b1++){
                imgSurface.lerp(b1 - 1, 50, b1, 50, 2, 255, 255, 255);  
            }

        ///Draw divider bars for menu skeleton 
        int h1;

        /// 6 buttons divided by the window width 
        int h2 = 640/6;

        int h3;
        /// There needs to be 5 dividers, this is h1
        for (h1 = 1; h1 <= 5; h1++){
            int divX = h1 * h2;
            /// The dividers each need to be 50 pixels tall. that is h3
            for (h3 = 0; h3 < 50; h3++){
                imgSurface.lerp(divX - 1, h3, divX, h3+1, 2, 255, 255, 255);
            }
        }
    }

    /***********************************
    * Name: button1Setup  
    * Description: Draws the brush selection button by showing brushes to click on.
    * Params: 
        * imgSurface = the surface to draw the button on 
    */
    void button1Setup(Surface imgSurface){
    int bs;
            int bsStart = 15;
            int bs1;
            for (bs = 1; bs <= 5; bs++){
                for(bs1 = 0; bs1 <= bs * 2; bs1++){
                imgSurface.lerp(bsStart, 8 + 2 * bs, bsStart, 40 - 2 * bs, bs * 2, 255, 255, 255);
                }
            bsStart += bs * 4 + 6;
            }
    }

    /***********************************
    * Name: button2Setup  
    * Description: Draws the color selection button by showing the colors to click on. 
    * Params: 
        * imgSurface = the surface to draw the button on 
    */
    void button2Setup(Surface imgSurface){
        int cn;
        int cn1;
        int cnStart = 112;
        for (cn = 1; cn <= 6; cn++){
            colorValueSetter(cn);
            for (cn1 = 0; cn1 < 12; cn1++){
                cnStart++;
                imgSurface.lerp(cnStart, 8, cnStart, 40, 1, red, green, blue);
            }
        cnStart += 4;
        }
    }

    /***********************************
    * Name: button3Setup 
    * Description: creates the eraser button by drawing a simple eraser icon 
    * Params: 
        * imgSurface = the surface to draw the button on 
    */
    void button3Setup(Surface imgSurface){
        imgSurface.lerp(240, 40, 290, 40, 2, 224, 125, 19);
        imgSurface.lerp(230, 20, 275, 8, 1, 255, 255, 255);
        imgSurface.lerp(230, 20, 240, 40, 1, 255, 255, 255);
        imgSurface.lerp(275, 8, 285, 28, 1, 255, 255, 255);
        imgSurface.lerp(243, 17, 253, 37, 1, 255, 255, 255);
        imgSurface.lerp(240, 40, 285, 28, 1, 255, 255, 255);
    }

    /***********************************
    * Name: button4Setup  
    * Description: Draws the dividers and the shapes for the shape button
    * Params:
        * imgSurface = the surface to draw the button on
    */
    void button4Setup(Surface imgSurface){
        ///Horizontal line across button 4 
        int s1;
        int sStart = 320;
        for(s1 = 0; s1 < 106; s1++){
            imgSurface.lerp(sStart, 24, sStart, 24, 1, 255, 255, 255);
            sStart ++;
        }
        ///Vertical line down button 4
        int s11;
        for (s11 = 0; s11 < 50; s11++){
            imgSurface.lerp(372, s11, 372, s11, 1, 255, 255, 255);
        }
        ///Button 4 Top left: Line 
        imgSurface.lerp(330, 20, 355, 3, 1, 255, 255, 255);

        ///Button 4 Top Right: Rectangle 
        Rectangle menuRect = new Rectangle(&imgSurface);
        menuRect.fillRectangle(385, 410, 5, 15, 255, 255, 255);

        ///Button 4 Bottom left: Circle 
        Circle menuCirc = new Circle(&imgSurface);
        Tuple!(int, int) circPoint;
        circPoint= tuple(342, 36);
        menuCirc.fillCircle(circPoint, 8, 255, 255, 255);

        ///Button 4 Bottom right: Triangle 
        Triangle menuTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(385, 41);
        tp2 = tuple(395, 31);
        tp3 = tuple(405, 41);

        menuTri.fillTriangle(tp1, tp2, tp3, 1, 255, 255, 255);
    }

    /***********************************
    * Name: button5Setup  
    * Description: Draws the "undo" button in red 
    * Params: 
        * imgSurface = the surface to draw the button on 
    */
    void button5Setup(Surface imgSurface){
        /// Draw the red arrow 
        Rectangle undoRect = new Rectangle(&imgSurface);
        undoRect.fillRectangle(470, 495, 20, 30, 24, 20, 195);
        Triangle undoTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(450, 25);
        tp2 = tuple(470, 12);
        tp3 = tuple(470, 38);
        undoTri.fillTriangle(tp1, tp2, tp3, 1, 24, 20, 195);
    }

    /***********************************
    * Name: button6Setup  
    * Description: Draws the "redo" button in blue
    * Params: 
        * imgSurface = the surface to draw the button on 
    */
    void button6Setup(Surface imgSurface){
        /// Draw the blue arrow 
        Rectangle undoRect = new Rectangle(&imgSurface);
        undoRect.fillRectangle(560, 585, 20, 30, 224, 129, 19);
        Triangle undoTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(605, 25);
        tp2 = tuple(585, 12);
        tp3 = tuple(585, 38);
        undoTri.fillTriangle(tp1, tp2, tp3, 1, 224, 129, 19);
    }
}

/**
Test: Checks for the surface to be initialized to black RGB values or 0,0,0
*/
@("Initialization test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    /// Parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 0 &&
    s.PixelAt(1,1)[1] == 0 &&
    s.PixelAt(1,1)[2] == 0, "error bgr value at x,y is wrong!");
}

/**
Test: Checks for the surface to be initialized to black, change the pixel color of 1,1 to blue
*/
@("Single Blue Pixel test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.UpdateSurfacePixel(1,1, 255, 128, 32);
    /// Parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 255 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 32, "error bgr value at x,y is wrong!");
}

/**
Test: Checks for the surface to be initialized to black, change the pixel color of 1,1 to blue, verify its blue,
change it to red, ensure that the color of 1,1 is now red
*/
@("Change a pixel test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.UpdateSurfacePixel(1,1, 255, 128, 32);
    /// Parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 255 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 32, "error bgr value at x,y is wrong!");
    /// Change the color of the pixel and make sure the change takes
    s.UpdateSurfacePixel(1,1, 32, 128, 255);
    /// Parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 32 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 255, "error bgr value at x,y is wrong!");
}
