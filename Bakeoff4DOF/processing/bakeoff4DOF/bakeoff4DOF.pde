import java.util.ArrayList;
import java.util.Collections;
import garciadelcastillo.dashedlines.*;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;
boolean locked = false;
float clickDist = (screenZ * sqrt(2));
float xOffset = 0.0;
float yOffset = 0.0;

// Declare the main DashedLines object
DashedLines dash;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

void setup() {
  size(1000, 800); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  
  textSize(55);
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  // Initialize it, passing a reference to the current PApplet
  dash = new DashedLines(this);

  // Set the dash-gap pattern in pixels
  dash.pattern(10, 5);
  
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}



void draw() {

  background(255); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    textSize(20);
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    textSize(20);
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    textSize(20);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchToPix(.4f)*3);
    textSize(20);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=0; i<trialCount; i++)
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Target t = targets.get(i);
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    
    rotate(radians(t.rotation));
    if (trialIndex==i)
      fill(255, 0, 0, 192); //set color to semi translucent
    else
      fill(128, 60, 60, 128); //set color to semi translucent
    rect(0, 0, t.z, t.z);
    if (trialIndex==i)
      fill(40); //set color to semi translucent
    else
      noFill(); //set color to semi translucent
    ellipse(0,0,10, 10);
    
    popMatrix();

  }

  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  if (checkForSuccess()){
    fill(0,255,0);}
  else{
    noFill();}
  strokeWeight(3f);
  stroke(160);
  rect(0, 0, screenZ, screenZ);
  popMatrix();
  
  // trying to draw center circle on cursor square
  ellipseMode(CENTER);
  noFill();
  dash.ellipse(screenTransX + width /2, screenTransY + height / 2, 10, 10);

  

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //dash.line(500, 0, 500, 800);
  //dash.line(0, 400, 1000, 400);
  int cx = width / 2;
  int cy = height / 2;
  
  // draw the transparent circle in the center
  ellipseMode(CENTER);
  noFill();
  dash.ellipse(cx, cy, 2 * inchToPix(3f), 2 * inchToPix(3f));
  
  //// draw 4 regions
  //dash.line(0, cy, width, cy);
  //dash.line(cx, 0, cx, height);

  dash.line(0, cy, cx - inchToPix(3f), cy);
  dash.line(cx, cy + inchToPix(3f), cx, height);
  dash.line(cx + inchToPix(3f), cy, width, cy);
  dash.line(cx, 0, cx, cy -  inchToPix(3f));
  
  // highlight the quadrant that needs to be clicked
  noStroke();
  fill(0, 0, 255, 50);
  if (checkForSize() < 0) {
    rect(width * 0.25, height * 0.75, 500, 400);
  } else if (checkForSize() > 0) {
    rect(width * 0.75, height * 0.75, 500, 400);
  }
    
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  int textMargin = 200;
  //upper left corner, rotate counterclockwise
  //text("CCW", inchToPix(.4f), inchToPix(.4f));
  
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
  fill(120);
  text("CCW", textMargin, textMargin);
  if (!locked && mousePressed && mouseX < width / 2 && mouseY < height / 2)
    screenRotation -= 1;

  //upper right corner, rotate clockwise
  //text("CW", width-inchToPix(.4f), inchToPix(.4f));
  text("CW", width - textMargin, textMargin);
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
  if (!locked && mousePressed && mouseX > width / 2 && mouseY < height / 2)
    screenRotation += 1;

  //lower left corner, decrease Z
  //text("-", inchToPix(.4f), height-inchToPix(.4f));
  text("-", textMargin, height - textMargin);
  //if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
  if (!locked && mousePressed && mouseX < width / 2 && mouseY > height / 2)
    screenZ = constrain(screenZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", width-textMargin, height-textMargin);
  //if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
  if (!locked && mousePressed && mouseX > width / 2 && mouseY > height / 2)
    screenZ = constrain(screenZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  //text("left", inchToPix(.4f), height/2);
  /*if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    screenTransX-=inchToPix(.02f);

  //text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    screenTransX+=inchToPix(.02f);

  //text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    screenTransY-=inchToPix(.02f);

  //text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    screenTransY+=inchToPix(.02f);
   */
  if(mousePressed && dist(mouseX, mouseY, width/2+screenTransX, height/2+screenTransY) < clickDist)
    locked = true;
}


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  xOffset = mouseX-screenTransX;
  yOffset = mouseY-screenTransY;
  
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f) && !(dist(mouseX, mouseY, width/2+screenTransX, height/2+screenTransY) < clickDist))
  //if(locked)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

void mouseDragged()
{
  if(locked) {
    screenTransX = mouseX-xOffset;
    screenTransY = mouseY-yOffset;
  }
}

void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches
  // need to change this logic too: now clicking withint middle of the screen should not 
  
  locked = false;
}

//return -1 for reducing size, 1 for increasing size, 0 for no change
public int checkForSize()
{
  Target t = targets.get(trialIndex);  
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"  
  println("checkForSize: Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  if (closeZ) {
    println("checkForSize returning 0");
    return 0;
  }
  
  if (t.z > screenZ) {
    println("checkForSize returning 1");
    return 1;
  } else {
    println("checkForSize returning -1");
    return -1;
  }
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);	
  boolean closeDist = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"	

  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation, screenRotation)+")");
  println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
