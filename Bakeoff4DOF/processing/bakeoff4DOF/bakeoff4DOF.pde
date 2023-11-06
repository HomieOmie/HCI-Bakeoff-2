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
boolean closeEnough = false;
Circle thisCircle;


float oldLogoX = 0;
float oldLogoY = 0;
float oldCircleX = 0;
float oldCircleY = 0;

final float doubleClickSpeed = 400; //in ms
final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;


float submitX;
float submitY;
float submitZ;

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

private class RotateButtonClass
{
  float x = 0;
  float y = 0;
  float z = 30;
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
  
  submitX = width - 70;
  submitY = height - 50;
  submitZ = 60;
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
    text("Missed", width/4, height - 10);
  else if (!showErrorMessage && trialIndex > 0)
    text("Success!", width/4, height - 10);

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
  if (checkForSuccess())
    closeEnough = true;
  else
    closeEnough = false;
  
  if (movingMode && insideBorder (mouseX, mouseY))
  {
    println("MOVING");
    int deltaX = mouseX - pmouseX;
    logoX += deltaX;
    int deltaY = mouseY - pmouseY;
    logoY += deltaY;
  }
  
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if (closeEnough)
    fill(#35C447);
  else
    //fill(60, 60, 192, 192);
    fill(#0FF9FF, 90);
    //fill(60, 60, 192, 300);
  rect(0, 0, logoZ, logoZ);
  popMatrix();


  //===========DRAW EDIT MODE CONTROLS=================
  
  rotateButton.x = logoX + (logoZ + 40) * (float)Math.sin(radians(logoRotation));
  rotateButton.y = logoY - (logoZ + 40) * (float)Math.cos(radians(logoRotation));
  
  rotateButton.rotation = logoRotation;
  
  if (!circles.isEmpty())
  {
    circles.clear();
  }
  
  float circleDist = (float)(Math.sqrt((float)Math.pow(logoZ / 2.0 + 20, 2) + (float)Math.pow(logoZ / 2.0 + 20, 2)));

  
  Circle leftTop = new Circle(logoX + circleDist * (float)Math.sin(radians(logoRotation - 45)), logoY - circleDist * (float)Math.cos(radians(logoRotation - 45)), "leftTop");
  Circle leftBottom = new Circle(logoX - circleDist * (float)Math.sin(radians(logoRotation + 45)), logoY + circleDist * (float)Math.cos(radians(logoRotation + 45)), "leftBottom");
  Circle rightTop = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation - 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation - 45)), "rightTop");
  Circle rightBottom = new Circle(logoX + circleDist * (float)Math.cos(radians(logoRotation + 45)), logoY + circleDist * (float)Math.sin(radians(logoRotation + 45)), "rightBottom");
  
  circles.add(leftTop);
  circles.add(leftBottom);
  circles.add(rightTop);
  circles.add(rightBottom);

  
  if (editMode)
  {
    fill(255);
    for (Circle circle : circles)
    {
      
      pushMatrix();
      translate(circle.x, circle.y);
      rotate(radians(circle.rotation));
      ellipse(0, 0, 2*circle.r, 2*circle.r);
      popMatrix();

    }
  
      pushMatrix();
      translate(rotateButton.x, rotateButton.y);
      rotate(radians(rotateButton.rotation));
      rect(0, 0, rotateButton.z, rotateButton.z);
      popMatrix();
      
      stroke(255);
      strokeWeight(5);
      line(rotateButton.x, rotateButton.y, logoX + (logoZ / 2.0) * (float)Math.sin(radians(logoRotation)), logoY - (logoZ / 2.0) * (float)Math.cos(radians(logoRotation)));
   
  }     
  
  pushMatrix();
  translate(submitX, submitY); //translate draw center to the center oft he logo square
  noStroke();
  fill(#83D18C);
  rect(0, 0, submitZ*2, submitZ);
  fill(0);
  text("SUBMIT",0, 0);
  popMatrix();
  
  fill(255);
  
  //===========DRAW EXAMPLE CONTROLS=================
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));

}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
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
  
  if (circles.isEmpty())
    print("circles Empty");
  }
  
  println(mouseX, mouseY);
    if (insideSubmit(mouseX, mouseY))
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
  
  for (Circle c : circles)
    {
      if (insideCircle (mouseX, mouseY, c))
      {
        canDragCorners = true;
        thisCircle = c;
        oldLogoX = logoX;
    oldLogoY = logoY;
    oldCircleX = thisCircle.x;
    oldCircleY = thisCircle.y;
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
  
  movingMode = false;
  canDragCorners = false;
  canDragButton = false;
  
  oldLogoX = 0;
  oldLogoY = 0;
  oldCircleX = 0;
  oldCircleY = 0;
  
}

void mouseDragged()
{
  
  if (canDragCorners)
  {
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    float d = Math.max(Math.abs(dx), Math.abs(dy));
    d *= 2;
     
    
    
    if (oldCircleX >= oldLogoX && oldCircleY >= oldLogoY)
    {
      println("rightBottom");
      
      if (dx <= 0 && dy <= 0)
        d *= -1;
      logoZ = constrain(logoZ+d, .01, inchToPix(4f));
      if (logoZ > .01 && logoZ < inchToPix(4f))
      {
        if (45 <= logoRotation && logoRotation <= 135)
          rightTop (d);
        else if (135 <= logoRotation && logoRotation <= 225)
         leftTop (d);
        else if (225 <= logoRotation && logoRotation <= 315)
          leftBottom (d);
        else
          rightBottom (d);
        
      }
      
     
    }
    else if (oldCircleX >= oldLogoX && oldCircleY <= oldLogoY)
    {
      
      println("rightTop");
      
      if (dx <= 0 && dy >= 0)
        d *= -1;
      logoZ = constrain(logoZ+d, .01, inchToPix(4f));
      if (logoZ > .01 && logoZ < inchToPix(4f))
      {
        if (45 <= logoRotation && logoRotation <= 135)
        leftTop (d);
        else if (135 <= logoRotation && logoRotation <= 225)
         leftBottom (d);
        else if (225 <= logoRotation && logoRotation <= 315)
                    rightBottom (d);

        else
          rightTop (d);
        
      }
    }
    else if (oldCircleX <= oldLogoX && oldCircleY >= oldLogoY)
    {
      
      println("leftBottom");
      if (dx >= 0 && dy <= 0)
        d *= -1;
      logoZ = constrain(logoZ+d, .01, inchToPix(4f));
      if (logoZ > .01 && logoZ < inchToPix(4f))
      {
        if (45 <= logoRotation && logoRotation <= 135)
          rightBottom (d);
        else if (135 <= logoRotation && logoRotation <= 225)
         rightTop (d);
        else if (225 <= logoRotation && logoRotation <= 315)
          leftTop (d);
        else
          leftBottom (d);
        
      }
    }
    else if (oldCircleX <= oldLogoX && oldCircleY <= oldLogoY)
    {
      
      println("leftTop");
      if (dx >= 0 && dy >= 0)
        d *= -1;
      logoZ = constrain(logoZ+d, .01, inchToPix(4f));
      if (logoZ > .01 && logoZ < inchToPix(4f))
      {
        if (45 <= logoRotation && logoRotation <= 135)
          leftBottom (d);
        else if (135 <= logoRotation && logoRotation <= 225)
         rightBottom (d);
        else if (225 <= logoRotation && logoRotation <= 315)
          rightTop (d);
        else
          leftTop (d);
      }
    } 
}
  
  if (canDragButton)
  {
    float dx = mouseX - rotationX0;
    float dy = mouseY - rotationY0;
    
    float res = 0;
    float resQ1 = (float)Math.atan((float)(dx/-dy));
    float resQ2 = (float)Math.atan((float)(-dx/-dy));
    float resQ3 = (float)Math.atan((float)(-dx/dy));
    float resQ4 = (float)Math.atan((float)(dx/dy));
    
    if (dy < 0)
    {
      res = resQ1;
      if (res < 0 && degrees(res) >= - 90)
        res = PI * 2 + res;
      //println("case 1");
    }
    else
    {
      //res = Math.pi
      res = (float)Math.PI - resQ4;
            println("case 2");

    }
    
    for (Circle c : circles)
      c.rotation = degrees(res);
    logoRotation = degrees(res);
    println("rotation (deg): "+logoRotation);
  }  
  
  }
  
void rightBottom (float d)
{
  if (d < 0) 
  {
    logoX -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 135));
    logoY += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 135)); 
  }
  else
  {
    logoX += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 135));
    logoY -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 135));   
  }       
}

void rightTop (float d)
{
  if (d < 0) 
  {
    logoX -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 45));
    logoY += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 45));
  }
  else 
  {
    logoX += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 45));
    logoY -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 45));
  }
}

void leftBottom (float d) {
  if (d < 0)
  {
    logoX -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 225));
    logoY += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 225));
  }
  else
  {
    logoX += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 225));
    logoY -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 225));
  }
}

void leftTop (float d) {
  if (d < 0)
  {
    logoX -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 315));
    logoY += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 315));
  }
  else
  {
    logoX += Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.sin(radians(logoRotation + 315));
    logoY -= Math.sqrt(Math.pow(d/2.0, 2)+Math.pow(d/2.0, 2)) * (float)Math.cos(radians(logoRotation + 315));
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
  //return (x >= logoZ  && x <= (width - logoZ) && y >= logoZ && y <= (height - logoZ));
  return (x > 0 && x < width && y > 0 && y < height);
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

boolean insideSubmit (int x, int y)
{
  return (x >= (submitX - submitZ) && x < (submitX + submitZ) && y >= (submitY - submitZ / 2.0) && y < (submitY + submitZ / 2.0));
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  //println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  //println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  //println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  //println("Close enough all: " + (closeDist && closeRotation && closeZ));

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
