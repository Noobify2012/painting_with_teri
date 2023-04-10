/// Import D standard libraries
import std.stdio;
import std.string;
import std.process;
import std.conv;
import std.socket;

/// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;
// #include SDL.h;
// include <SDL2/SDL.h>
import test_client;
import Packet : Packet;
import Deque : Deque;

import shape_listener;
import drawing_utilities;
// import server;


// For printing the key pressed info
// void PrintKeyInfo( SDL_KeyboardEvent *key );



class SDLApp{

    /// global variable for sdl;
    const SDLSupport ret;


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
        ubyte red = 255;
        ubyte green = 255;
        ubyte blue = 255;
        int brushSize = 4;
        bool erasing = false;
        int temp_color = 0;

        int prevX = -9999;
        int prevY = -9999;

        DrawingUtility du = new DrawingUtility();

        /// Intialize deque for storing traffic to send
        auto traffic = new Deque!(Packet);
        Socket socket;
        byte[Packet.sizeof] buffer;
        bool tear_down = false;
        // Deque traffic = new Deque!Packet;
        


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
                }else if(e.type == SDL_MOUSEBUTTONUP){
                    drawing=false;
                    prevX = -9999;
                    prevY = -9999;
                } else if(e.type == SDL_MOUSEMOTION && drawing){
                    /// Get position of the mouse when drawing
                    int xPos = e.button.x;
                    int yPos = e.button.y;
                    /// Loop through and update specific pixels
                    // NOTE: No bounds checking performed --
                    //       think about how you might fix this :)
                    if (brush == 1) {
                        brushSize = 4;
                    } else if (brush == 2) {
                        brushSize = 8;
                    } else {
                        brushSize = 16;
                    }

                    /// Change brush:
                    for(int w=-brushSize; w < brushSize; w++){
                        for(int h=-brushSize; h < brushSize; h++){
                            /// Set brush color to blue
                            if (color == 1 && !erasing) {
                                red = 255;
                                green = 128;
                                blue = 32;
                                // imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            } else if (color == 2 && !erasing) {
                                /// Set brush color to green
                                red = 32;
                                green = 255;
                                blue = 128;
                                // imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, 32, 255, 128);
                            } else if (color == 3 && !erasing) {
                                /// Set brush color to red
                                red = 128;
                                green = 32;
                                blue = 255;
                                // imgSurface.UpdateSurfacePixel(xPos+w,yPos+h,  128, 32, 255);
                            } else if (erasing) {
                                /// Erase: set color to black
                                red = 0;
                                green = 0;
                                blue = 0;
                                // imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, 0, 0, 0);
                            }
                            /// Send change from user to deque
                            imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            if(networked == true) {
                                Packet packet;
                                packet = test_client.getChangeForServer(xPos+w,yPos+h, red, green, blue);
                                // traffic = test_client.addToSend(traffic, packet);
                                traffic.push_front(packet);
                                // test_client.sendToServer(packet, socket);
                            }
                        }
                    }
                    /// This is where we draw the line!
                    if (prevX > -9999) {
                        // imgSurface.linearInterpolation(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                        imgSurface.lerp(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                    }
                    prevX = xPos;
                    prevY = yPos;
                    /// If keyboard is pressed check for change event
                } else if(e.type == SDL_KEYDOWN) { // Listener for button down - not in use yet
                    // writeln()
                    // PrintKeyInfo( &e.key );
                    // printf( ", Name: %s", SDL_GetKeyName( key.keysym.sym ) );
                    if (e.key.keysym.sym == SDLK_b) {
                        // printf("Changing brush size");

                    }
                    // printf( cast(string)(e.key.keysym.sym) , " key pressed ");
                    // printf( SDL_GetKeyNamse (e.key.keysym.sym ) , " key pressed ");


                } else if(e.type == SDL_KEYUP) {
                    printf("key released: ");
                    //, to!string(e.key.keysym.sym));
                    if (e.key.keysym.sym == SDLK_b) {
                        /// Change brush size
                        if (brush < 3) {
                            brush++;
                        } else {
                            brush=1;
                        }
                        writeln("Changing to brush size: " , to!string(brush));
                    } else if (e.key.keysym.sym == SDLK_c) {
                        /// Change color
                        if (color < 3) {
                            color++;
                        } else {
                            color=1;
                        }
                        writeln("Changing to color : " , to!string(color));
                    } else if (e.key.keysym.sym == SDLK_e) {
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
                            socket = test_client.initialize();
                            /// Perform initial handshake and test connect string
                            buffer = test_client.sendConnectionHandshake(socket);
                            networked = true;
                        } else {
                            networked = false;
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
                        ShapeListener sh = new ShapeListener();
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                    }
                    // } else if (e.key.keysym.sym == SDLK_h) {
                    //     server.run();
                    // }
                }
            }
            //if we have turned networking on, the client not the server
            if (networked == true) {
                // while(!tear_down) {
                    /// Check if there is traffic to send, if so send it, else listen
                    // writeln("size of traffic: " ~ to!string(traffic.size));
                    if(traffic.size > 0) {
                        /// Send action to server
                        test_client.sendToServer(traffic.pop_back, socket);
                        writeln("traffic sent");
                    }
                    //else {
                        /// Listen
                        // Packet inbound;
                        Packet inbound = test_client.recieveFromServer(socket, buffer);
                        writeln("traffic recieved");
                        /// If traffic recieved update surface.
                        imgSurface.UpdateSurfacePixel(inbound.x, inbound.y, inbound.r, inbound.g, inbound.b);
                        writeln("updated surface pixel");
                    // }
                // }

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

