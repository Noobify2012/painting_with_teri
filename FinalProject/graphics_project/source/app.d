/// Run with: 'dub'

//// Import D standard libraries
//import std.stdio;
//import std.string;
//
//// Load the SDL2 library
//import bindbc.sdl;
//import loader = bindbc.loader.sharedlib;
import SDLApp : SDLApp;
import SDL_Initial: SDLInit;

// Entry point to program
void main()
{
	SDLInit newSDL = new SDLInit();
	SDLApp myApp = new SDLApp;
	myApp.MainApplicationLoop();
}
