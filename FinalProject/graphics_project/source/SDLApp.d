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

                    }
                }
            }

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

    //void PrintKeyInfo( SDL_KeyboardEvent *key ){
    ///* Is it a release or a press? */
    //    if( key.type == SDL_KEYUP )
    //        printf( "Release:- " );
    //    else
    //        printf( "Press:- " );
    //
    //        /* Print the hardware scancode first */
    //        printf( "Scancode: 0x%02X", key.keysym.scancode );
    //        /* Print the name of the key */
    //        printf( ", Name: %s", SDL_GetKeyName( key.keysym.sym ) );
    //        /* We want to print the unicode info, but we need to make */
    //        /* sure its a press event first (remember, release events */
    //        /* don't have unicode info                                */
    //        if( key.type == SDL_KEYDOWN ){
    //            /* If the Unicode value is less than 0x80 then the    */
    //            /* unicode value can be used to get a printable       */
    //            /* representation of the key, using (char)unicode.    */
    //            printf(", Unicode: " );
    //        if( key.keysym.unicode < 0x80 && key.keysym.unicode > 0 ){
    //            printf( "%c (0x%04X)", cast(char)key.keysym.unicode,
    //        key.keysym.unicode );
    //    }
    //    else{
    //        printf( "? (0x%04X)", key.keysym.unicode );
    //        }
    //    }
    //    printf( "\n" );
    //    /* Print modifier info */
    //    PrintModifiers( key.keysym.mod );
    //    }
    //
    //    /* Print modifier info */
    ////void PrintModifiers( SDLMod mod ){
    //    void PrintModifiers( SDLMod mod ){
    //        printf( "Modifers: " );
    //
    //        /* If there are none then say so and return */
    //        if( mod == KMOD_NONE ){
    //            printf( "None\n" );
    //            return;
    //        }
    //
    //        /* Check for the presence of each SDLMod value */
    //        /* This looks messy, but there really isn't    */
    //        /* a clearer way.                              */
    //        if( mod & KMOD_NUM ) printf( "NUMLOCK " );
    //        if( mod & KMOD_CAPS ) printf( "CAPSLOCK " );
    //        if( mod & KMOD_LCTRL ) printf( "LCTRL " );
    //        if( mod & KMOD_RCTRL ) printf( "RCTRL " );
    //        if( mod & KMOD_RSHIFT ) printf( "RSHIFT " );
    //        if( mod & KMOD_LSHIFT ) printf( "LSHIFT " );
    //        if( mod & KMOD_RALT ) printf( "RALT " );
    //        if( mod & KMOD_LALT ) printf( "LALT " );
    //        if( mod & KMOD_CTRL ) printf( "CTRL " );
    //        if( mod & KMOD_SHIFT ) printf( "SHIFT " );
    //        if( mod & KMOD_ALT ) printf( "ALT " );
    //        printf( "\n" );
    //    }
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

