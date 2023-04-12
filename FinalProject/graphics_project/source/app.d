/// Run with: 'dub'

// Import D standard libraries
// import std.stdio;
// import std.string;
//
// Load the SDL2 library
// import bindbc.sdl;
// import loader = bindbc.loader.sharedlib;
import SDLApp : SDLApp;
import SDL_Initial: SDLInit;

/// Entry point to program
void main()
{
	SDLInit newSDL = new SDLInit();  /// Initializes SDL
	SDLApp myApp = new SDLApp;  /// Creates paint application
	myApp.MainApplicationLoop();  /// Runs application
}
