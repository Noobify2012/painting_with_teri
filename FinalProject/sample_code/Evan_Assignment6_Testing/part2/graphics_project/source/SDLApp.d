import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import surface: Surface;

class SDLApp {

  private {
    const static SDLSupport ret;
    static Surface surf;
  }

  shared static this() {

    // Load the SDL libraries from bindbc-sdl
	  // on the appropriate operating system
    version(Windows){
      writeln("Searching for SDL on Windows");
		  this.ret = loadSDL("SDL2.dll");
	  }
    version(OSX){
      writeln("Searching for SDL on Mac");
      this.ret = loadSDL();
    }
    version(linux){ 
      writeln("Searching for SDL on Linux");
      this.ret = loadSDL();
    }

    // Error if SDL cannot be loaded
    if(this.ret != sdlSupport){
      writeln("error loading SDL library");
      
      foreach( info; loader.errors){
        writeln(info.error,':', info.message);
      }
    }
    if(this.ret == SDLSupport.noLibrary){
      writeln("error no library found");    
    }
    if(this.ret == SDLSupport.badLibrary){
      writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
    }

    // Initialize SDL
    if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
      writeln("SDL_Init: ", fromStringz(SDL_GetError()));
    }

    this.surf = new Surface(640, 480);
  }

  shared static ~this() {
    SDL_Quit();
    writeln("Ending application--good bye!");
  }

  void mainApplicationLoop() {

    SDL_Window* window = SDL_CreateWindow("D SDL Painting",
                                          SDL_WINDOWPOS_UNDEFINED,
                                          SDL_WINDOWPOS_UNDEFINED,
                                          640,
                                          480, 
                                          SDL_WINDOW_SHOWN
                                          );
    
    // isRunning controls the main loop. It will run if isRunning is true
    // isDrawing controls whether we draw. There must be mouseclick to draw
    bool isRunning = true;
    bool isDrawing = false;

    while (isRunning) {
      SDL_Event e;
      while(SDL_PollEvent(&e) !=0){
        if(e.type == SDL_QUIT){
          isRunning= false;
        }
        else if(e.type == SDL_MOUSEBUTTONDOWN){
          isDrawing=true;
        }else if(e.type == SDL_MOUSEBUTTONUP){
          isDrawing=false;
        }else if(e.type == SDL_MOUSEMOTION && isDrawing){
          // retrieve the position
          int xPos = e.button.x;
          int yPos = e.button.y;
          // Loop through and update specific pixels
          // NOTE: No bounds checking performed --
          //       think about how you might fix this :)
          int brushSize=4;
          for(int w=-brushSize; w < brushSize; w++){
            for(int h=-brushSize; h < brushSize; h++){
              surf.UpdateSurfacePixel(xPos + w, yPos + h);
            }
          }
        }
      }
      // Blit the surace (i.e. update the window with another surfaces pixels
      //                       by copying those pixels onto the window).
      surf.blit(window);
      // SDL_BlitSurface(imgSurface,null,SDL_GetWindowSurface(window),null);
      // Update the window surface
      SDL_UpdateWindowSurface(window);
      // Delay for 16 milliseconds
      // Otherwise the program refreshes too quickly
      // SDL_Delay(2);
    }

    // Destroy our window
    SDL_DestroyWindow(window);
  }

}