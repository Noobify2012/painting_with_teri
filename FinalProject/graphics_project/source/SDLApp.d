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
// #include SDL.h;
// include <SDL2/SDL.h>
import test_client;
import Packet : Packet;
import Deque : Deque;
import test_addr;
import shape_listener;
import drawing_utilities;
import mClient;
import Action : Action;
import state;

import Rectangle : Rectangle;
import Triangle : Triangle; 
import Circle : Circle;
import Line : Line;
// For printing the key pressed info
// void PrintKeyInfo( SDL_KeyboardEvent *key );

class SDLApp{

    /// global variable for sdl;
    const SDLSupport ret;
    TCPClient client = new TCPClient();

    /// RGB Values that get passed into drawing functions & methods
    /// Defaults to white if for some reason your colors are not working 
    ubyte red = 255;
    ubyte green = 255;
    ubyte blue = 255;

    bool erasing = false;
    auto traffic = new Deque!(Packet);
    Socket sendSocket;
    byte[Packet.sizeof] buffer;

    Packet inbound;
    bool tear_down = false;
    auto received = new Deque!(Packet);
    Action shapeAction;


    void MainApplicationLoop(){
        /// Create an SDL window
        SDL_Window* window= SDL_CreateWindow("A Teri Chadbourne Experience",
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
        /// Drawing flag for determining if we are 'drawing' (i.e. mouse has been pressed
        ///                                                but not yet released)
        bool drawing = false;

        bool change = false;
        bool networked = false;

        int brush = 1;
        
        int color = 1;
        
        int brushSize = 4;
        // bool erasing = false;
        int temp_color = 0;

        int prevX = -9999;
        int prevY = -9999;

        State state = new State(&imgSurface);

        DrawingUtility du = new DrawingUtility();
        ShapeListener sh = new ShapeListener();

        /// Intialize deque for storing traffic to send
        // auto traffic = new Deque!(Packet);
        // Socket sendSocket;
        // byte[Packet.sizeof] buffer;
        
        writeln("tear down : " ~ to!string(tear_down));
        
        Socket recieveSocket;
        // Deque traffic = new Deque!Packet;

        createMenu(imgSurface);

        Action act = new Action([], [red, green, blue], "stroke");
        brush = 2;
        // SDL_EnableUNICODE( 1 );

        /// Main application loop that will run until a quit event has occurred.
        /// This is the 'main graphics loop'

        

        while(runApplication){
            SDL_Event e;
            /// Handle events
            /// Events are pushed into an 'event queue' internally in SDL, and then
            /// handled one at a time within this loop for as many events have
            /// been pushed into the internal SDL queue. Thus, we poll until there
            /// are '0' events or a NULL event is returned.
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
                    //Button one: change brush size 
                    if (yPos < 50 && xPos < h2){
                        writeln("button1: Change brush size");

                        if (xPos > 10 && xPos < 18){
                            writeln("Brush Size 2");
                            brush = 2;
                        } 
                        else if (xPos > 20 && xPos < 29){
                            writeln("Brush Size 4");
                            brush = 4;
                        }
                        else if (xPos > 30 && xPos < 45){
                            writeln("Brush Size 6");
                            brush = 6;
                        }
                        else if (xPos > 50 && xPos < 65){
                            writeln("Brush Size 8");
                            brush = 8;
                        }
                        else if (xPos > 69 && xPos < 89){
                            writeln("Brush Size 12");
                            brush = 12;
                        }
                    }
                    //Button two: change brush color 
                    //**TECH DEBT: pull this out into a separate function with xpos args**
                    
                    if(yPos < 50 && xPos > h2 && xPos < h2 * 2){
                        if(xPos > 112 && xPos < 124){
                            writeln("You selected color RED");
                            color = 1;
                        }
                        else if(xPos > 130 && xPos < 142){
                            writeln("You selected color ORANGE");
                            color = 2;
                        }
                        else if(xPos > 146 && xPos < 158){
                            writeln("You selected color YELLOW");
                            color = 3;
                        }
                        else if(xPos > 162 && xPos < 174){
                            writeln("You selected color GREEN");
                            color = 4;
                        }
                        else if(xPos > 178 && xPos < 190){
                            writeln("You selected color BLUE");
                            color = 5;
                        }else if(xPos > 194 && xPos < 206){
                            writeln("You selected color VIOLET");
                            color = 6;
                        }
                        
                    }
                    //Button three:
                    //**TECH DEBT: pull this out into a separate function. Code is duplicate of key presses 
                    if(yPos < 50 && xPos > h2 * 2 + 1 && xPos < h2 * 3){
                        writeln("button3: Toggle Eraser");
                        if (erasing == false) {
                            erasing = true;
                            temp_color = color;
                            color = -1;
                            writeln("eraser active, value of temp_color: ", to!string(temp_color));
                        } else {
                            erasing = false;
                            color = temp_color;
                            writeln("Changing to color : " , to!string(color));
                        }
                    }
                    //Button four: Shape Activator 
                    // Splits the 4 quadrants of B4 into shape assignments  
                    if(yPos < 50 && xPos > h2 * 3 + 1 && xPos < h2 * 4){
                        writeln("button4: Shape Activate");
                        writeln("Drawing shape");
                        
                        string quadrant; 
                        //Top Left: Line
                        if(yPos < 24 && xPos < 373){
                            quadrant = "TL";
                        }
                        //Top Right: Rectangle 
                        else if(yPos < 24 && xPos > 373){
                            quadrant = "TR";
                        }
                        //Bottom Left: Circle 
                        else if(yPos > 24 && xPos < 373){
                            quadrant = "BL";
                        }
                        //Bottom Right: Triangle
                        else if(yPos > 24 && xPos > 373){
                            quadrant = "BR";
                        }

                        // ShapeListener sh = new ShapeListener(quadrant);
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                    }

                    //Button five: UNDO --- INCOMING: dependency: implement undo/redo
                    if(yPos < 50 && xPos > h2 * 4 + 1 && xPos < h2 * 5){
                        writeln("button5");
                    }
                    //Button six: REDO --- INCOMING: Dependency: implement undo/redo 
                    if(yPos < 50 && xPos > h2 * 5 + 1 && xPos < h2 * 6){
                        writeln("button6");
                    }
                    //END MENU BUTTON SELECTOR 

                }else if(e.type == SDL_MOUSEBUTTONUP){
                    if (drawing) {
                        act.setColor([cast(int) red, cast(int) green, cast(int) blue]);
                        state.addAction(act);

                        act = new Action([], [red, green, blue], "stroke");
                    }
                    drawing=false;
                    prevX = -9999;
                    prevY = -9999;
                } else if(e.type == SDL_MOUSEMOTION && drawing) {
                    /// Get position of the mouse when drawing
                    int xPos = e.button.x;
                    int yPos = e.button.y;

                    act.addPoint(tuple(xPos, yPos));
                    /// Loop through and update specific pixels
                    // NOTE: No bounds checking performed --
                    //       think about how you might fix this :)
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
                    //**Tech Debt: Change color without having to draw first**
                    for(int w=-brushSize; w < brushSize; w++){
                        for(int h=-brushSize; h < brushSize; h++){
                            if (color == 1 && !erasing) {
                                // Set brush color to red
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
                                // imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, 0, 0, 0);
                            }
                            /// Send change from user to deque
                            if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 52 && prevY > 52)
                                imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            
                            // Check if the client is networked
                            if(networked == true) {
                                Packet packet;
                                // packet = mClient.getChangeForServer(xPos+w,yPos+h, red, green, blue, 0, brushSize,0,0,0,0);
                                //if client networked then make sure that the next packet to send isn't equal to the last one(no sequential duplicate packets).
                                // if (traffic.size() > 0 ) {
                                //     if (packet != traffic.back() ) {
                                //         traffic.push_front(packet);
                                //     }
                                // } else {
                                //     traffic.push_front(packet);
                                // }
                            // }
                            }
                        }
                    }

                    /// This is where we draw the line!
                    /// --This is also imposing bounds for drawing lines - the xPos & yPos limitations
                    /// keep you from overflowing pixels
                    if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 50 && prevY > 51) {
                        Packet linePacket = mClient.getChangeForServer(prevX, prevY, red, green, blue, 4, brushSize, xPos, yPos,0,0);
                        Line newLine = new Line(&imgSurface);
                        newLine.drawFromPoints(buildShape(linePacket), red, green, blue, brushSize);
                        imgSurface.lerp(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                        if (networked == true) {
                            // client.sendDataToServer(linePacket);
                            traffic.push_front(linePacket);
                        }
                         writeln("are we hitting lerp?");
                    }
                    prevX = xPos;
                    prevY = yPos;
                    /// If keyboard is pressed check for change event

                } else if(e.type == SDL_KEYDOWN) { // Listener for button down - not in use yet
                    // writeln()
                    // PrintKeyInfo( &e.key );
                    // printf( ", Name: %s", SDL_GetKeyName( key.keysym.sym ) );
                    // if (e.key.keysym.sym == SDLK_b) {
                    //     // printf("Changing brush size");

                    // }
                    // printf( cast(string)(e.key.keysym.sym) , " key pressed ");
                    // printf( SDL_GetKeyNamse (e.key.keysym.sym ) , " key pressed ");

                } else if(e.type == SDL_KEYUP) {
                    printf("key released: ");
                    //, to!string(e.key.keysym.sym));
                    if (e.key.keysym.sym == SDLK_b){
                        //For each key press, cycle through the 3 brush sizes. 
                        brush = brushSizeChanger(brush);

                    } else if (e.key.keysym.sym == SDLK_c) {
                        /// Change color
                        // if (color < 3) {
                        //     color++;
                        // } else {
                        //     color=1;
                        // }
                        
                        //writeln("Changing to color : " , to!string(color));
                        color = colorChanger(color);
                        writeln("CHANGE COLOR KEYs PRESSED");


                    } else if (e.key.keysym.sym == SDLK_e) {
                        //Activate Eraser 
                        if (erasing == false) {
                            erasing = true;
                            temp_color = color;
                            color = -1;
                            writeln("eraser active, value of temp_color: ", to!string(temp_color));
                        } else {
                            erasing = false;
                            color = temp_color;
                            writeln("Changing to color : " , to!string(color));
                        }

                    } else if (e.key.keysym.sym == SDLK_n) {
                        if (networked == false) {
                            client.init();
                            getNewData();
                            writeln("started new listener");
                            networked = true;
                        } else {
                            tear_down = true;
                        }
                        
                    } else if (e.key.keysym.sym == SDLK_f) {
                        /// This is where we fill the shape once drawn!
                        writeln("Starting fill");
                        bool isFilled = false;

                        while (!isFilled) {
                        SDL_Event fill;
                            while (SDL_PollEvent(&fill)) {
                                if(fill.type == SDL_QUIT){
                                    runApplication= false;
                                    break;
                                } else if (fill.type == SDL_MOUSEBUTTONUP) {
                                    int fillStartX = fill.button.x, fillStartY = fill.button.y;
                                    du.dfs(fillStartX, fillStartY, &imgSurface, red, green, blue);
                                    isFilled = true;
                                }
                            }
                        }
                        writeln("Fill ended");

                    } else if (e.key.keysym.sym == SDLK_s) {
                        /// This is where we draw the shape when prompted!
                        writeln("Drawing shape");
                        writeln("Type 'r' for rectangle", "\nType 'c' for circle", 
                                "\nType 'l' for line", "\nType 'r' for rectangle");
                        // ShapeListener sh = new ShapeListener();

                        // sh.setRGB(red, green, blue);
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
                            //do triangle
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

                        ///unpack rgb values 
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
                    } else if (e.key.keysym.sym == SDLK_u) {
                        
                        state.undo();
                        if (networked) {
                            Packet undoPack = mClient.getChangeForServer(0,0,0,0,0, -10, 0,0,0,0,0);
                            client.sendDataToServer(undoPack);
                        }
                    } else if (e.key.keysym.sym == SDLK_r) {
                        state.redo();
                        if (networked) {
                            Packet rePack = mClient.getChangeForServer(0,0,0,0,0, 10, 0,0,0,0,0);
                            client.sendDataToServer(rePack);
                        }
                    }
                }
            }

            ///Networking Block:
            //if we have turned networking on, check if there is traffic and that we are not in the tear down process. 
            if (networked == true) {
                if (traffic.size > 0 && !tear_down) {
                    writeln(">");
                    //send traffic to the server
                    client.sendDataToServer(traffic.pop_back);
                } else if (tear_down) {
                    //initiate a grace full tear down with the server by sendings and empty packet. 
                    auto packet = mClient.getChangeForServer(-9999,-9999, 0, 0, 0,0,0,0,0,0,0);
                    client.sendDataToServer(packet);
                    //close the socket
                    client.closeSocket();
                    tear_down = false;
                    networked = false;
                // } else if (received.size() > 0 && !tear_down){
                } else if (received.size() > 0){
                    // if we have traffic that came in from the server, add it to the surface. 
                    // drawInbound(received, imgSurface, state);
                       drawInbound(received, imgSurface);

                } // else if (cast(int)shapeAction.getPoints.length != 0) {
                //     // int x1, x2, x3, y1, y2, y3;
                //     // for (int i = 0; i < shapeAction.getPoints.length; i++) {
                //     //     writeln("Array index positions: "  ~ to!string(shapeAction.getPoints[i]));
                //     // }
                //  }   
            }
            
            /// Blit the surace (i.e. update the window with another surfaces pixels
            ///                       by copying those pixels onto the window).
            SDL_BlitSurface(imgSurface.getSurface(),null,SDL_GetWindowSurface(window),null);
            /// Update the window surface
            SDL_UpdateWindowSurface(window);
            /// Delay for 16 milliseconds
            /// Otherwise the program refreshes too quickly
            SDL_Delay(16);
        }
        /// Destroy our window
        SDL_DestroyWindow(window);
    
    }

    void colorValueSetter(int colorNum) { 
        if (colorNum == 1) {
            // Set brush color to red
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
/**
    * Name: getNewData 
    * Description: Establishes a new thread with a listener to get all incoming changes when we are networked
    * Listens for incoming data from the server and adds it to the queue for inbound traffic to be added to the surface.
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

/**
    * Name: drawInbound 
    * Description: Adds all networked painting pixels and adds them to the users surface. 
    * Params:    
        * @param traffic: Deque of packets from the server that contains pixel changes from the server
        * @param imgSurface: The users image surface that needs to be updated
    * Creates a seperate thread and removes all of the packets of pixel changes from the server from the queue and adds them to the surface. 
    */
void drawInbound(Deque!(Packet) traffic, Surface imgSurface) {
// void drawInbound(Deque!(Packet) traffic, Surface imgSurface, State state) {
    // auto threads = ThreadBase.getAll(); 
    // writeln("Number of threads: " ~to!string(threads.length));    
    
        // int prevX = -9999;
        // int prevY = -9999;
        new Thread({
        while(traffic.size() > 0) {
            
                auto curr = traffic.pop_back();
                // writeln("and now here");
                //TODO: Fix order
                // int brushs = cast(int)(curr.bs & 0xff);
                red = cast(char)(curr.r & 0xff);
                blue = cast(char)(curr.b & 0xff);
                green = cast(char)(curr.g & 0xff);
                // writeln("Prevx : " ~ to!string(prevX) ~ " Prevy : " ~ to!string(prevY) ~  " curr.x : " ~ to!string(curr.x) ~  " curr.y : " ~ to!string(curr.y)~  " curr.bs : " ~ to!string(curr.bs) ~  " red : " ~ to!string(red) ~  " green : " ~ to!string(green) ~ " blue : " ~ to!string(blue));     
                // writeln("NEW RBG VALS:: " ~ to!string(convertBytetoUnsigned(curr.r))  ~ to!string(convertBytetoUnsigned(curr.g))~ to!string(convertBytetoUnsigned(curr.b)));
                // imgSurface.lerp(prevX, prevY, curr.x, curr.y, curr.bs, red, green, blue);
            
                // prevX = curr.x;
                // prevY = curr.y;
                Tuple!(int, int)[] shapePoints = buildShape(curr);
                if (curr.s == 0) {
                    imgSurface.UpdateSurfacePixel(curr.x, curr.y, curr.r, curr.g, curr.b);
                    writeln("i got a pixel");
                } else if (curr.s == 1) {
                    //circle
                    Circle inboundCircle = new Circle(&imgSurface);
                    inboundCircle.drawFromPoints(shapePoints, red, green, blue, 4);
                    writeln("i got a circle");
                } else if (curr.s == 2) {
                    //rectangle
                    Rectangle inboundRec = new Rectangle(&imgSurface);
                    inboundRec.drawFromPoints(shapePoints, red, green, blue, 4);
                    writeln("i got a rectangle");
                } else if (curr.s == 3) {
                    //triangle
                    Triangle inboundTri = new Triangle(&imgSurface);
                    inboundTri.drawFromPoints(shapePoints, red, green, blue, 4);
                    writeln("i got a triangle");
                } else if (curr.s == -10) {
                    // state.undo();
                } else if (curr.s == 10) {
                    // state.redo();
                } else {
                    //line
                    Line inboundLine = new Line(&imgSurface);
                    inboundLine.drawFromPoints(shapePoints, red, green, blue, 4);
                    writeln("i got a line");
                } 
        }}).start();

}

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

int colorChanger(int curColor){
    if (curColor < 6) {
        writeln("CHANGE COLOR BUTTON PRESSED");
        curColor++;
    } else {
        curColor=1;
        writeln("CHANGE COLOR BUTTON PRESSED");
    }

    string[6] colorNameArr;
    colorNameArr = ["Red", "Orange", "Yellow", 
                              "Green", "Blue", "Violet"];
    writeln("Changing to color : " , colorNameArr[curColor - 1]);
    return curColor; 
}

void createMenu(Surface imgSurface){
 /// **Tech debt: Create variables for window size so they can be changed proportionally**
        /// **Tech debt: Move menu creation into its own function**
        //Draw bottom bar of menu skeleton
        menuBarSetup(imgSurface);
        //Setting up brush size button display (Button 1)
        button1Setup(imgSurface);
        //Setting up color button display (Button 2)
        button2Setup(imgSurface);
        //Setting up eraser button display (Button 3)
        button3Setup(imgSurface);
        //Setting up shape button display (Button 4)
        button4Setup(imgSurface);
}


void menuBarSetup(Surface imgSurface){
    int b1;
        for(b1 = 1; b1 <= 640; b1++){
             imgSurface.lerp(b1 - 1, 50, b1, 50, 2, 255, 255, 255);  
        }

    //Draw divider bars for menu skeleton 
    int h1;
    int h2 = 640/6;
    int h3;
    //There needs to be 5 dividers, this is h1
    for (h1 = 1; h1 <= 5; h1++){
        int divX = h1 * h2;
        //The dividers each need to be 50 pixels tall. that is h3
        for (h3 = 0; h3 < 50; h3++){
            imgSurface.lerp(divX - 1, h3, divX, h3+1, 2, 255, 255, 255);
        }
    }
}

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

void button3Setup(Surface imgSurface){
    imgSurface.lerp(240, 40, 290, 40, 2, 224, 125, 19);
    imgSurface.lerp(230, 20, 275, 8, 1, 255, 255, 255);
    imgSurface.lerp(230, 20, 240, 40, 1, 255, 255, 255);
    imgSurface.lerp(275, 8, 285, 28, 1, 255, 255, 255);
    imgSurface.lerp(243, 17, 253, 37, 1, 255, 255, 255);
    imgSurface.lerp(240, 40, 285, 28, 1, 255, 255, 255);
}

void button4Setup(Surface imgSurface){
            //Horizontal line across button 4 
        int s1;
        int sStart = 320;
        for(s1 = 0; s1 < 106; s1++){
            imgSurface.lerp(sStart, 24, sStart, 24, 1, 255, 255, 255);
            sStart ++;
        }
        //Vertical line down button 4
        int s11;
        for (s11 = 0; s11 < 50; s11++){
            imgSurface.lerp(372, s11, 372, s11, 1, 255, 255, 255);
        }
        //Button 4 Top left: Line 
        imgSurface.lerp(330, 20, 355, 3, 1, 255, 255, 255);

        //Button 4 Top Right: Rectangle 
        Rectangle menuRect = new Rectangle(&imgSurface);
        menuRect.fillRectangle(385, 410, 5, 15, 255, 255, 255);

        //Button 4 Bottom left: Circle 
        Circle menuCirc = new Circle(&imgSurface);
        Tuple!(int, int) circPoint;
        circPoint= tuple(342, 36);
        menuCirc.fillCircle(circPoint, 8, 255, 255, 255);

        //Button 4 Bottom right: Triangle 
        Triangle menuTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(385, 41);
        tp2 = tuple(395, 31);
        tp3 = tuple(405, 41);

        menuTri.fillTriangle(tp1, tp2, tp3, 1, 255, 255, 255);
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
