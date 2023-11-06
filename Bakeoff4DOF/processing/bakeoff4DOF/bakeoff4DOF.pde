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
boolean editMode = false;
boolean movingMode = false;
boolean canDragCorners = false;
boolean canDragButton = false;
float lastClickTime = 0;
float rotationX0 = 0;
float rotationY0 = 0;
boolean showErrorMessage = false;
Circle thisCircle;

final float doubleClickSpeed = 400; //in ms
final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

private class Circle
{
  float x, y; //center x and y of circle
  //float r = 10;
  float r = 6;
  float rotation = 0;
  String name = "";
  
  Circle (float x, float y, String name)
  {
    //this.x = x - 2*z;
    //this.y = y - 2*z;
    this.x = x;
    this.y = y;
    this.name = name;
  }
}

private class RotateButtonClass
{
  float x = 0;
  float y = 0;
  float z = 12;
  float rotation = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();
ArrayList<Circle> circles = new ArrayList<Circle>();
RotateButtonClass rotateButton = new RotateButtonClass();


void setup() {
  size(1000, 800);  
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
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  if (showErrorMessage)
    text("Missed", width/2.0, height - 10);
  else if (!showErrorMessage && trialIndex > 0)
    text("Success!", width/2.0, height - 10);

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  
  
  if (movingMode && insideBorder (mouseX, mouseY))
  {
    int deltaX = mouseX - pmouseX;
    logoX += deltaX;
    int deltaY = mouseY - pmouseY;
    logoY += deltaY;
  }
  
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EDIT MODE CONTROLS=================
  //rotateButton.x = logoX;
  //rotateButton.y = logoY - logoZ / 2.0;
  
  //float buttonRadius = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0, 2) + (float)Math.pow(logoZ / 2.0, 2)));
  
  
  //rotateButton.x = logoX + buttonRadius * (float)Math.sin(radians(logoRotation));
  //rotateButton.y = logoY - buttonRadius * (float)Math.cos(radians(logoRotation));
  
  rotateButton.x = logoX + (logoZ / 2.0) * (float)Math.sin(radians(logoRotation));
  rotateButton.y = logoY - (logoZ / 2.0) * (float)Math.cos(radians(logoRotation));
  
  rotateButton.rotation = logoRotation;
  //rotateButton.z = logoZ / 10.0;
  
  //fill(#FF1717);
  //fill(255);
  //rect(rotateButton.x, rotateButton.y, rotateButton.z, rotateButton.z);
  
  if (!circles.isEmpty())
  {
    circles.clear();
  }
  
  float circleDist = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0, 2) + (float)Math.pow(logoZ / 2.0, 2)));
  
  //float oldX = circles.get(0).x;
  //float oldY = circles.get(0).y;
  
  float cornerX = logoX - circleDist * (float)Math.cos(radians(logoRotation));
  float cornerY = logoY - circleDist * (float)Math.sin(radians(logoRotation));
  
  Circle leftTop = new Circle(logoX + circleDist * (float)Math.sin(radians(logoRotation - 45)), logoY - circleDist * (float)Math.cos(radians(logoRotation - 45)), "leftTop");
  Circle leftBottom = new Circle(logoX - circleDist * (float)Math.sin(radians(logoRotation + 45)), logoY + circleDist * (float)Math.cos(radians(logoRotation + 45)), "leftBottom");
  Circle rightTop = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation - 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation - 45)), "rightTop");
  Circle rightBottom = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation + 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation + 45)), "rightBottom");
  
  circles.add(leftTop);
  circles.add(rightTop);
  circles.add(leftBottom);
  circles.add(rightBottom);

  //if (mouseX >= (logoX - logoZ) && mouseX < (logoX + logoZ) && mouseY >= (logoY - logoZ) && mouseY < (logoY + logoZ))
  //  editMode = true;
  //else
  //  editMode = false;
  

  //if (editMode)
  //  fill(255);
  //else
  //  fill(255, 0);
  if (editMode)
  {
    fill(255);
    for (Circle circle : circles)
    {
      //fill(255, 0);
      
      //ellipse(circle.x, circle.y, 2*circle.r, 2*circle.r);
      
      //fill(#FF2121);
      //float centerX = circle.x;
      //  float centerY = circle.y;
      //ellipse(centerX, centerY, 2, 2);
      
      pushMatrix();
      translate(circle.x, circle.y);
      rotate(radians(circle.rotation));
      ellipse(0, 0, 2*circle.r, 2*circle.r);
      popMatrix();

    }
  
    //if (!canDragButton)
    //{
      pushMatrix();
      translate(rotateButton.x, rotateButton.y);
      rotate(radians(rotateButton.rotation));
      rect(0, 0, rotateButton.z, rotateButton.z);
      popMatrix();
    //}
    //else
    //{
    
    //  pushMatrix();
    //  translate(rotationX0, rotationY0);
    //  rotate(radians(rotateButton.rotation));
    //  rect((rotateButton.x - rotationX0), (rotateButton.y - rotationY0), rotateButton.z, rotateButton.z);
    //  popMatrix();
    //}
    
  }     
  fill(255);
  
  //===========DRAW EXAMPLE CONTROLS=================
  //fill(255);
  //scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //for (Circle c : circles)
  //  {
  //    if (insideCircle (mouseX, mouseY, c))
  //    {
  //      print("In circle");
  //    }
  //  }
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  ////upper left corner, rotate counterclockwise
  //text("CCW", inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
  //  logoRotation--;

  ////upper right corner, rotate clockwise
  //text("CW", width-inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
  //  logoRotation++;

  
  //text("-", inchToPix(.4f), height-inchToPix(.4f));
  //if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
  //  logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  ////lower right corner, increase Z
  //text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  //if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
  //  logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  //print(mouseX+ " " + mouseY);
  
  
  //for (Circle c : circles)
  //{
  //   print("mouseX, mouseY"+mouseX+" "+mouseY);
  //    float centerX = c.x + c.r;
  //    float centerY = c.y + c.r;
  //    println("centerXY"+centerX+" "+centerY);
  //  if (insideCircle (mouseX, mouseY, c))
  //  {
  //    print("In circle");
  //  }
  //}
  //println();
  
  if (insideLogo (mouseX, mouseY))
    editMode = true;
  else
  {
    boolean notInCircle = true;
    if (insideButton (mouseX, mouseY))
      notInCircle = false;
    for (Circle c : circles)
    {
      if (insideCircle (mouseX, mouseY, c))
        notInCircle = false;
    }
    if (notInCircle)
      editMode = false;
  }
  
     
  if (insideLogo (mouseX, mouseY))
  {
    //print("InLOGO");
    boolean notInCircles = true;
    if (insideButton (mouseX, mouseY))
      notInCircles = false;
    for (Circle c : circles)
    {
      if (insideCircle (mouseX, mouseY, c))
      {
        print("In circle");
        notInCircles = false;
      }
    }
    //print("edit Mode");
    if (notInCircles)
      movingMode = true;
    else
      movingMode = false;
  //Double click code; counts double click if within moveable square and user clicks within 500ms in same square. Used as submit button
  //print("Time"+millis());
  //print("lastClickTime"+lastClickTime);
  float thisClickTime = millis();
  if (thisClickTime - lastClickTime <= doubleClickSpeed && insideLogo(mouseX, mouseY))
  {
    print("Done");
    if (userDone==false && !checkForSuccess())
    {
      errorCount++;
      showErrorMessage = true;
    }
    else if (userDone==false && checkForSuccess())
      showErrorMessage = false;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  lastClickTime = thisClickTime;
  
  if (circles.isEmpty())
    print("circles Empty");
  }
  
  for (Circle c : circles)
    {
      if (insideCircle (mouseX, mouseY, c))
      {
        canDragCorners = true;
        thisCircle = c;
      }
    }
    
  if (insideButton (mouseX, mouseY))
  {
    canDragButton = true;
    rotationX0 = logoX; 
    rotationY0 = logoY;
  }
  }

void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  //if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  //{
  //  if (userDone==false && !checkForSuccess())
  //    errorCount++;

  //  trialIndex++; //and move on to next trial

  //  if (trialIndex==trialCount && userDone==false)
  //  {
  //    userDone = true;
  //    finishTime = millis();
  //  }
  //}
  movingMode = false;
  canDragCorners = false;
  canDragButton = false;
  
}

void mouseDragged()
{
  //Error: if moving mouse too fast, square stops
  //If within bounds of moveable square, move sqaure with mouse
  //if (insideLogo (mouseX, mouseY))
  //{
  //  int deltaX = mouseX - pmouseX;
  //  logoX += deltaX;
  //  int deltaY = mouseY - pmouseY;
  //  logoY += deltaY;
  //}
  
  //if mouse in any of the corner icons, change logo sizing based off of any change in mouseX and mouseY
  int deltaX = mouseX - pmouseX;
  int deltaY = mouseY - pmouseY;
  int deltaXY = Math.min(Math.abs(deltaX), Math.abs(deltaY));
  
  //println(deltaX+" "+deltaY);
  //float percentChange = Math.max(mouseX*1.0/pmouseX, mouseY*1.0/pmouseY);
  //float percentChange = (float)(Math.sqrt(Math.pow(Math.max(Math.abs(deltaX), Math.abs(deltaY)), 2))); 
  //float oldR = ((float)Math.pow(pmouseX, 2) + (float)Math.pow(pmouseY, 2));
  //float newR = ((float)Math.pow(mouseX, 2) + (float)Math.pow(mouseY, 2));
  //float oldR = 2*((float)Math.pow((float)Math.max(pmouseX, pmouseY), 2));
  //float newR = 2*((float)Math.pow((float)Math.max(mouseX, mouseY), 2));

  float percentChange;
  float newR = 0;
  float oldR = 0;
  //if (deltaX >= 0)
  //  percentChange = 1.0;
  //else
  //  percentChange = -1.0;
  //if (insideLogo (mouseX, mouseY))
  //{
      //percentChange = (float)(1.0/Math.sqrt(Math.pow(Math.max(Math.abs(deltaX), Math.abs(deltaY)), 2))); 
      //percentChange = 1.0;
      //percentChange = (float)(newR/oldR);
  //}
  //else
  //{
      //percentChange = -1*(float)(Math.sqrt(Math.pow(Math.max(Math.abs(deltaX), Math.abs(deltaY)), 2))); 
      //percentChange = -1.0;
  //}
  
  //for (Circle circle : circles)
  //{
  //  if (insideCircle (mouseX, mouseY, circle))
  //  {
  //    print("mouseX, mouseY: " + mouseX + " " + mouseY);
  //    print("oldZ: "+logoZ);
  //    //logoZ = constrain(logoZ+(percentChange*inchToPix(.02f)), .01, inchToPix(4f)); //leave min and max alone!
  //    //logoZ = constrain(logoZ*percentChange*inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
  //    logoZ = constrain(logoZ+percentChange*inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
  //    println("newZ: "+logoZ);
  //  }
  //}
  if (canDragCorners)
  {
    //if (circleCorner == "rightBottom")
    if (thisCircle.x >= logoX && thisCircle.y >= logoY)
    {
      oldR = ((float)Math.pow(pmouseX, 2) + (float)Math.pow(pmouseY, 2));
      newR = ((float)Math.pow(mouseX, 2) + (float)Math.pow(mouseY, 2));
    }
    //else if (circleCorner == "rightTop")
    else if (thisCircle.x >= logoX && thisCircle.y <= logoY)
    {
      oldR = ((float)Math.pow(pmouseX, 2) + (float)Math.pow(mouseY, 2));
      newR = ((float)Math.pow(mouseX, 2) + (float)Math.pow(pmouseY, 2));
    }
    //else if (circleCorner == "leftBottom")
    else if (thisCircle.x <= logoX && thisCircle.y >= logoY)
    {
      oldR = ((float)Math.pow(mouseX, 2) + (float)Math.pow(pmouseY, 2));
      newR = ((float)Math.pow(pmouseX, 2) + (float)Math.pow(mouseY, 2));
    }
    //else if (circleCorner == "leftTop")
    else if (thisCircle.x <= logoX && thisCircle.y <= logoY)
    {
      oldR = ((float)Math.pow(mouseX, 2) + (float)Math.pow(mouseY, 2));
      newR = ((float)Math.pow(pmouseX, 2) + (float)Math.pow(pmouseY, 2));
    }
    
    
    percentChange = (float)(newR/oldR);
    //float deltaXY = (float)Math.abs(Math.sqrt(oldR) - Math.sqrt(newR));
    
    //if (percentChange > 0) //increasing size
    //{
    //  //if (circleCorner == "rightBottom")
    //  if (thisCircle.x >= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX += deltaXY;
    //    logoY += deltaXY;
    //  }
    //  //else if (circleCorner == "rightTop")
    //  else if (thisCircle.x >= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX -= deltaXY;
    //    logoY += deltaXY;
    //  }
    //  //else if (circleCorner == "leftBottom")
    //  else if (thisCircle.x <= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX -= deltaXY;
    //    logoY += deltaXY;
    //  }
    //  //else if (circleCorner == "leftTop")
    //  else if (thisCircle.x <= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX -= deltaXY;
    //    logoY -= deltaXY;
    //  }
    //}
    //else
    //{
    //  //if (circleCorner == "rightBottom")
    //  if (thisCircle.x >= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX -= deltaXY;
    //    logoY -= deltaXY;
    //  }
    //  //else if (circleCorner == "rightTop")
    //  else if (thisCircle.x >= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX += deltaXY;
    //    logoY -= deltaXY;
    //  }
    //  //else if (circleCorner == "leftBottom")
    //  else if (thisCircle.x <= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX += deltaXY;
    //    logoY -= deltaXY;
    //  }
    //  //else if (circleCorner == "leftTop")
    //  else if (thisCircle.x <= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX += deltaXY;
    //    logoY += deltaXY;
    //  }
    //}
    
    //float oldX = logoX;
    //float oldY = logoY;
    //println("old " + logoX);
    //logoZ = constrain(logoZ+percentChange, .01, inchToPix(4f)); //leave min and max alone!
    logoZ = constrain(logoZ*(float)Math.pow(percentChange, 4), .01, inchToPix(4f)); //leave min and max alone!
    
    //float circleDist = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0, 2) + (float)Math.pow(logoZ / 2.0, 2)));
  
    //float oldX = circles.get(0).x;
    //float oldY = circles.get(0).y;
    
    //float newX = logoX + circleDist * (float)Math.sin(radians(logoRotation - 45));
    //float newY = logoY - circleDist * (float)Math.cos(radians(logoRotation - 45));
    
    //logoX += oldX - newX;  
    //logoY -= oldY - newY;
    
    //float oldX = circles.get(2).x;
    //float oldY = circles.get(2).y;
    
    //float newX = logoX + circleDist * (float)Math.cos(radians(logoRotation - 45));
    //float newY = logoY + circleDist * (float)Math.sin(radians(logoRotation - 45));
    
    //logoX += newX - oldX;  
    //logoY -= oldY - newY;
    
    //Circle leftTop = new Circle(logoX + circleDist * (float)Math.sin(radians(logoRotation - 45)), logoY - circleDist * (float)Math.cos(radians(logoRotation - 45)), "leftTop");
    //Circle leftBottom = new Circle(logoX - circleDist * (float)Math.sin(radians(logoRotation + 45)), logoY + circleDist * (float)Math.cos(radians(logoRotation + 45)), "leftBottom");
    //Circle rightTop = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation - 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation - 45)), "rightTop");
    //Circle rightBottom = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation + 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation + 45)), "rightBottom");
  
  
    
    //logoX = logoX + (logoZ / 2.0) * (float)Math.sin(radians(logoRotation));
    //logoY = logoY - (logoZ / 2.0) * (float)Math.cos(radians(logoRotation));
  
    //logoX += logoZ / 2.0;
    //logoY -= logoZ / 2.0;
    //println("X: "+logoX+" Y: "+logoY+" Z: "+logoZ);
    //if (canDragCorners)
    //{
    //  logoX += logoZ / 2.0;
    //  logoY -= logoZ / 2.0;
    //}
    //println("Circle "+thisCircle.x);
    //logoX = logoX/(float)Math.pow(percentChange, 0.5);
    //logoY = logoY/(float)Math.pow(percentChange, 0.5);
    //logoX = oldX;
    //logoY = oldY;
    
    
    //float circleDist = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0, 2) + (float)Math.pow(logoZ / 2.0, 2)));
    
      //if (circleCorner == "rightBottom")
    //  if (thisCircle.x >= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX = logoX + circleDist * (float)Math.cos(radians(logoRotation + 45)) - logoZ / 2.0;
    //    logoY = logoY + circleDist * (float)Math.sin(radians(logoRotation + 45)) - logoZ / 2.0;
    //  }
    //  //else if (circleCorner == "rightTop")
    //  else if (thisCircle.x >= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX = logoX + circleDist * (float)Math.cos(radians(logoRotation - 45)) - logoZ / 2.0;
    //    logoY = logoY + circleDist * (float)Math.sin(radians(logoRotation - 45)) + logoZ / 2.0;
    //  }
    //  //else if (circleCorner == "leftBottom")
    //  else if (thisCircle.x <= logoX && thisCircle.y >= logoY)
    //  {
    //    logoX = logoX - circleDist * (float)Math.sin(radians(logoRotation + 45)) + logoZ / 2.0;
    //    logoY = logoY + circleDist * (float)Math.cos(radians(logoRotation + 45)) - logoZ / 2.0;
    //  }
    //  //else if (circleCorner == "leftTop")
    //  else if (thisCircle.x <= logoX && thisCircle.y <= logoY)
    //  {
    //    logoX = logoX + circleDist * (float)Math.sin(radians(logoRotation - 45)) + logoZ / 2.0;
    //    logoY = logoY - circleDist * (float)Math.cos(radians(logoRotation - 45)) + logoZ / 2.0;
    //  }
    //}
    
    
}
  
  if (canDragButton)
  {
    //println("Rotating");
    //deltaX = Math.abs(deltaX);
    //deltaY = Math.abs(deltaY);
    //float deltaX1 = ();
    //float res = (float)Math.atan((float)(deltaX/deltaY));
    //float res = (float)Math.atan((float)(deltaX/deltaY));
    //float res = rotateButton.rotation = (float)Math.atan((float)deltaX/(Math.min(mouseY, pmouseY)));
    //rotateButton.rotation = (float)Math.atan((float)deltaX/(Math.min(mouseY, pmouseY)));
    //logoRotation = (float)degrees((float)Math.atan((float)deltaX/(Math.min(mouseY, pmouseY))));
    
    float dx = mouseX - rotationX0;
    float dy = mouseY - rotationY0;
    //float dx = rotationX0 - mouseX;
    //float dy = rotationY0 - mouseY;
    float res = 0;
    float resQ1 = (float)Math.atan((float)(dx/-dy));
    float resQ2 = (float)Math.atan((float)(-dx/-dy));
    float resQ3 = (float)Math.atan((float)(-dx/dy));
    float resQ4 = (float)Math.atan((float)(dx/dy));
    //float resQ4 = (float)Math.atan((float)(dy/dx));
    
    //if (degrees(resQ1) >= 0)
    //  res = resQ1;
    //else
    //  res = resQ3;
    
    if (dy < 0)
      res = resQ1;
    else
      //res = Math.pi
      res = (float)Math.PI - resQ4;
      
    
    //if (dx >= 0 && dy >= 0)
      //res = resQ1;
    //else if (dx <= 0 && dy >=0)
    //  res = resQ2;
    //else if (dx <= 0 && dy <= 0)
    //  res = resQ3;
    //else if (dx >= 0 && dy <= 0)
    //  res = resQ4;
    
    //rotateButton.rotation = res;
    for (Circle c : circles)
      c.rotation = degrees(res);
    logoRotation = degrees(res);
    println("rotation (deg): "+logoRotation);
  }  
  
  }
  


boolean insideLogo (int x, int y)
{
  return (x >= (logoX - logoZ / 2.0) && x < (logoX + logoZ / 2.0) && y >= (logoY - logoZ / 2.0) && y < (logoY + logoZ / 2.0));
}

boolean insideBorder (int x, int y)
{
  //return (x >= border && x <= (width - border) && y >= border && y <= (height - border));
  //return (x >= logoZ / 2.0 && x <= (width - logoZ / 2.0) && y >= logoZ / 2.0 && y <= (height - logoZ / 2.0));
  return (x >= logoZ  && x <= (width - logoZ) && y >= logoZ && y <= (height - logoZ));
  //return (x > 0 && x < width && y > 0 && y < height);
}

boolean insideCircle (int x, int y, Circle c)
{
  //float centerX = c.x + c.r;
  //float centerY = c.y + c.r;
  return Math.pow(x - c.x, 2) + Math.pow(y - c.y, 2) < Math.pow(c.r, 2);
}

boolean insideButton (int x, int y)
{
  return (x >= (rotateButton.x - rotateButton.z / 2.0) && x < (rotateButton.x + rotateButton.z / 2.0) && y >= (rotateButton.y - rotateButton.z / 2.0) && y < (rotateButton.y + rotateButton.z / 2.0));
}

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
