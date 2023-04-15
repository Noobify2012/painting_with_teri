/// Import D standard libraries
import std.stdio;
import std.string;
import std.process;
import std.conv;
import std.socket;
import std.parallelism;
import core.thread.osthread;

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


// For printing the key pressed info
// void PrintKeyInfo( SDL_KeyboardEvent *key );



class SDLApp{

    /// global variable for sdl;
    const SDLSupport ret;
    TCPClient client;

    ubyte red = 255;
    ubyte green = 255;
    ubyte blue = 255;


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
        
        bool button1pressed, button2pressed, button3pressed, 
             button4pressed, button5pressed, button6pressed = false;

        int color = 1;
        
        int brushSize = 4;
        bool erasing = false;
        int temp_color = 0;

        int prevX = -9999;
        int prevY = -9999;

        DrawingUtility du = new DrawingUtility();

        /// Intialize deque for storing traffic to send
        auto traffic = new Deque!(Packet);
        Socket sendSocket;
        byte[Packet.sizeof] buffer;
        bool tear_down = false;
        writeln("tear down : " ~ to!string(tear_down));
        
        Socket recieveSocket;
        // Deque traffic = new Deque!Packet;
        
        /// **Tech debt: Create variables for window size so they can be changed proportionally**
        /// **Tech debt: Move menu creation into its own function**
        //Draw bottom bar of menu skeleton
        brushSize = 2;
        int b1;
        for(b1 = 1; b1 <= 640; b1++){
             imgSurface.lerp(b1 - 1, 50, b1, 50, brushSize, red, green, blue);  
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
                imgSurface.lerp(divX - 1, h3, divX, h3+1, brushSize, red, green, blue);
            }
        }

        //Setting up brush size button display
        int bs;
        int bsStart = 15;
        int bs1;
        for (bs = 1; bs <= 5; bs++){
            for(bs1 = 0; bs1 <= bs * 2; bs1++){
            imgSurface.lerp(bsStart, 8 + 2 * bs, bsStart, 40 - 2 * bs, bs * 2, red, green, blue);
            writeln(bsStart);
            }
            bsStart += bs * 4 + 6;
        }


        //Setting up color button display 
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

        brushSize = 4;
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

                    ///**BEGIN MENU BUTTON SELECTOR**
                    //Button one: change brush size 
                    if (yPos < 50 && xPos < h2){
                        writeln("button1: Change brush size");
                        //button1pressed = true; 
                        //brush = brushSizeChanger(brush);
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
                        //writeln("button2: Change Color");
                        //button2pressed = true; 
                        //color = colorChanger(color);
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
                        //button3pressed = true; 
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
                    // Either split this button into 4 buttons or have instructions pop up onto screen 
                    if(yPos < 50 && xPos > h2 * 3 + 1 && xPos < h2 * 4){
                        writeln("button4: Shape Activate");
                        writeln("Drawing shape");
                        writeln("Type 'r' for rectangle", "\nType 'c' for circle", 
                                "\nType 'l' for line", "\nType 'r' for rectangle");
                        ShapeListener sh = new ShapeListener();
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                    }
                    //Button five: UNDO --- INCOMING: dependency: implement undo/redo
                    if(yPos < 50 && xPos > h2 * 4 + 1 && xPos < h2 * 5){
                        writeln("button5");
                        //button5pressed = true; 
                    }
                    //Button six: REDO --- INCOMING: Dependency: implement undo/redo 
                    if(yPos < 50 && xPos > h2 * 5 + 1 && xPos < h2 * 6){
                        writeln("button6");
                        //button6pressed = true; 
                    }
                    //END MENU BUTTON SELECTOR 

                }else if(e.type == SDL_MOUSEBUTTONUP){
                    drawing=false;
                    prevX = -9999;
                    prevY = -9999;
                } else if(e.type == SDL_MOUSEMOTION && drawing) {
                    /// Get position of the mouse when drawing
                    int xPos = e.button.x;
                    int yPos = e.button.y;

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

                            if(networked == true) {
                                Packet packet;
                                packet = mClient.getChangeForServer(xPos+w,yPos+h, red, green, blue);
                                // writeln("Input values x: " ~to!string(xPos+w) ~ " y: " ~ to!string(yPos+h) ~ " r: " ~to!string(red) ~ " g: " ~ to!string(green) ~ " b: " ~ to!string(blue));
                                // writeln("Packet values x: " ~to!string(packet.x) ~ " y: " ~ to!string(packet.y) ~ " r: " ~to!string(packet.r) ~ " g: " ~ to!string(packet.g) ~ " b: " ~ to!string(packet.b));
                                // traffic = test_client.addToSend(traffic, packet);
                                if (traffic.size() > 0 ) {
                                    if (packet != traffic.back() ) {
                                        traffic.push_front(packet);
                                    }
                                } else {
                                    traffic.push_front(packet);
                                }
                                // test_client.sendToServer(packet, sendSocket);
                            }
                        }
                    }

                    /// This is where we draw the line!
                    /// --This is also imposing bounds for drawing lines - the xPos & yPos limitations
                    /// keep you from overflowing pixels
                    if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 50 && prevY > 51) {
                        imgSurface.lerp(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                        //  writeln("are we hitting lerp?");
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
                            /// Set up the socket and connection to server
                            // sendSocket = test_client.initialize();
                            // /// Perform initial handshake and test connect string
                            // auto address = test_addr.find();
                            // auto port = test_addr.findPort();
                            // // recieveSocket =
                            // buffer = test_client.sendConnectionHandshake(sendSocket);  // FIX ALL THIS


                            client = new TCPClient();
                            networked = true;
                        } else {
                            tear_down = true;
                            writeln("do the tear down");
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
                        ShapeListener sh = new ShapeListener();
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                    }
                    // } else if (e.key.keysym.sym == SDLK_h) {
                    //     server.run();
                    // }
                }
            }

            auto received = new Deque!(Packet);
            //if we have turned networking on, the client not the server
            if (networked == true) {
                // while(!tear_down) {
                    /// Check if there is traffic to send, if so send it, else listen
                    // writeln("size of traffic: " ~ to!string(traffic.size));
                    // Packet inbound = client.receiveDataFromServer();
                    //     // writeln("traffic recieved down here");
                    // received.push_front(inbound);

            		// Spin up the new thread that will just take in data from the server
                new Thread({
                        if (!tear_down) {
                            Packet inbound = client.receiveDataFromServer();
                            received.push_front(inbound);
                        } 
                        }).start();

                if (traffic.size > 0 && !tear_down) {

                    writeln(">");
                    client.sendDataToServer(traffic.pop_back);
                    writeln("are we sending to server?");

                    // received.push_front(client.run(traffic.pop_back));  // FIX

                    
                    // if(traffic.size > 0) {
                    //     /// Send action to server

                    //     received.push_front(client.run(traffic.pop_back));  // FIX
                    //     // writeln("traffic sent");
                    //     // Packet inbound = client.receiveDataFromServer();
                    //     // writeln("traffic recieved up here");
                    //     // received.push_front(inbound);
                    // }
                        
                    //else {
                        // Listen
                        // Packet inbound;
                        // Packet inbound = test_client.recieveFromServer(socket, buffer);
                        // writeln("traffic recieved");
                        /// If traffic recieved update surface.
                        // imgSurface.UpdateSurfacePixel(inbound.x, inbound.y, inbound.r, inbound.g, inbound.b);
                        // writeln("updated surface pixel");
                    //}
                    // else {
                    //     //listen
                    //     // Packet inbound;
                        
                    // }
                // }
                } else if (tear_down) {
                    auto packet = mClient.getChangeForServer(-9999,-9999, 0, 0, 0);
                    client.sendDataToServer(packet);
                    client.closeSocket();
                    writeln("we should have closed the socket.");
                    tear_down = false;
                    networked = false;
                    
                }
                while (received.size() > 0) {
                    //draw the packets
                    writeln("do i get here?");
                    drawInbound(received, imgSurface);
                }
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
}

void drawInbound(Deque!(Packet) traffic, Surface imgSurface) {
    int prevX = -9999;
    int prevY = -9999;
    while(traffic.size() > 0) {
        auto curr = traffic.pop_back();
        writeln("and now here");
        //TODO: Fix order
        imgSurface.UpdateSurfacePixel(curr.x, curr.y, curr.r, curr.g, curr.b);
        // imgSurface.lerp(prevX, prevY,curr.x, curr.y, 1, curr.r, curr.g, curr.b);
    }

}

int brushSizeChanger(int curBrush){
    if (curBrush < 3) {
        curBrush++;
        writeln(curBrush);
    } else {
        curBrush=1;
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



// void runClient(Deque traffic, Socket socket, Bool tear_down) {
//     //if the client is running, loop
    


// }

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
