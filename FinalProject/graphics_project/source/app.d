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

/**
* Name: main 
* Description: Entry point to program.
*/
void main()
{
	/// Initialize SDL
	SDLInit newSDL = new SDLInit();  

	/// Create paint application
	SDLApp myApp = new SDLApp;  

	/// Run application
	myApp.MainApplicationLoop();  
}
