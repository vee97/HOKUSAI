// VERSION WITH BOAT ADDED

// Import libraries
import processing.video.*;
import processing.sound.*;
import SimpleOpenNI.*;
import java.util.Map;
import java.util.Iterator;

Movie title;
Movie sceneOne;
Movie sceneTwo;
Movie sceneThree;
SoundFile music;
SoundFile waveSFX;

int[] userList;

int timer;
int start;
float volume;
float volume2;

float opacity;
float moveBigWave;
float moveLowWave;

//boat rotation angle and speed
float angle=0;
float offset = 0.02;
PImage boat1;
PImage boat2;

PImage bg;
PImage bigWave;
PImage lowWave;
PImage fuji;
PImage highWave;
float loop=0; 

//// Kinect Callibration
// User MinZ = 400
// UserMaxZ = 1800

// UserMinX = -1000
// UserMaxX =1000

int userMinX = -1000;
int userMaxX = 1000;

int userMinZ = 600;
int userMaxZ = 2300;

// SimpleOpenNI
SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
color[]       userClr = new color[]{ color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

// HANDS3D
int handVecListSize = 30;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();


// MOUSE INTERACTION
int PARTICLE_NUM = 100;
float PARTICLE_RADIOUS = 1.5;
float PARTICLE_MAX_SPEED = 10.0;
float PARTICLE_MAX_ACCELERATION = 0.7;
float PARTICLE_SPEED_VARIANT = 0.2;

Particle[] particles;


void setup()
{
  // 1280 x 800 resolution
  // add surface mapwork library

  fullScreen(P3D);
  //size(1280, 1024, P3D);
  //size(displayWidth, displayHeight, P3D);

  // MOUSE INTERACTION
  particles = new Particle[PARTICLE_NUM];
  for (int i = 0; i < PARTICLE_NUM; i++) {
    particles[i] = new Particle();
  }

  music = new SoundFile(this, "music.wav");
  //music.play();
  waveSFX = new SoundFile(this, "wave2.mp3");
  //waveSFX.play();
  music.loop();  //play the file on repeat
  waveSFX.amp(0.0);
  waveSFX.loop();  //play the file on repeat
  //waveSFX.play();
  //music.amp(0.0);


  //// Images
  bg = loadImage("background.png");
  bigWave = loadImage("wave_layers_high.png");
  lowWave = loadImage("wave13.png");
  fuji = loadImage("wave_layers_fuji.png");
  highWave=loadImage("wave.png");
  boat1=loadImage("ship1.png");
  boat2=loadImage("ship3.png");

  //// Quote Videos
  //sceneOne= new Movie(this, "sceneOne.mp4");
  sceneOne= new Movie(this, "combinedver.mp4");
  title= new Movie(this, "open.mp4");
  sceneTwo= new Movie(this, "sceneTwo.mp4");
  sceneThree= new Movie(this, "sceneThree.mp4");

  //timer testing
  text(timer, 20, 20);
  start=millis();

  //// Kinect
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  // enable hands + gesture generation
  //context.enableHand();
  //context.startGesture(SimpleOpenNI.GESTURE_WAVE);

  // set how smooth the hand capturing should be
  //context.setSmoothingHands(.5);

  stroke(255, 255, 255);
  smooth();
}


void draw()
{
  translate(width/2, height/2, 0);

  // update the cam
  context.update();

  pushMatrix();
  translate(width-width/2, -height/2); 
  scale(-1.0, 1.0); 

  //timer
  timer=millis()-start;

  // RESOLUTION 1024 x 768
  //float move = map(com.x, userMinX, userMaxX, 10, 1020);

  // MOVE WITH KINECT
  moveBigWave = map(com.x, userMinX, userMaxX, 1024, -1000);
  moveLowWave = map(com.x, userMinX, userMaxX, 800, 0);

  // PROTOTYPING WITH MOUSE
  //moveBigWave = map(mouseX, userMinX, userMaxX, -1000, 1024);
  //moveLowWave = map(mouseX, userMinX, userMaxX, 0, 800);



  //// KINECT - draw the 3d point depth map
  int[]   depthMap = context.depthMap();
  int[]   userMap = context.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  //translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud
  beginShape(POINTS);
  for (int y=0; y < context.depthHeight(); y+=steps)
  {
    for (int x=0; x < context.depthWidth(); x+=steps)
    {
      index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = context.depthMapRealWorld()[index];
        if (userMap[index] == 0)
          stroke(100); 
        else
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);        

        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  } 
  endShape();

  // draw the skeleton if it's available
  userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      //drawSkeleton(userList[i]);

      // draw the center of mass
      if (context.getCoM(userList[i], com))
      {
        stroke(100, 255, 0);
        strokeWeight(1);
        beginShape(LINES);
        vertex(com.x - 15, com.y, com.z);
        vertex(com.x + 15, com.y, com.z);

        vertex(com.x, com.y - 15, com.z);
        vertex(com.x, com.y + 15, com.z);

        vertex(com.x, com.y, com.z - 15);
        vertex(com.x, com.y, com.z + 15);
        endShape();

        fill(0, 255, 100);
        text(Integer.toString(userList[i]), com.x, com.y, com.z);
      }
  }    

  if (userList.length == 0) {
    title();
    offset=0;
    //background(0);
  } else {
    sceneOne();

    if (opacity<255) {
      opacity = opacity + 10;
      fade();
    }
    // CALL ALL FUNCTIONS
    fuji();
    bigWave();
    lowWave();
    boats();
    for (Particle particle : particles) {
      particle.display();
      particle.update(moveBigWave, height/2);
    }
    checkUsers();
  }
  popMatrix();


  //// HANDS3D  
  //// draw the tracked hands
  //if (handPathList.size() > 0)  
  //{    
  //  Iterator itr = handPathList.entrySet().iterator();     
  //  while (itr.hasNext())
  //  {
  //    Map.Entry mapEntry = (Map.Entry)itr.next(); 
  //    int handId =  (Integer)mapEntry.getKey();
  //    ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
  //    PVector p;

  //    pushStyle();
  //    stroke(userClr[ (handId - 1) % userClr.length ]);
  //    noFill();           
  //    Iterator itrVec = vecList.iterator(); 
  //    beginShape();
  //    while ( itrVec.hasNext() ) 
  //    { 
  //      p = (PVector) itrVec.next(); 
  //      vertex(p.x, p.y, p.z);
  //    }
  //    endShape();   

  //    stroke(userClr[ (handId - 1) % userClr.length ]);
  //    strokeWeight(4);
  //    p = vecList.get(0);
  //    point(p.x, p.y, p.z);


  //    //imageMode(CORNER);
  //    //bigWave.resize(688, 363);
  //    ////image(bigWave, mouseX-680, height-600);
  //    //image(bigWave, p.x, p.y);

  //    //for (Particle particle : particles) {
  //    //  particle.display();
  //    //  particle.update(com.x, com.y);
  //    //}
  //    popStyle();
  //  }
  //}

  //text("hands: " + handPathList.size(), 30, 70);
  
  // draw the kinect cam
  //context.drawCamFrustum();
}

// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------

// UserMaxZ = 1800
// User MinZ = 400

// UserMaxX =1000
// UserMinX = -1000

void movieEvent(Movie m) {
  m.read();
}

//// HANDS3D
//// hand events

//void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
//{
//  println("onNewHand - handId: " + handId + ", pos: " + pos);

//  ArrayList<PVector> vecList = new ArrayList<PVector>();
//  vecList.add(pos);

//  handPathList.put(handId, vecList);
//}

//void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
//{
//  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );

//  ArrayList<PVector> vecList = handPathList.get(handId);
//  if (vecList != null)
//  {
//    vecList.add(0, pos);
//    if (vecList.size() >= handVecListSize)
//      // remove the last point 
//      vecList.remove(vecList.size()-1);
//  }
//}

//void onLostHand(SimpleOpenNI curContext, int handId)
//{
//  println("onLostHand - handId: " + handId);

//  handPathList.remove(handId);
//}

//// -----------------------------------------------------------------
//// gesture events

//void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
//{
//  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

//  context.startTrackingHand(pos);

//  int handId = context.startTrackingHand(pos);
//  println("hands tracked: " + handId);
//}

//// FUNCTIONS TO DISPLAY IMAGES

void fade() {
  tint(255, opacity);
}

void fuji() {
  imageMode(CORNER);
  fuji.resize(999, 909);
  image(fuji, 100, height-925);
}

void bigWave() {
  // orig resolution: 1583 × 835
  //bigWave.resize(688, 363);
  bigWave.resize(floor(688*1.2), floor(363*1.2));
  //image(bigWave, mouseX-680, height-600);
  image(bigWave, moveBigWave-680, height-600);
}

// HIGH WAVE
//highWave.resize(floor(984/1.8), floor(550/1.8));
//image(highWave, moveLowWave/3+250, height-550);
//image(highWave, moveLowWave/3+250+lowWave.width, height-550);

// BACK LOWER WAVE
void lowWave() {
  imageMode(CORNER);
  lowWave.resize(1300, 400);
  //image(lowWave, mouseX/3-500, height-500);
  //image(lowWave, mouseX/3-500+lowWave.width, height-500);
  image(lowWave, moveLowWave/3-500, height-500);
  image(lowWave, moveLowWave/3-500+lowWave.width, height-500);


  // LOOPING LOWER WAVE
  image(lowWave, loop, height-350);
  image(lowWave, loop+lowWave.width, height-350);

  //loop = mouseX/2 - 550;
  loop = moveLowWave/2 - 550;
  if (loop<-lowWave.width) 
    loop=0;
}

void boats() {

  //boats animation 

  angle+=offset;
  if (angle>=0.9) {
    offset*=-1;
  } else if (angle<=0.01) {
    offset*=-1;
    offset=0.02;
  }


//void boats() {
//  //boats animation 
//  angle+=offset;

//  if (angle>=1) {
//    offset*=-1;
//  } else if (angle<=0.01) {
//    offset*=-1;

//    if (userList.length==1) {
//      offset=0.01;
//    } else if (userList.length==2) {
//      offset=0.04;
//    } else if (userList.length>=3) {
//      offset=0.07;
//    }
//  }

  // smaller ship
  pushMatrix();
  translate(width/2+200, height/2+150);
  rotate(angle);
  imageMode(CENTER);
  image(boat1, 0, 0, 300, 150);
  popMatrix();

  // bigger ship
  pushMatrix();
  translate(width/2-100, height/2+300);
  rotate(-angle);
  imageMode(CENTER);
  image(boat2, 0, 0, 300, 100);
  popMatrix();
}

void checkUsers() {
  textSize(40);
  //text("users: " + userList.length, 20, 20);
  if (userList.length > 1) {
  } else {
  }

  // Music Z-axis controller

  //if (userList.length >= 1) {
  if (com.z > 10) {
    volume = map(com.z, userMinZ, userMaxZ, 150, 0);
    volume2 = map(com.z, userMinZ, userMaxZ, 15, 0);
    music.amp(volume);
    waveSFX.amp(volume2);
  } else {
    //music.amp(0.3);
    waveSFX.amp(0.05);
  }

  pushMatrix();
  //translate(width, 0); 
  translate(width/2, 0);
  scale(-1.0, 1.0); 
  //text("UserZ: " + com.z, 30, 30);
  //text("volume: " + volume, 30, 60);
  popMatrix();
}

//// FUNCTIONS FOR VIDEOS 

void title() {
  title.loop();
  imageMode(CORNER);
  image(title, 0, 0, width, height);
}

void sceneOne() {
  sceneOne.play();
  imageMode(CORNER);
  image(sceneOne, 0, 0, width, height);
}

void sceneTwo() {
  sceneTwo.play();
  imageMode(CORNER);
  image(sceneTwo, 0, 0, width, height);
}

void sceneThree() {
  sceneThree.play();
  imageMode(CORNER);
  image(sceneThree, 0, 0, width, height);
}
