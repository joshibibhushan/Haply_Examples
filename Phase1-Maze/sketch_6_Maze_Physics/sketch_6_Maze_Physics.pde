/**
 **********************************************************************************************************************
 * @file       Maze.pde
 * @author     Elie Hymowitz, Steve Ding, Colin Gallacher
 * @version    V4.0.0
 * @date       08-January-2021
 * @brief      Maze game example using 2-D physics engine
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */



/* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 



/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerCentimeter                 = 40.0;

/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0); 

/* World boundaries */
FWorld            world;
float             worldWidth                          = 25.0;  
float             worldHeight                         = 15.0; 

float             edgeTopLeftX                        = 0.0; 
float             edgeTopLeftY                        = 0.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

float             gravityAcceleration                 = 980; //cm/s2
/* Initialization of virtual tool */
HVirtualCoupling  s;

/* define maze blocks */
FBox              b1;
FBox              b2;
FBox              b3;
FBox              b4;
FBox              b5;
FBox              l1;

float lineThickness= 0.1;
  float widthTunnel = 1.1;
  float vThickness = 1.3;

/* define start and stop button */
FCircle           c1;
FCircle           c2;

/* define game ball */
FCircle           g2;
FBox              g1;

/* define game start */
boolean           gameStart                           = false;

/* text font */
PFont             f;

/* end elements definition *********************************************************************************************/  



/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 600);
  
  /* set font type and size */
  f                   = createFont("Arial", 12, true);

  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */
  haplyBoard          = new Board(this, "COM3", 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);
  
  widgetOne.add_actuator(1, CW, 2);
  widgetOne.add_actuator(2, CW, 1);
 
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  widgetOne.device_set_parameters();

  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
  
  /* Set maze barriers */
  /*b1                  = new FBox(1.0, 5.0);
  b1.setPosition(edgeTopLeftX+worldWidth/4.0-2, edgeTopLeftY+worldHeight/2+1.5); 
  b1.setFill(0);
  b1.setNoStroke();
  b1.setStaticBody(true);
  world.add(b1);
  
  b2                  = new FBox(1.0, 5.0);
  b2.setPosition(edgeTopLeftX+worldWidth/4.0, edgeTopLeftY+worldHeight/2-1.5); 
  b2.setFill(0);
  b2.setNoStroke();
  b2.setStaticBody(true);
  world.add(b2);
   
  b3                  = new FBox(1.0, 3.0);
  b3.setPosition(edgeTopLeftX+worldWidth/4.0+8, edgeTopLeftY+worldHeight/2+1.5); 
  b3.setFill(0);
  b3.setNoStroke();
  b3.setStaticBody(true);
  world.add(b3);
  
  b4                  = new FBox(1.0, 5.0);
  b4.setPosition(edgeTopLeftX+worldWidth/4.0+12, edgeTopLeftY+worldHeight/2-1.5); 
  b4.setFill(0);
  b4.setNoStroke();
  b4.setStaticBody(true);
  world.add(b4);
   
  b5                  = new FBox(3.0, 2.0);
  b5.setPosition(edgeTopLeftX+worldWidth/2.0, edgeTopLeftY+worldHeight/2.0+2);
  b5.setFill(0);
  b5.setNoStroke();
  b5.setStaticBody(true);
  world.add(b5);*/
   
  /* Set viscous layer */
  l1                  = new FBox(27,8);
  l1.setPosition(24.5/2,12);
  l1.setFill(150,150,255,80);
  l1.setDensity(100);
  l1.setSensor(true);
  l1.setNoStroke();
  l1.setStatic(true);
  l1.setName("Water");
  world.add(l1);
  
  
  
    FBox h11 = new FBox(3, lineThickness);
  h11.setPosition(2.27, edgeTopLeftY+2); 
  h11.setFill(94, 52, 224);
  h11.setNoStroke();
  h11.setStaticBody(true);
  world.add(h11);
  
  FBox h12 = new FBox(8, lineThickness);
  h12.setPosition(worldWidth/5.25+3+1.5,2); 
  h12.setFill(94, 52, 224);
  h12.setNoStroke();
  h12.setStaticBody(true);
  world.add(h12);
  
  FBox h13 = new FBox(4.5, lineThickness);
  h13.setPosition(7.4+worldWidth/2,2); 
  h13.setFill(94, 52, 224);
  h13.setNoStroke();
  h13.setStaticBody(true);
  world.add(h13);
  
  //Row 2
  FBox h21 = new FBox(12, lineThickness);
  h21.setPosition(worldWidth/5.25+2, 2+widthTunnel); 
  h21.setFill(94, 52, 224);
  h21.setNoStroke();
  h21.setStaticBody(true);
  world.add(h21);
  
  FBox h22 = new FBox(4.8, lineThickness);
  h22.setPosition(worldWidth/5.25+6, 2+widthTunnel); 
  h22.setFill(94, 52, 224);
  h22.setNoStroke();
  h22.setStaticBody(true);
  world.add(h22);
  
  FBox h23 = new FBox(4.2, lineThickness);
  h23.setPosition(worldWidth/5.25+7+ 2.9 + 2*widthTunnel, 2+widthTunnel); 
  h23.setFill(94, 52, 224);
  h23.setNoStroke();
  h23.setStaticBody(true);
  world.add(h23);
  
  FBox h24 = new FBox(1.5, lineThickness);
  h24.setPosition(8.5+ worldWidth/2, 2+widthTunnel); 
  h24.setFill(94, 52, 224);
  h24.setNoStroke();
  h24.setStaticBody(true);
  world.add(h24);
  
  //Row 3
  FBox h31 = new FBox(3.98, lineThickness);
  h31.setPosition(worldWidth/12.1+2*widthTunnel, 2+2*widthTunnel); 
  h31.setFill(94, 52, 224);
  h31.setNoStroke();
  h31.setStaticBody(true);
  world.add(h31);
  
  FBox h32 = new FBox(3.19, lineThickness);
  h32.setPosition(worldWidth/5.25+7+1.4, 2+2*widthTunnel); 
  h32.setFill(94, 52, 224);
  h32.setNoStroke();
  h32.setStaticBody(true);
  world.add(h32);

  FBox h33 = new FBox(2.5, lineThickness);
  h33.setPosition(10.5+worldWidth/2, 2+widthTunnel*4); 
  h33.setFill(94, 52, 224);
  h33.setNoStroke();
  h33.setStaticBody(true);
  world.add(h33);
  
  //Row 4
  FBox h41 = new FBox(3, lineThickness);
  h41.setPosition(2+widthTunnel*4, worldWidth-widthTunnel-1.14); 
  h41.setFill(94, 52, 224);
  h41.setNoStroke();
  h41.setStaticBody(true);
  world.add(h41);
  
  //Row 5
  FBox h51 = new FBox(3.7, lineThickness);
  h51.setPosition(11.4, 5.8); 
  h51.setFill(94, 52, 224);
  h51.setNoStroke();
  h51.setStaticBody(true);
  world.add(h51);
  
  FBox h52 = new FBox(1.5, lineThickness);
  h52.setPosition(15.4, 5.8); 
  h52.setFill(0,0,0);
  h52.setNoStroke();
  h52.setStaticBody(true);
  world.add(h52);
  
  //Row 6
  FBox h61 = new FBox(1.55, lineThickness);
  h61.setPosition(1.54, 8.16); 
  h61.setFill(94, 52, 224);
  h61.setNoStroke();
  h61.setStaticBody(true);
  world.add(h61);
  
  FBox h62 = new FBox(3.1, lineThickness);
  h62.setPosition(16.2, 7.28); 
  h62.setFill(94, 52, 224);
  h62.setNoStroke();
  h62.setStaticBody(true);
  world.add(h62);
  
  FBox h63 = new FBox(1.3, lineThickness);
  h63.setPosition(19.7, 7.3); 
  h63.setFill(0,0,0);
  h63.setNoStroke();
  h63.setStaticBody(true);
  world.add(h63);
  
  //Row 7
  FBox h71 = new FBox(2.68, lineThickness);
  h71.setPosition(worldWidth/17.9+2*widthTunnel, 9.5); 
  h71.setFill(94, 52, 224);
  h71.setNoStroke();
  h71.setStaticBody(true);
  world.add(h71);
  
  FBox h72 = new FBox(3.5, lineThickness);
  h72.setPosition(7.9, 9.2); 
  h72.setFill(94, 52, 224);
  h72.setNoStroke();
  h72.setStaticBody(true);
  world.add(h72);
  
  //Row 8
  FBox h81 = new FBox(3.5, lineThickness);
  h81.setPosition(7.9, 9.2+1.2); 
  h81.setFill(94, 52, 224);
  h81.setNoStroke();
  h81.setStaticBody(true);
  world.add(h81);
  
  FBox h82 = new FBox(2.5, lineThickness);
  h82.setPosition(19, 8.61); 
  h82.setFill(0,0,0);
  h82.setNoStroke();
  h82.setStaticBody(true);
  world.add(h82);
  
  FBox b83 = new FBox(2.5, lineThickness);
  b83.setPosition(23.1, 8.61); 
  b83.setFill(0,0,0);
  b83.setNoStroke();
  b83.setStaticBody(true);
  world.add(b83);
  
  //Row 9
  FBox h91 = new FBox(5.4, lineThickness);
  h91.setPosition(8.9, 9.2+2.5);  
  h91.setFill(94, 52, 224);
  h91.setNoStroke();
  h91.setStaticBody(true);
  world.add(h91);
  
  FBox h92 = new FBox(1.5, lineThickness);
  h92.setPosition(15.4, 9.2+2.5);  
  h92.setFill(94, 52, 224);
  h92.setNoStroke();
  h92.setStaticBody(true);
  world.add(h92);
  
 //Row 10
  FBox h101 = new FBox(12.8, lineThickness);
  h101.setPosition(11.25, 13); 
  h101.setFill(94, 52, 224);
  h101.setNoStroke();
  h101.setStaticBody(true);
  world.add(h101);
  
  
 //vertical line
 
 //Column 1
  FBox v11 = new FBox(lineThickness, 4);
  v11.setPosition(2.3, 6.19); 
  v11.setFill(0, 0, 0);
  v11.setNoStroke();
  v11.setStaticBody(true);
  world.add(v11);
  
  FBox v12 = new FBox(lineThickness, 2);
  v12.setPosition(2.3, 10.5); 
  v12.setFill(0, 0, 0);
  v12.setNoStroke();
  v12.setStaticBody(true);
  world.add(v12);
  
  //column 2
  FBox v21 = new FBox(lineThickness, 4);
  v21.setPosition(2.3+vThickness, 7.5); 
  v21.setFill(0, 0, 0);
  v21.setNoStroke();
  v21.setStaticBody(true);
  world.add(v21);
  
  FBox v22 = new FBox(lineThickness, 4);
  v22.setPosition(2.3+vThickness, 13); 
  v22.setFill(0, 0, 0);
  v22.setNoStroke();
  v22.setStaticBody(true);
  world.add(v22);
  
  //column 3
  FBox v31 = new FBox(lineThickness, 4);
  v31.setPosition(2.3+2*vThickness, 7.5); 
  v31.setFill(0, 0, 0);
  v31.setNoStroke();
  v31.setStaticBody(true);
  world.add(v31);
  
  FBox v32 = new FBox(lineThickness, 3.5);
  v32.setPosition(2.3+2*vThickness, 11.2); 
  v32.setFill(0, 0, 0);
  v32.setNoStroke();
  v32.setStaticBody(true);
  world.add(v32);
  
   //column 4
  FBox v41 = new FBox(lineThickness, 5);
  v41.setPosition(2.3+3*vThickness, 6.66);
  v41.setFill(0, 0, 0);
  v41.setNoStroke();
  v41.setStaticBody(true);
  world.add(v41);
  
  //column 5
  FBox v51 = new FBox(lineThickness, 4.5);
  v51.setPosition(7.8, 5.4);
  v51.setFill(0, 0, 0);
  v51.setNoStroke();
  v51.setStaticBody(true);
  world.add(v51);
  
  //column 6
  FBox v61 = new FBox(lineThickness, 1.1);
  v61.setPosition(9.59, 2.6);
  v61.setFill(0, 0, 0);
  v61.setNoStroke();
  v61.setStaticBody(true);
  world.add(v61);
  
  FBox v62 = new FBox(lineThickness, 1.1);
  v62.setPosition(9.59, 9.8);
  v62.setFill(0, 0, 0);
  v62.setNoStroke();
  v62.setStaticBody(true);
  world.add(v62);
  
  FBox v63 = new FBox(lineThickness, 5);
  v63.setPosition(9.59, 5.13);
  v63.setFill(0, 0, 0);
  v63.setNoStroke();
  v63.setStaticBody(true);
  world.add(v63);
  
  //column 7
  FBox v71 = new FBox(lineThickness, 1.1);
  v71.setPosition(11.6, 3.6);
  v71.setFill(0, 0, 0);
  v71.setNoStroke();
  v71.setStaticBody(true);
  world.add(v71);
  
  FBox v72 = new FBox(lineThickness, 5.5);
  v72.setPosition(11.6, 10.3);
  v72.setFill(0, 0, 0);
  v72.setNoStroke();
  v72.setStaticBody(true);
  world.add(v72);
  
  //column 8
  FBox v81 = new FBox(lineThickness, 5);
  v81.setPosition(13.2, 8.3);
  v81.setFill(0, 0, 0);
  v81.setNoStroke();
  v81.setStaticBody(true);
  world.add(v81);
  
  //column 9
  FBox v91 = new FBox(lineThickness, 1.3);
  v91.setPosition(14.7, 2.5);
  v91.setFill(0, 0, 0);
  v91.setNoStroke();
  v91.setStaticBody(true);
  world.add(v91);
  
  FBox v92 = new FBox(lineThickness, 1.7);
  v92.setPosition(14.7, 5);
  v92.setFill(0, 0, 0);
  v92.setNoStroke();
  v92.setStaticBody(true);
  world.add(v92);
  
  FBox v93 = new FBox(lineThickness, 4.5);
  v93.setPosition(14.7, 9.5);
  v93.setFill(0, 0, 0);
  v93.setNoStroke();
  v93.setStaticBody(true);
  world.add(v93);
  
  //column 10
  FBox v101 = new FBox(lineThickness, 3.2);
  v101.setPosition(16.2, 5.7);
  v101.setFill(0, 0, 0);
  v101.setNoStroke();
  v101.setStaticBody(true);
  world.add(v101);
  
  FBox v102 = new FBox(lineThickness, 3.15);
  v102.setPosition(16.2, 10.18);
  v102.setFill(0, 0, 0);
  v102.setNoStroke();
  v102.setStaticBody(true);
  world.add(v102);
  
  //column 11 
  FBox v111 = new FBox(lineThickness, 3.2);
  v111.setPosition(17.7, 5.7);
  v111.setFill(0, 0, 0);
  v111.setNoStroke();
  v111.setStaticBody(true);
  world.add(v111);
  
  FBox v112 = new FBox(lineThickness, 4.5);
  v112.setPosition(17.7, 10.8);
  v112.setFill(0, 0, 0);
  v112.setNoStroke();
  v112.setStaticBody(true);
  world.add(v112);
  
  FBox v113 = new FBox(lineThickness, 1.5);
  v113.setPosition(17.7, 1.2);
  v113.setFill(0, 0, 0);
  v113.setNoStroke();
  v113.setStaticBody(true);
  world.add(v113);
  
   //column 12 
  FBox v121 = new FBox(lineThickness, 4.3);
  v121.setPosition(19, 5.2);
  v121.setFill(0, 0, 0);
  v121.setNoStroke();
  v121.setStaticBody(true);
  world.add(v121);
  
  FBox v122 = new FBox(lineThickness, 4.48);
  v122.setPosition(19, 12);
  v122.setFill(0, 0, 0);
  v122.setNoStroke();
  v122.setStaticBody(true);
  world.add(v122);
  
  //column 13 
  FBox v131 = new FBox(lineThickness, 9.82);
  v131.setPosition(19+1.3, 8);
  v131.setFill(94, 52, 224);
  v131.setNoStroke();
  v131.setStaticBody(true);
  world.add(v131);
  
  //column 14 
  FBox v141 = new FBox(lineThickness, 3.4);
  v141.setPosition(19+2.8, 4.75);
  v141.setFill(94, 52, 224);
  v141.setNoStroke();
  v141.setStaticBody(true);
  world.add(v141);
  
  FBox v142 = new FBox(lineThickness, 4.4);
  v142.setPosition(19+2.8, 10.75);
  v142.setFill(94, 52, 224);
  v142.setNoStroke();
  v142.setStaticBody(true);
  world.add(v142);
  
  
 
  

//Main Destination  
  FPoly star                = new FPoly();
  /*star.vertex(0.7, 0);
  star.vertex(0.6, 0.2);
  star.vertex(0.8, 0.2);
  star.vertex(0.7, 0.35);
  star.vertex(0.8, 0.53);
  star.vertex(0.6, 0.53);
  star.vertex(0.5, 0.7);
  star.vertex(0.4, 0.53);
  star.vertex(0.2, 0.53);
  star.vertex(0.3, 0.35);
  star.vertex(0.2, 0.2);
  star.vertex(0.4, 0.2);*/
  
  star.vertex(1,-0.040);
  star.vertex(1.2, 0.4);
  star.vertex(1.6, 0.4);
  star.vertex(1.4, 0.7);
  star.vertex(1.6, 1.06);
  star.vertex(1.2, 1.06);
  star.vertex(1, 1.4);
  star.vertex(0.8, 1.06);
  star.vertex(0.4, 1.06);
  star.vertex(0.6, 0.7);
  star.vertex(0.4, 0.4);
  star.vertex(0.8, 0.4);
  
  //triangle(30, 75, 58, 20, 86, 75);
  
  star.setPosition(worldWidth-2.5, worldHeight/2-0.8);
  star.setFill(128, 0, 128);
  star.setNoStroke();
  star.setStaticBody(true);
  world.add(star); 
  
  
  
  
  
  
  
  /* Start Button */
  c1                  = new FCircle(0.8); // diameter is 2
  c1.setPosition(worldWidth/2 - 10, 1.3);
  c1.setFill(0, 255, 0);
  c1.setStaticBody(true);
  world.add(c1);
  
  /* Finish Button */
  c2                  = new FCircle(0.8);
  c2.setPosition(0,0);
  c2.setFill(0,0,0);
  c2.setStaticBody(true);
  c2.setSensor(true);
  world.add(c2);
  
  /* Game Box */
  g1                  = new FBox(1, 1);
  g1.setPosition(0, 0);
  g1.setDensity(80);
  g1.setFill(0,0,0);
  g1.setName("Widget");
  world.add(g1);
  
  /* Game Ball */
  g2                  = new FCircle(1);
  g2.setPosition(0, 0);
  g2.setDensity(80);
  g2.setFill(0,0,0);
  g2.setName("Widget");
  world.add(g2);
  
  /* Setup the Virtual Coupling Contact Rendering Technique */
  s                   = new HVirtualCoupling((0.75)); 
  s.h_avatar.setDensity(4); 
  s.h_avatar.setFill(255,0,0); 
  s.h_avatar.setSensor(true);

  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
  
  /* World conditions setup */
  world.setGravity((0.0), gravityAcceleration); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
  

 
  world.draw();
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  
  /* setup simulation thread to run at 1kHz */
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}
/* end setup section ***************************************************************************************************/



/* draw section ********************************************************************************************************/
void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  if(renderingForce == false){
    background(255);
    textFont(f, 22);
 
    if(gameStart){
      fill(0, 0, 0);
      textSize(10);
      textAlign(CENTER);
      text("Push the ball or square to the red circle", width/2, 40);
      textAlign(CENTER);
      text("Touch the green circle to reset", width/2, 60);
    
     /* b1.setFill(0, 0, 0);
      b2.setFill(0, 0, 0);
      b3.setFill(0, 0, 0);
      b4.setFill(0, 0, 0);
      b5.setFill(0, 0, 0);*/
    
    }
    else{
      fill(128, 128, 128);
      textAlign(CENTER);
      text("Touch the green circle to start the maze", width/2, 60);
    
      /*b1.setFill(255, 255, 255);
      b2.setFill(255, 255, 255);
      b3.setFill(255, 255, 255);
      b4.setFill(255, 255, 255);
      b5.setFill(255, 255, 255);*/
    }
  
    world.draw();
  }
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(posEE.copy().mult(200));  
    }
    
    s.setToolPosition(edgeTopLeftX+worldWidth/2-(posEE).x, edgeTopLeftY+(posEE).y-7); 
    s.updateCouplingForce();
 
 
    fEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    fEE.div(100000); //dynes to newtons
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
    
    if (s.h_avatar.isTouchingBody(c1)){
      gameStart = true;
     // g1.setPosition(2,8);
      //g2.setPosition(3,8);
      s.h_avatar.setSensor(false);
    }
  
    if(g1.isTouchingBody(c2) || g2.isTouchingBody(c2)){
      gameStart = false;
      s.h_avatar.setSensor(true);
    }
  
  
  
    /* Viscous layer codes */
    if (s.h_avatar.isTouchingBody(l1)){
      s.h_avatar.setDamping(400);
    }
    else{
      s.h_avatar.setDamping(10); 
    }
  
    if(gameStart && g1.isTouchingBody(l1)){
      g1.setDamping(20);
    }
  
    if(gameStart && g2.isTouchingBody(l1)){
      g2.setDamping(20);
    }
  
  
    /* Bouyancy of fluid on avatar and gameball section */
    if (g1.isTouchingBody(l1)){
      float b_s;
      float bm_d = g1.getY()-l1.getY()+l1.getHeight()/2; // vertical distance between middle of ball and top of water
    
      if (bm_d + g1.getWidth()/2 >= g1.getWidth()) { //if whole ball or more is submerged
        b_s = g1.getWidth(); // amount of ball submerged is ball size
      }
      else { //if ball is partially submerged
        b_s = bm_d + g1.getWidth()/2; // amount of ball submerged is vertical distance between middle of ball and top of water + half of ball size
      }
  
      g1.addForce(0,l1.getDensity()*sq(b_s)*gravityAcceleration*-1); // 300 is gravity force
   
    }
  
    if (g2.isTouchingBody(l1)){
      float b_s;
      float bm_d = g2.getY()-l1.getY()+l1.getHeight()/2; // vertical distance between middle of ball and top of water
    
      if (bm_d + g2.getSize()/2 >= g2.getSize()) { //if whole ball or more is submerged
        b_s = g2.getSize(); // amount of ball submerged is ball size
      }
      else { //if ball is partially submerged
        b_s = bm_d + g2.getSize()/2; // amount of ball submerged is vertical distance between middle of ball and top of water + half of ball size
      }
  
      g2.addForce(0,l1.getDensity()*sq(b_s)*gravityAcceleration*-1); // 300 is gravity force
     
    }
    /* End Bouyancy of fluid on avatar and gameball section */
  
  
    world.step(1.0f/1000.0f);
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/

/* Alternate bouyancy of fluid on avatar and gameball helper functions, comment out
 * "Bouyancy of fluid on avatar and gameball section" in simulation and uncomment 
 * the helper functions below to test
 */
 
/*
void contactPersisted(FContact contact){
  float size;
  float b_s;
  float bm_d;
  
  if(contact.contains("Water", "Widget")){
    size = 2*sqrt(contact.getBody2().getMass()/contact.getBody2().getDensity()/3.1415);
    bm_d = contact.getBody2().getY()-contact.getBody1().getY()+l1.getHeight()/2;
    
    if(bm_d + size/2 >= size){
      b_s = size;
    }
    else{
      b_s = bm_d + size/2;
    }
    
    contact.getBody2().addForce(0, contact.getBody1().getDensity()*sq(b_s)*300*-1);
    contact.getBody2().setDamping(20);
  }
  
}


void contactEnded(FContact contact){
  if(contact.contains("Water", "Widget")){
    contact.getBody2().setDamping(0);
  }
}
*/

/* End Alternate Bouyancy of fluid on avatar and gameball helper functions */

/* end helper functions section ****************************************************************************************/
