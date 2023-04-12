// import std.stdio;
// import std.typecons;

// import bindbc.sdl;
// import loader = bindbc.loader.sharedlib;
// import SDL_Surfaces :Surface;
// import SDL_Initial :SDLInit;
// import Point : Point;
// import SDL_Surfaces;

// class State {

//     Point[][] undoStack, redoStack;
//     int numUndo, numRedo;
//     Surface *surf;

//     this(Surface *surf) {
//         this.numUndo = 0;
//         this.numRedo = 0;
//         this.surf = surf;
//     }

//     ~this() {}

//     void addAction(Point[] action, Point[] counteraction) {

//         undoStack ~= counteraction;
//         redoStack ~= action;
//     }

//     void undo() {

//         if (undoStack.length > 0) {
            
//             Point[] undone = undoStack[undoStack.length - 1];
//             undoStack = undoStack[0 .. undoStack.length - 1];
//             for (int i = 0; i < undone.length; ++i) {
                
//                 Tuple!(int, int) coord = undone[i].getPoint();
//                 SDL_Color col = undone[i].getColor();

//                 this.surf.UpdateSurfacePixel(coord[0], coord[1], col.r, col.g, col.b);
//             }
//             ++numUndo;
//         } else {
            
//             writeln("Undo stack is empty -- No action taken");
//         }
//     }

//     void redo() {

//     }
// }