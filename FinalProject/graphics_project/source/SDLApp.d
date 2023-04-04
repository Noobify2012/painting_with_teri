// Import D standard libraries
import std.stdio;
import std.string;
import std.process;
import std.conv;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import SDL_Surfaces :Surface;
import SDL_Initial :SDLInit;
//#include SDL.h;
import test_client;

import shapes;
import drawing_utilities;

//For printing the key pressed info
//void PrintKeyInfo( SDL_KeyboardEvent *key );



class SDLApp{

    // global variable for sdl;
    const SDLSupport ret;


    void MainApplicationLoop(){
        // Create an SDL window
        SDL_Window* window= SDL_CreateWindow("A Teri Chadbourne Experience",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
        SDL_WINDOW_SHOWN);
        // Load the bitmap surface
        Surface imgSurface = new Surface(0,640,480,32,0,0,0,0);

        // Flag for determing if we are running the main application loop
        bool runApplication = true;
        // Flag for determining if we are 'drawing' (i.e. mouse has been pressed
        //                                                but not yet released)
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

        //SDL_EnableUNICODE( 1 );

        // Main application loop that will run until a quit event has occurred.
        // This is the 'main graphics loop'
        while(runApplication){
            SDL_Event e;
            // Handle events
            // Events are pushed into an 'event queue' internally in SDL, and then
            // handled one at a time within this loop for as many events have
            // been pushed into the internal SDL queue. Thus, we poll until there
            // are '0' events or a NULL event is returned.
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
                }else if(e.type == SDL_MOUSEMOTION && drawing){
                    // retrieve the position
                    int xPos = e.button.x;
                    int yPos = e.button.y;
                    // Loop through and update specific pixels
                    // NOTE: No bounds checking performed --
                    //       think about how you might fix this :)
                    if (brush == 1) {
                        brushSize = 4;
                    } else if (brush == 2) {
                        brushSize = 8;
                    } else {
                        brushSize = 16;
                    }

                    for(int w=-brushSize; w < brushSize; w++){
                        for(int h=-brushSize; h < brushSize; h++){
                            //blue
                            if (color == 1 && !erasing) {
                                red = 255;
                                green = 128;
                                blue = 32;
                                //imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            } else if (color == 2 && !erasing) {
                                //green
                                red = 32;
                                green = 255;
                                blue = 128;
                                //imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, 32, 255, 128);
                            } else if (color == 3 && !erasing) {
                                //red
                                red = 128;
                                green = 32;
                                blue = 255;
                                //imgSurface.UpdateSurfacePixel(xPos+w,yPos+h,  128, 32, 255);
                            } else if (erasing) {
                                red = 0;
                                green = 0;
                                blue = 0;
                                //imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, 0, 0, 0);
                            }
                            imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            if(networked == true) {
                                // test_client.sendChangeToServer(xPos+w,yPos+h, red, green, blue);
                            }
                        }
                    }
                    if (prevX > -9999) {
                        imgSurface.linearInterpolation(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                    }
                    prevX = xPos;
                    prevY = yPos;
                    //if keyboard is pressed check for change event
                } else if(e.type == SDL_KEYDOWN) {
                    //writeln()
                    //PrintKeyInfo( &e.key );
                    //printf( ", Name: %s", SDL_GetKeyName( key.keysym.sym ) );
                    if (e.key.keysym.sym == SDLK_b) {
                        //printf("Changing brush size");

                    }
                    //printf( cast(string)(e.key.keysym.sym) , " key pressed ");
                    //printf( SDL_GetKeyNamse (e.key.keysym.sym ) , " key pressed ");


                } else if(e.type == SDL_KEYUP) {
                    printf("key released: ");
                    //, to!string(e.key.keysym.sym));
                    if (e.key.keysym.sym == SDLK_b) {
                        if (brush < 3) {
                            brush++;
                        } else {
                            brush=1;
                        }
                        writeln("Changing to brush size: " , to!string(brush));
                    } else if (e.key.keysym.sym == SDLK_c) {
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
                            // test_client.main();
                            networked = true;
                        } else {
                            networked = false;
                        }
                        
                    } else if (e.key.keysym.sym == SDLK_f) {
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
                                    du.dfs(fillStartX, fillStartY, &imgSurface);
                                    isFilled = true;
                                }
                            }
                        }
                        writeln("Fill ended");
                    }
                }
            }

            Shape sh = new Shape();

            sh.drawShape();

            // Blit the surace (i.e. update the window with another surfaces pixels
            //                       by copying those pixels onto the window).
            SDL_BlitSurface(imgSurface.getSurface(),null,SDL_GetWindowSurface(window),null);
            // Update the window surface
            SDL_UpdateWindowSurface(window);
            // Delay for 16 milliseconds
            // Otherwise the program refreshes too quickly
            SDL_Delay(16);
        }

        // Destroy our window
        SDL_DestroyWindow(window);

    }
}

///Test: Checks for the surface to be initialized to black RGB values or 0,0,0
@("Initialization test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    //parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 0 &&
    s.PixelAt(1,1)[1] == 0 &&
    s.PixelAt(1,1)[2] == 0, "error bgr value at x,y is wrong!");
}

///Test: Checks for the surface to be initialized to black, change the pixel color of 1,1 to blue
@("Single Blue Pixel test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.UpdateSurfacePixel(1,1, 255, 128, 32);
    //parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 255 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 32, "error bgr value at x,y is wrong!");
}

///Test: Checks for the surface to be initialized to black, change the pixel color of 1,1 to blue, verify its blue,
///change it to red, ensure that the color of 1,1 is now red
@("Change a pixel test")
unittest{
    SDLInit app = new SDLInit();
    Surface s = new Surface(0,640,480,32,0,0,0,0);
    s.UpdateSurfacePixel(1,1, 255, 128, 32);
    //parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 255 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 32, "error bgr value at x,y is wrong!");
    //change the color of the pixel and make sure the change takes
    s.UpdateSurfacePixel(1,1, 32, 128, 255);
    //parse values of new data struct
    assert(	s.PixelAt(1,1)[0] == 32 &&
    s.PixelAt(1,1)[1] == 128 &&
    s.PixelAt(1,1)[2] == 255, "error bgr value at x,y is wrong!");
}

