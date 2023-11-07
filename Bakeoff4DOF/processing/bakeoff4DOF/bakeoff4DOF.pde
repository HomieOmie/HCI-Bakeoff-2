import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
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
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

// General slider sizes
float sliderDiam;
float sliderHeight;
float handleDiam;
float handleHeight;

// ZSlider specific
float ZSliderPosX;
float ZSliderPosY;
float ZHandlePosX;
float ZHandlePosY;

// RotSlider specific
float RotSliderPosX;
float RotSliderPosY;
float RotHandlePosX;
float RotHandlePosY;

boolean draggingZSlider;
boolean draggingRotSlider;
float correctZPosX;
float correctRotPosX;


// ******************** Added Start
float targetX = 0;
float targetY = 0;
float targetRot = 0;
float targetSize = 0;

float currX = 0;
float currY = 0;

boolean rotCorrect = false;
boolean sizeCorrect = false;
boolean posCorrect = false;
boolean xCorrect = false;
boolean yCorrect = false;

boolean followMouse = false; //used to determine click and drag of logo

float submitX = 975;
float submitY = 400;
float submitWidth = 100;
float submitHeight = 200;

//float width;
//float height;
float width = 1000;
float height = 800;

private class Circle
{
  float x, y; //center x and y of circle
  float r = 15;
  float rotation = 0;
  String name = "";
  
  Circle (float x, float y, String name)
  {
    this.x = x;
    this.y = y;
    this.name = name;
  }
}
// ******************** Added End

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  fullScreen();
  //size(1000, 800);  
  //width = 1000;
  //height = 800;
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
  
  // Slider and handle sizes
  sliderHeight = inchToPix(1.0);
  sliderDiam = width / 2;
  handleDiam = sliderDiam / 14;
  handleHeight = sliderHeight;
  
  // ZSlider position init on bottom of the screen
  ZSliderPosX = width / 2;
  ZSliderPosY = height - sliderHeight/2;

  // ZSlider ZHandle position init (Should be based on ZSlider coords to keep the ZHandle overlapped on the ZSlider background; middle of ZSlider initially)
  ZHandlePosX = ZSliderPosX;
  ZHandlePosY = ZSliderPosY;
  
  // ZSlider position init on bottom of the screen
  RotSliderPosX = width / 2;
  RotSliderPosY = sliderHeight/2;

  // RotSlider RotHandle position init
  RotHandlePosX = RotSliderPosX;
  RotHandlePosY = RotSliderPosY;
  
  // Boolean to let the program know if the user is sliding the ZHandle while moving the mouse or not
  draggingZSlider = false;
  
  // Initialize logo size:
  setZByHandlePos();
  setRotByHandlePos();
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  // ******************** Added Start
  //if (followMouse) {
  //   logoX = mouseX;
  //   logoY = mouseY;
  //}
  if (followMouse && insideBorder (mouseX, mouseY))
  {
    int deltaX = mouseX - pmouseX;
    logoX += deltaX;
    int deltaY = mouseY - pmouseY;
    logoY += deltaY;
  }
  // ******************** Added End


  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      stroke(255, 0, 0, 192); //set color to semi translucent
      targetX = d.x;
      targetY = d.y;
      targetRot = (d.rotation + 360) % 90;
      targetSize = d.z;
    }
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  Destination d = destinations.get(trialIndex);  
  posCorrect = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if (posCorrect)
    fill(0, 255, 0, 100);
  else
    fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //text("X: " + int(targetX) + " Y: " + int(targetY) + " rot: " + int(targetRot) + " size: " + int(targetSize), width/2, height/2);
  //text("X: " + int(logoX) + " Y: " + int(logoY) + " rot: " + int((logoRotation + 360) % 90) + " size: " + int(logoZ), width/2, height/2 + 20);
  
  
  // Current location lines
  fill(255);
  stroke(255);
  line(logoX, 0, logoX, height);
  line(0, logoY, width, logoY);
  noStroke();
  
  rotCorrect = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  sizeCorrect = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"
  
  // SUBMIT BUTTON
  if (rotCorrect && sizeCorrect && posCorrect) {
    fill(0, 255, 0);
  } else {
    fill(255, 0, 0); 
  }
  
  rect(submitX, submitY, submitWidth, submitHeight);
  
  //===========DRAW ZSlider=================
  if (sizeCorrect)
    fill(0, 255, 0, 100);
  else
    fill(255, 0, 0, 100); 
  rect(ZSliderPosX, ZSliderPosY, sliderDiam, sliderHeight);
  
  //===========DRAW RotSliderS=================
  if (rotCorrect)
    fill(0, 255, 0, 100);
  else
    fill(255, 0, 0, 100); 
  rect(RotSliderPosX, RotSliderPosY, sliderDiam, sliderHeight);
  
  // Move the correct Z indicator
  correctZPosX = map(d.z, 0.01, inchToPix(4.0), ZSliderPosX - sliderDiam / 2, ZSliderPosX + sliderDiam / 2);
  
  // Move the correct Z indicator
  correctRotPosX = map((d.rotation + 360) % 90, 0, 90, RotSliderPosX - sliderDiam / 2, RotSliderPosX + sliderDiam / 2);
  
  // Draw ZHandle
  fill(200);
  ellipse(ZHandlePosX, ZHandlePosY, handleHeight + 20, handleHeight + 20);
  
  // Draw RotHandle
  fill(200);
  ellipse(RotHandlePosX, RotHandlePosY, handleHeight + 20, handleHeight + 20);
  
  // Draw correct ZHandle location indicator
  fill(0, 255, 0);
  rect(correctZPosX, ZSliderPosY, 20, sliderHeight);
  
  // Draw correct RotHandle location indicator
  fill(0, 255, 0);
  rect(correctRotPosX, RotSliderPosY, 20, sliderHeight);
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
}

void mousePressed()
{
  // ******************** Added Start
  if (insideLogo (mouseX, mouseY))
    followMouse = true;
  currX = mouseX;
  currY = mouseY;
  //if (mouseX >= logoX - logoZ && mouseX <= logoX + logoZ && mouseY >= logoY - logoZ && mouseY <= logoY + logoZ) {
  //  //followMouse = !followMouse;
  //}
  // Let's the program know if the user is clicking on the ZHandle to drage the ZSlider, then sets the boolean to true for the mouseDragged() function to ZHandle
  if (mouseX > ZHandlePosX - handleDiam && mouseX < ZHandlePosX + handleDiam && mouseY > ZHandlePosY - handleHeight && mouseY < ZHandlePosY + handleHeight) {
    draggingZSlider = true;
  }
  else {
    draggingZSlider = false;
  }
  
  if (mouseX > ZSliderPosX - sliderDiam/2 && mouseX <  ZSliderPosX + sliderDiam/2 && mouseY > ZSliderPosY - sliderHeight/2 && mouseY <  ZSliderPosY + sliderHeight/2){
    // Moves the ZSlider ZHandle based on the mouse position but has a constraint to prevent ZHandle from going off of the ZSlider background
    ZHandlePosX = constrain(mouseX, ZSliderPosX - sliderDiam / 2, ZSliderPosX + sliderDiam / 2);

    // Adjust the square size based on the ZSlider position
    setZByHandlePos(); 
  }
  
  if (mouseX > RotSliderPosX - sliderDiam/2 && mouseX <  RotSliderPosX + sliderDiam/2 && mouseY > RotSliderPosY - sliderHeight/2 && mouseY <  RotSliderPosY + sliderHeight/2){
    // Moves the RotSlider RotHandle based on the mouse position but has a constraint to prevent RotHandle from going off of the RotSlider background
    RotHandlePosX = constrain(mouseX, RotSliderPosX - sliderDiam / 2, RotSliderPosX + sliderDiam / 2);

    // Adjust the square size based on the RotSlider position
    setRotByHandlePos(); 
  }
  
  // Let's the program know if the user is clicking on the ZHandle to drage the ZSlider, then sets the boolean to true for the mouseDragged() function to ZHandle
  if (mouseX > RotHandlePosX - handleDiam && mouseX < RotHandlePosX + handleDiam && mouseY > RotHandlePosY - handleHeight && mouseY < RotHandlePosY + handleHeight) {
    draggingRotSlider = true;
  }
  else {
    draggingRotSlider = false;
  }
  
  // ******************** Added End
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  followMouse = false;
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (mouseX >= submitX - submitWidth && mouseX <= submitX + submitWidth 
      && mouseY >= submitY - submitHeight && mouseY <= submitY + submitHeight)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    
    posCorrect = false;
    rotCorrect = false;
    sizeCorrect = false;
    
    // Reset slider positions
    ZHandlePosX = ZSliderPosX;
    ZHandlePosY = ZSliderPosY;
    RotHandlePosX = RotSliderPosX;
    RotHandlePosY = RotSliderPosY;
    setZByHandlePos();
    setRotByHandlePos();
  }
}

void setZByHandlePos () {
  logoZ = map(ZHandlePosX, ZSliderPosX - sliderDiam / 2, ZSliderPosX + sliderDiam / 2, 0.01, inchToPix(4.0));
}

void setRotByHandlePos() {
  logoRotation = map(RotHandlePosX, RotSliderPosX - sliderDiam / 2, RotSliderPosX + sliderDiam / 2, 0, 90); 
}

// ******************** Added Start
void mouseDragged() {
  
  if (draggingZSlider) {
    // Moves the ZSlider ZHandle based on the mouse position but has a constraint to prevent ZHandle from going off of the ZSlider background
    ZHandlePosX = constrain(mouseX, ZSliderPosX - sliderDiam / 2, ZSliderPosX + sliderDiam / 2);

    // Adjust the square size based on the ZSlider position
    setZByHandlePos();
  }
  
  if (draggingRotSlider) {
    RotHandlePosX = constrain(mouseX, RotSliderPosX - sliderDiam / 2, RotSliderPosX + sliderDiam / 2);
    setRotByHandlePos();
  }
  
  //if (mouseY < 200) {
  //if (mouseX > currX + 1)
  //  logoRotation++;
  //else if (mouseX < currX - 1)
  //  logoRotation--;
  //}
    
  //if (mouseY > 600){
  //if (mouseX > currX + 1)
  //  logoZ++;
  //else if (mouseX < currX - 1)
  //  logoZ--;
  //}
   
  currX = mouseX; 
  currY = mouseY; 
}

//boolean insideLogo (int x, int y)
//{
//  return (x >= (logoX - logoZ / 2.0) && x < (logoX + logoZ / 2.0) && y >= (logoY - logoZ / 2.0) && y < (logoY + logoZ / 2.0));
//}

boolean insideLogo (int x, int y)
{
  //float r = Math.sqrt(Math.pow(logoZ / 2.0, 2) + Math.pow(logoZ / 2.0, 2));
  //return (x >= (logoX - logoZ / 2.0) && x < (logoX + logoZ / 2.0) && y >= (logoY - logoZ / 2.0) && y < (logoY + logoZ / 2.0));
     
  float circleDist = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0 + 20, 2) + (float)Math.pow(logoZ / 2.0 + 20, 2)));

  
  Circle leftTop = new Circle(logoX + circleDist * (float)Math.sin(radians(logoRotation - 45)), logoY - circleDist * (float)Math.cos(radians(logoRotation - 45)), "leftTop");
  Circle leftBottom = new Circle(logoX - circleDist * (float)Math.sin(radians(logoRotation + 45)), logoY + circleDist * (float)Math.cos(radians(logoRotation + 45)), "leftBottom");
  Circle rightTop = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation - 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation - 45)), "rightTop");
  Circle rightBottom = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation + 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation + 45)), "rightBottom");
  
  float[] xBounds = {leftTop.x, leftBottom.x, rightTop.x, rightBottom.x};
  float[] yBounds = {leftTop.y, leftBottom.y, rightTop.y, rightBottom.y};  // Create an array of ints
  float xMin = min(xBounds);
  float xMax = max(xBounds);
  float yMin = min(yBounds);
  float yMax = max(yBounds);

  return (xMin <= x && x <= xMax && yMin <= y && y <= yMax);

}


//helper function to see if mouseX, mouseY within screen border
boolean insideBorder (int x, int y)
{
  //return (x >= border && x <= (width - border) && y >= border && y <= (height - border));
  //return (x >= logoZ / 2.0 && x <= (width - logoZ / 2.0) && y >= logoZ / 2.0 && y <= (height - logoZ / 2.0));
  //return (x >= logoZ  && x <= (width - logoZ) && y >= logoZ && y <= (height - logoZ));
  return (x > 0 && x < width && y > 0 && y < height);
}
// ******************** Added End

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
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
