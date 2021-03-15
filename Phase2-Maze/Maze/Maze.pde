/**
 **********************************************************************************************************************
 * @file       Maze.pde
 * @author     Bibhushan Joshi
 * @version    V4.0.0
 * @date       14/03/2021
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

/* define start and stop button */
FCircle           c1;
FBox           c2;

/* define game ball */
FCircle           g2;
FBox              g1;

/* define game start */
boolean           gameStart                           = false;
boolean           gameEnd                           = false;
PImage startImage; 
PImage cursorImage;


/*destination*/
PImage goalPostImage; 
PImage goalKeeperImage; 

/* text font */
PFont             f;
PFont             f1;

/*for walls*/
int wallNumber = 10;
FBox[] wall = new FBox[wallNumber];
//FBox l1 ;
Barrier barrier = new Barrier();

/*Create defenders*/
Defender defender1 = new Defender();
Defender defender2 = new Defender();
Defender defender3 = new Defender();
Defender defender4 = new Defender();

/* end elements definition *********************************************************************************************/  



/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 600);
  
  /* set font type and size */
  f                   = createFont("Arial", 16, true);
  f1                  = createFont("Adobe Gothic Std B", 16, true);
  
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
  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);
 
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  widgetOne.device_set_parameters();
  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
    /* Set maze barriers */
  barrier.add(world);
   
  /* Set viscous layer */
  l1                  = new FBox(27,2.5);
  l1.setPosition(24.5/2,13.4);
  l1.setFill(98,88,171,95);
  l1.setDensity(17);
  l1.setSensor(true);
  l1.setNoStroke();
  l1.setStatic(true);
  l1.setName("Water");
  world.add(l1);
  
  /* Start Button */
  startImage = loadImage("img/start_button.png");
  c1                  = new FCircle(1.2); // diameter is 2
  c1.setPosition(worldWidth-6, 1.85);
  c1.setFill(0, 255, 0,1);
  c1.setStaticBody(true);
  world.add(c1);
  
  /* Finish Button */
  goalPostImage = loadImage("img/goal_post_white.png");
  goalKeeperImage = loadImage("img/goalkeeper.png");
  c2                  = new FBox(3.7, 2.3);
  c2.setPosition(21.55,5.9);
  c2.setNoStroke();
  c2.setFill(0,0,0,1);

  c2.setStaticBody(true);
  c2.setSensor(true);
  world.add(c2);
  
  /* Game Box */
  g1                  = new FBox(1, 1);
  g1.setPosition(10, 2.8);
  g1.setDensity(10);
  g1.setFill(random(255),random(255),random(255));
  g1.setName("Widget");
  world.add(g1);
  
  /* Game Ball */
  g2                  = new FCircle(0.6);
  g2.setPosition(13, 2.8);
  g2.setDensity(20);
  g2.setFill(random(255),random(255),random(255));
  g2.setName("Widget");
  world.add(g2);
  
  /* Setup the Virtual Coupling Contact Rendering Technique */
  s                   = new HVirtualCoupling((0.75)); 
  smooth();
  cursorImage = loadImage("img/football2.png"); 
  cursorImage.resize((int)(hAPI_Fisica.worldToScreen(0.8)), (int)(hAPI_Fisica.worldToScreen(0.8)));
  s.h_avatar.attachImage(cursorImage); 
  
  
  
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
   if(gameEnd){
      background(0);
      textFont(f1, 30);
      textAlign(CENTER);
      text("Hurray !!!!", width/2, 250);
      text("You Won", width/2, height/2);
      textFont(f1, 12);
      text("Thank you for playing the game", width/2, height/2+50);
    }
    else{
      if(renderingForce == false){
          background(255);
          textFont(f, 22);
          //start Image
          image(startImage, 735, 50, 50, 50);
          
          barrier.hideWalls();
          //rectangle information
          stroke(0);
          fill(49,43,93);
          rect(800, 30, 290, 120);
          fill(255,255,255);
          textAlign(CENTER);
          text("Try to reach the", width-115, 60);
          text("GOAL POST", width-110, 95);
          textSize(12);
          text("Avoid the moving balls", width-110, 125);
          
          textSize(40);
          fill(0, 0, 0);
          textFont(f1, 22);
          text("Welcome to the Maze Game", width/2, 250);
          text("Hit Start", width/2, height/2);
          text("to run the game....", width/2, height/2+50);
          textSize(12);
          textAlign(CENTER);
          text("Start Button", 763, 125);
          g1.setFill(255,255,255);
          g1.setNoStroke();
          g2.setFill(255,255,255);
          g2.setNoStroke();
          
          
         if(gameStart){
            barrier.showWalls();
            image(goalPostImage, 790, 190, 143, 90.75);
            image(goalKeeperImage, 790, 300, 168, 171.8);
            g1.setFill(171,92,88);
            g1.setNoStroke();
            g2.setFill(171,92,88);
            g2.setNoStroke();
            //crete defender
            defender1.moveHorizontal(450,height/2+150,120); 
            defender2.moveVertical(150,195,120); 
            defender3.moveHorizontal(420,height/2+50,120); 
            defender4.moveVertical(500,185,90);
              
         }else{
            fill(128, 128, 128);
        }
        
        world.draw();
        
      }
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
      //s.setAvatarPosition(10,1);
      gameStart = true;
      g1.setPosition(10,2.8);
      g2.setPosition(13, 2.8);
      s.h_avatar.setSensor(false);
    }
    
    if (s.h_avatar.isTouchingBody(c2)){
      gameEnd= true;

      

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
