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


    /**
    Starts when you run the application and ends automatically 
    when you destroy the window. This is the main loop which 
    runs all of the primary app functionality. 
    **/
    void MainApplicationLoop(){
        /// Create an SDL window
        SDL_Window* window= SDL_CreateWindow("The Teri Chadbourne Experience",
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
        /// Drawing flag for determining if we are 'drawing' 
        bool drawing = false;

        bool change = false;
        bool networked = false;

        ///Defaults 
        int brush = 1;
        int color = 1;
        int brushSize = 4;
        int prevX = -9999;
        int prevY = -9999;

        State state = new State(&imgSurface);

        DrawingUtility du = new DrawingUtility();
        ShapeListener sh = new ShapeListener(&state);

        /// Intialize deque for storing traffic to send
        auto traffic = new Deque!(Packet);
        Socket sendSocket;
        byte[Packet.sizeof] buffer;
        
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
                    /// Button one: change brush size 
                    if (yPos < 50 && xPos < h2){
                        if (xPos > 10 && xPos < 18){
                            writeln("You selected: BRUSH SIZE 2");
                            brush = 2;
                        } 
                        else if (xPos > 20 && xPos < 29){
                            writeln("You selected: BRUSH SIZE 4");
                            brush = 4;
                        }
                        else if (xPos > 30 && xPos < 45){
                            writeln("You selected: BRUSH SIZE 6");
                            brush = 6;
                        }
                        else if (xPos > 50 && xPos < 65){
                            writeln("You selected: BRUSH SIZE 8");
                            brush = 8;
                        }
                        else if (xPos > 69 && xPos < 89){
                            writeln("You selected: BRUSH SIZE 12");
                            brush = 12;
                        }
                    }

                    /// Button two: change brush color                     
                    if(yPos < 50 && xPos > h2 && xPos < h2 * 2){
                        if(erasing == true){
                            writeln("ERASER: Deactivated");
                            erasing = false;
                        }
                        if(xPos > 112 && xPos < 124){
                            writeln("You selected: color RED");
                            color = 1;
                        }
                        else if(xPos > 130 && xPos < 142){
                            writeln("You selected: color ORANGE");
                            color = 2;
                        }
                        else if(xPos > 146 && xPos < 158){
                            writeln("You selected: color YELLOW");
                            color = 3;
                        }
                        else if(xPos > 162 && xPos < 174){
                            writeln("You selected: color GREEN");
                            color = 4;
                        }
                        else if(xPos > 178 && xPos < 190){
                            writeln("You selected: color BLUE");
                            color = 5;
                        }else if(xPos > 194 && xPos < 206){
                            writeln("You selected: color VIOLET");
                            color = 6;
                        }  
                    }

                    /// Based on color selected, update the RGB values using colorValueSetter
                    if (color == 1 && !erasing) {
                        /// Set brush color to red
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
                    }
                    
                    /// Button three: Eraser Activator/Deactivator
                    if(yPos < 50 && xPos > h2 * 2 + 1 && xPos < h2 * 3){
                        eraserToggle(erasing, color);
                    }

                    /// Button four: Shape Activator 
                    /// Splits the 4 quadrants of B4 into shape assignments  
                    if(yPos < 50 && xPos > h2 * 3 + 1 && xPos < h2 * 4){
                        string quadrant; 
                    
                        /// Top Left: Line
                        if(yPos < 24 && xPos < 373){
                            writeln("You selected: Draw LINE");
                            writeln("LINE: Click start and end points");
                            quadrant = "TL";
                        }
                        /// Top Right: Rectangle 
                        else if(yPos < 24 && xPos > 373){
                            writeln("You selected: Draw RECTANGLE");
                            writeln("RECTANGLE: Click two corner points");
                            quadrant = "TR";
                        }
                        /// Bottom Left: Circle 
                        else if(yPos > 24 && xPos < 373){
                            writeln("You selected: Draw CIRCLE");
                            writeln("CIRCLE: Click two points");
                            quadrant = "BL";
                        }
                        /// Bottom Right: Triangle
                        else if(yPos > 24 && xPos > 373){
                            writeln("You selected: Draw TRIANGLE");
                            writeln("TRIANGLE: Click three corner points");
                            quadrant = "BR";
                        }

                        /// Send the selected shape to the ShapeListener so the user can draw it. 
                        ShapeListener sh = new ShapeListener(quadrant, brushSize);
                        sh.drawShape(&imgSurface, brush, red, green, blue);
                    }

                    /// Button five: UNDO --- INCOMING: dependency: implement undo/redo
                    if(yPos < 50 && xPos > h2 * 4 + 1 && xPos < h2 * 5){
                        writeln("You selected: UNDO");
                        /// UNDO FUNCTION HERE 
                    }
                    /// Button six: REDO --- INCOMING: Dependency: implement undo/redo 
                    if(yPos < 50 && xPos > h2 * 5 + 1 && xPos < h2 * 6){
                        writeln("You selected: REDO");
                        /// REDO FUNCTION HERE 
                    }
                 /// **END MENU BUTTON SELECTOR**

                }else if(e.type == SDL_MOUSEBUTTONUP){
                    if (drawing) {
                        state.addAction(act);

                        act = new Action([], [red, green, blue], "stroke");
                    }
                    drawing=false;
                    prevX = -9999;
                    prevY = -9999;
                } else if(e.type == SDL_MOUSEMOTION && drawing){
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

                    /// Send information to deque for network 
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
                                act.setColor([cast(int) red, cast(int) green, cast(int) blue]);
                            }
                            /// Send change from user to deque
                            if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 52 && prevY > 52)
                                imgSurface.UpdateSurfacePixel(xPos+w,yPos+h, red, green, blue);
                            
                            // Check if the client is networked
                            if(networked == true) {
                                Packet packet;
                                packet = mClient.getChangeForServer(xPos+w,yPos+h, red, green, blue, 0, brushSize);
                                //if client networked then make sure that the next packet to send isn't equal to the last one(no sequential duplicate packets).
                                if (traffic.size() > 0 ) {
                                    if (packet != traffic.back() ) {
                                        traffic.push_front(packet);
                                    }
                                } else {
                                    traffic.push_front(packet);
                                }
                            // }
                            }
                        }
                    }

                    /// This is where we draw the line!
                    /// --This is also imposing bounds for drawing lines - the xPos & yPos limitations
                    ///   keep you from overflowing pixels
                    if (prevX > -9999 && xPos > 1 && xPos < 637 && yPos > 53 && prevY > 54) {
                        imgSurface.lerp(prevX, prevY, xPos, yPos, brushSize, red, green, blue);
                    }
                    prevX = xPos;
                    prevY = yPos;
                    
                /// If keyboard is pressed check for change event
                } else if(e.type == SDL_KEYDOWN) { 
                    // Wait for key to be lifted before we do anything. 
                } else if(e.type == SDL_KEYUP) {
                    writeln("key released: ");
                    //, to!string(e.key.keysym.sym));th
                    if (e.key.keysym.sym == SDLK_b){
                        /// For each key press, cycle through the 3 brush sizes. 
                        brush = brushSizeChanger(brush);

                    } else if (e.key.keysym.sym == SDLK_c) {
                        /// Pressing c changes the color 
                        color = colorChanger(color);

                    } else if (e.key.keysym.sym == SDLK_e) {
                        writeln("E");
                        eraserToggle(erasing, color);

                    } else if (e.key.keysym.sym == SDLK_n) {
                        /// When you press the n key, you want to join a network 
                        if (networked == false) {
                            client.init();
                            getNewData();
                            writeln("started new listener");
                            networked = true;
                        } else {
                            tear_down = true;
                        }

                    } else if (e.key.keysym.sym == SDLK_s) {
                        /// When you press the S key, you activate shape listener 
                        writeln("S");
                        writeln("SHAPE MENU: \nType 'r' for rectangle", "\nType 'c' for circle", 
                                "\nType 'l' for line", "\nType 'r' for rectangle");
                        // ShapeListener sh = new ShapeListener();

                        sh.setRGB(red, green, blue);
                        sh.drawShape(&imgSurface, brushSize, red, green, blue);
                    } else if (e.key.keysym.sym == SDLK_u) {
                        state.undo();
                    } else if (e.key.keysym.sym == SDLK_r) {
                        state.redo();
                    }
                    // } else if (e.key.keysym.sym == SDLK_h) {
                    //     server.run();
                    // }
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
                    auto packet = mClient.getChangeForServer(-9999,-9999, 0, 0, 0,0,0);
                    client.sendDataToServer(packet);
                    //close the socket
                    client.closeSocket();
                    tear_down = false;
                    networked = false;
                // } else if (received.size() > 0 && !tear_down){
                } else if (received.size() > 0){
                    // if we have traffic that came in from the server, add it to the surface. 
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

    /**
    Sets the RGB values for each color. 
    *NOTE* For some reason, our app's Red and Blue values are swapped when compared with real RGB values 
    **/
    void colorValueSetter(int colorNum) { 
        if (colorNum == 1) {
            /// Set brush color to red
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
                writeln("inbound x: " ~ to!string(inbound.x) ~ " inbound y: " ~ to!string(inbound.y));
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
            
                imgSurface.UpdateSurfacePixel(curr.x, curr.y, curr.r, curr.g, curr.b);            
        }}).start();

}


    /**
     Change the brush size selected. 
     Accessed by typing letter "b"
    **/ 
    int brushSizeChanger(int curBrush){
        if (curBrush < 8) {
            curBrush += 2;
            writeln(curBrush);
        } else if (curBrush == 8){
            curBrush = 12;
        } else {
            /// reset to first brush
            curBrush = 2;
        }
        writeln("Changing to brush size: " , to!string(curBrush));
        return curBrush;
    }

    /**
    Change the color selected.
    Accessed by typing the letter "c"
    **/
    int colorChanger(int curColor){
        writeln("C");
        /// Increment color 
        if (curColor < 6) {
            curColor++;
        /// Reset to first color when you reach the end
        } else {
            curColor=1;   
        }

        string[6] colorNameArr;
        colorNameArr = ["Red", "Orange", "Yellow", 
                        "Green", "Blue", "Violet"];
        writeln("Changing to color : " , colorNameArr[curColor - 1]);
        return curColor; 
    }

    /**
    Method that activates or deactivates the eraser function. 
    Accessed by pressing "E" key or by pressing button 3. 
    **/
    void eraserToggle(bool eraseBool, int color){
        int temp_color = 0;
        /// Activate eraser 
        if (eraseBool == false) {
            erasing = true;
            temp_color = color;
            color = -1;
            writeln("You selected: ERASER ACTIVATE");
        /// Deactivate eraser and restore previous color
        } else {
            erasing = false;
            color = temp_color;
            writeln("You selected: ERASER DEACTIVATE");
        }
    }

    /** 
    This sets up the entire menu by calling methods that create the structure and each button. 
    Taking out this function will remove the entire menu. 
    **/
    void createMenu(Surface imgSurface){
    /// **Tech debt: Create variables for window size so they can be changed proportionally**
        /// Draw bars of menu skeleton
        menuBarSetup(imgSurface);
        /// Setting up brush size button display (Button 1)
        button1Setup(imgSurface);
        /// Setting up color button display (Button 2)
        button2Setup(imgSurface);
        /// Setting up eraser button display (Button 3)
        button3Setup(imgSurface);
        /// Setting up shape button display (Button 4)
        button4Setup(imgSurface);
        /// Setting up undo button display (Button 5)
        button5Setup(imgSurface);
        /// Setting up redo button display (Button 6)
        button6Setup(imgSurface);
    }

    /** 
    This creates the white lines that divide the buttons 
    from the rest of the screen and draws the 5 button dividers  
    **/
    void menuBarSetup(Surface imgSurface){
        int b1;
        /// Draw bottom bar that separates menu from drawing space 
        for(b1 = 1; b1 <= 640; b1++){
            imgSurface.lerp(b1 - 1, 50, b1, 50, 2, 255, 255, 255);  
        }

        /// Draw divider bars for menu skeleton 
        int h1;
        int h2 = 640/6;
        int h3;
        /// There needs to be 5 dividers, this is what h1 iterates over 
        for (h1 = 1; h1 <= 5; h1++){
            int divX = h1 * h2;
            /// The dividers each need to be 50 pixels tall. that is h3
            for (h3 = 0; h3 < 50; h3++){
                imgSurface.lerp(divX - 1, h3, divX, h3+1, 2, 255, 255, 255);
            }
        }
    }

    /**
    Sets up the brush selector button, draws 5 different lines showing each brush size 
    **/
    void button1Setup(Surface imgSurface){
        int bs;
        int bsStart = 15;
        int bs1;
        /// Draw the lines at size 2, 4, 6, 8, 12 in the loop
        for (bs = 1; bs <= 5; bs++){
            for(bs1 = 0; bs1 <= bs * 2; bs1++){
            imgSurface.lerp(bsStart, 8 + 2 * bs, bsStart, 40 - 2 * bs, bs * 2, 255, 255, 255);
            }
        bsStart += bs * 4 + 6;
        }
    }

    /**
    Sets up the color changer button, iterates through all 6 colors to draw 6 lines and draw them 
    **/
    void button2Setup(Surface imgSurface){
        int cn;
        int cn1;
        int cnStart = 112;
        /// Iterate through the colors, draw a line of each color 
        for (cn = 1; cn <= 6; cn++){
            colorValueSetter(cn);
            for (cn1 = 0; cn1 < 12; cn1++){
                cnStart++;
                imgSurface.lerp(cnStart, 8, cnStart, 40, 1, red, green, blue);
            }
        cnStart += 4;
        }
    }

    /**
    Sets up the eraser button, 
    this is drawing the image of a simple eraser icon
    that is erasing a blue line. 
    **/
    void button3Setup(Surface imgSurface){
        /// Draw the blue line 
        imgSurface.lerp(240, 40, 290, 40, 2, 224, 125, 19);

        /// Draw the white eraser 
        imgSurface.lerp(230, 20, 275, 8, 1, 255, 255, 255);
        imgSurface.lerp(230, 20, 240, 40, 1, 255, 255, 255);
        imgSurface.lerp(275, 8, 285, 28, 1, 255, 255, 255);
        imgSurface.lerp(243, 17, 253, 37, 1, 255, 255, 255);
        imgSurface.lerp(240, 40, 285, 28, 1, 255, 255, 255);
    }

    /**
    Sets up the shapes button
    draws a grid to divide button into 4 sections
    and then draws each shape so the user can choose one. 
    **/
    void button4Setup(Surface imgSurface){
        /// Horizontal line across button 4 
        int s1;
        int sStart = 320;
        for(s1 = 0; s1 < 106; s1++){
            imgSurface.lerp(sStart, 24, sStart, 24, 1, 255, 255, 255);
            sStart ++;
        }

        /// Vertical line down button 4
        int s11;
        for (s11 = 0; s11 < 50; s11++){
            imgSurface.lerp(372, s11, 372, s11, 1, 255, 255, 255);
        }

        /// Button 4 Top left: Line 
        imgSurface.lerp(330, 20, 355, 3, 1, 255, 255, 255);

        /// Button 4 Top Right: Rectangle 
        Rectangle menuRect = new Rectangle(&imgSurface);
        menuRect.fillRectangle(385, 410, 5, 15, 255, 255, 255);

        /// Button 4 Bottom left: Circle 
        Circle menuCirc = new Circle(&imgSurface);
        Tuple!(int, int) circPoint;
        circPoint= tuple(342, 36);
        menuCirc.fillCircle(circPoint, 8, 255, 255, 255);

        /// Button 4 Bottom right: Triangle 
        Triangle menuTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(385, 41);
        tp2 = tuple(395, 31);
        tp3 = tuple(405, 41);
        menuTri.fillTriangle(tp1, tp2, tp3, 1, 255, 255, 255);
    }

    /**
    Sets up the Undo button, 
    this method draws a red undo or go back arrow
    which points to the left. 
    **/
    void button5Setup(Surface imgSurface){
        /// Draw the red arrow 
        Rectangle undoRect = new Rectangle(&imgSurface);
        undoRect.fillRectangle(470, 495, 20, 30, 24, 20, 195);
        Triangle undoTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(450, 25);
        tp2 = tuple(470, 12);
        tp3 = tuple(470, 38);
        undoTri.fillTriangle(tp1, tp2, tp3, 1, 24, 20, 195);
    }

    /**
    Sets up the Redo button, 
    this method draws a blue redo or go forward arrow
    which points to the right. 
    **/
    void button6Setup(Surface imgSurface){
        /// Draw the blue arrow 
        Rectangle undoRect = new Rectangle(&imgSurface);
        undoRect.fillRectangle(560, 585, 20, 30, 224, 129, 19);
        Triangle undoTri = new Triangle(&imgSurface);
        Tuple!(int, int) tp1, tp2, tp3;
        tp1 = tuple(605, 25);
        tp2 = tuple(585, 12);
        tp3 = tuple(585, 38);
        undoTri.fillTriangle(tp1, tp2, tp3, 1, 224, 129, 19);
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
