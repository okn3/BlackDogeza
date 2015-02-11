
/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
dogeza 

 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import http.requests.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,0,255),
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();   
int max = 0;
int min = 0;
int delta;
int HP;
boolean start;
String set_url;

  
void setup()
{
  size(640,480);
  print("push Enter! to start!");
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();  
}

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      

  }    
}

void keyPressed() {
  if (key == ENTER) {
    start = true;
    println ("=========================");
    println ("          start          ");
    println ("=========================");
  }
}

  
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  PVector HeadPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,HeadPos);
  HP = int(HeadPos.y);

  if (HeadPos.z > 3500) {
    start = true;
    println ("=========================");
    println ("          start          ");
    println ("=========================");
  }
  
  //max min
  if (HP > max && start == true){
    max = HP;
  }else if (HP < min && start == true){
    min = HP;
  }
  
//  println("now:",HP,"max:",max,"min:",min,"depth",HeadPos.z); //debug
  
//  if(min < -200 && HP > 0 && start == true){
  if(min < -700 && HP > -500 && start == true){
    delta = max - min;
    println("====================");
    println("score:",delta);
    println("====================");
    
    //HTTP-GET
    //Debug
    //    GetRequest get = new GetRequest("http://127.0.0.1:8080/for_processing"); 
    //    set_url = "http://127.0.0.1:8080/"+delta;
    
    set_url = "http://ec2-54-64-239-254.ap-northeast-1.compute.amazonaws.com:1337/submit?m=3&score="+delta;
    print("URL:"+set_url);
    GetRequest get = new GetRequest(set_url);
    get.send();
    println("Reponse Content: " + get.getContent());
    println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
    
    exit();
  }
}
// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

