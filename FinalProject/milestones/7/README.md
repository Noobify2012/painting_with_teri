# Building Software

- [ ] Instructions on how to build your software should be written in this file
	- This is especially important if you have added additional dependencies.
	- Assume someone who has not taken this class (i.e. you on the first day) would have read, build, and run your software from scratch.
- You should have at a minimum in your project
	- [ ] A dub.json in a root directory
    	- [ ] This should generate a 'release' version of your software
  - [ ] Run your code with the latest version of d-scanner before commiting your code (could be a github action)
  - [ ] (Optional) Run your code with the latest version of clang-tidy  (could be a github action)

*Modify this file to include instructions on how to build and run your software. Specify which platform you are running on. Running your software involves launching a server and connecting at least 2 clients to the server.*

Platform: Apple Macbook Pro M1

required software:
DMD
Dub
SDL2

Navigating to the directory to run the client and server : 
In order to access the code for the client and server you will need 2 terminal windows. 

Starting the Client: 
In the client window, navigate to the graphics project directory located in FinalProject/graphics_project. 

For running on a Mac:
Run command 'dub' to load dependencies. If error message 'linker exited with status 1' encountered, run command 'export MACOSX_DEPLOYMENT_TARGET=11' and then run 'dub' again.

For running on a windows or Linux machine:
From the graphics_project directory, simply run the command: dub run
If you want to run the release version, run this: dub run --build=release 

Starting a painting party
When the SDL window appears, press 'n' to start to connect the client to the server. You will then have to switch back to the terminal window. In that window, you will be prompted
to enter the IP address in format ###.###.###.### and press the enter key. Then you will be asked to enter the port that the server is running on. The server tell you the address
and port when it start. When you connect to the server, you will start receiving data from the server upon successful connection. Otherwise, it will ask you to try again.

Starting the Server:
In the server window, navigate to the res directory withing FinalProject/graphics_project/res. Run the command rdmd mserver.d. The server will start and give you its ip address 
and port number for connecting.

Drawing freehand on the Canvas:
Using the mouse, select a color from the color button by clicking on the color you want and selecting a brush size in the brush pane. Then you can freely draw within the window. 

Drawing with the shape tool:
In order to draw one of the pre-defined shapes, either click on the shape button or press the "s" key. Then enter press either the c key for a circle, r for a rectangle, t for a 
triangle or l for a line. For a circle, you must click on the canvas 2 times(the top and bottom points of the circle). For a Rectangle you must also click on two points, the
first is the upper left hand corner and the second is the lower right hand corner. For a triangle, you must click 3 points which will be the 3 corners of the triangle. And for 
the line you must click 2 points, which will be the end points of the line. 

Erasing:
To erase part of your drawing you can either press the e key or the eraser button. Then like drawing you simply hold down the mouse while passing it over whatever you would
like to erase. To get out of the eraser either press the e key, select the eraser button or click on one of the colors in the color pallete. 

Undo/Redo Action:
To undo and action simply press the u key. To redo an action press the r key.
Note: Redo does not currently work when you are networked, you will have to redraw anything undone at this time.  

Ending a paint party:
There are 2 ways to end a paint party. The first is if you are the host and just want to shut down the server, you can simply go to the server window and press the combination 
of the control and c keys. This will tear down the server while allowing everyone to have their copy of the painting you did. 

The other way to leave is for a client to simply press the n button. This will allow the user to leave while others can continue on. If you are the last person in the server,
then the server must be torn down before the client can leave. This can be achieved by going to the server window and give the combination of the control and c keys. 

