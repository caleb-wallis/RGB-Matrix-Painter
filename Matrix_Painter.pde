import controlP5.*; //library
ControlP5 cp5; //create ControlP5 object

import processing.serial.*;
Serial myPort;  // Create object from Serial class

import java.io.File;  // Import the File class
import java.io.FileNotFoundException;  // Import this class to handle errors
import java.util.Scanner; // Import the Scanner class to read text files
import java.io.FileWriter;   // Import the FileWriter class
import java.io.IOException;  // Import the IOException class to handle errors

class Rec {
  int num;
  int x, y, w, h;
  color c;
  Rec(int _num, int _x, int _y, int _w, int _h) {
    num = _num;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    c = color(0, 0, 0);
  }
  void draw() {

    fill(c);
    stroke(255, 255, 255);
    rect(x, y, w, h);
  }

  int getX() {
    return x;
  }

  void pressCheck( int _x, int _y ) {
    if ( _x > x && _y > y && _x < x+w && _y < y+h ) {

      float redVal = cp5.getController("red").getValue();
      float greenVal = cp5.getController("green").getValue();
      float blueVal = cp5.getController("blue").getValue();


      c = color(redVal, greenVal, blueVal);

      String rgbData = "<" + num + "," + redVal + "," + greenVal + "," + blueVal + ">";

      //myPort.write("<Banana, 20, 24.7>");
      myPort.write(rgbData);
    }
  }

  void resetColor() {
    c = color(0, 0, 0);
  }

  color getColor() {
    return c;
  }
}


class Slider {
  String name;
  int x, y, w, h;
  float min, max, sVal;
  color cVal;
  color cAct;

  Slider(String _name, int _x, int _y, int _w, int _h, float _min, float _max, float _sVal, color _cVal, color _cAct) {
    name = _name;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    min = _min;
    max = _max;
    sVal = _sVal;
    cVal = _cVal;
    cAct = _cAct;

    cp5.addSlider(name)
      .setPosition(x, y) //x and y upper left corner
      .setSize(w, h) //(width, height)50, 250
      .setRange(min, max) //slider range low,high
      .setValue(sVal) //start val
      .setColorValue(cVal) //vall color r,g,b
      .setColorActive(cAct) //mouse over color
      // .setScrollSensitivity(1)
      //  .setNumberOfTickMarks(20)
      ;
  }
}


class Button {
  String name;
  int x, y, w, h, val;

  Button(String _name, int _x, int _y, int _w, int _h, int _val) {
    name = _name;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    val = _val;

    cp5.addButton(name)
    .setBroadcast(false)
      .setPosition(x, y)
      .setSize(w, h)
      .setValue(val)
      .setBroadcast(true)
      ;
  }
}

String fileName = "ledSave.txt";

ArrayList<Rec> recs;
ArrayList<Slider> sliders;
ArrayList<Button> buttons;

void setup() {

  surface.setTitle("Matrix Software");
  surface.setResizable(true);


  size(displayWidth, displayHeight);

  myPort = new Serial(this, "COM3", 9600); 

  int videoScale = 30;

  recs = new ArrayList<Rec>();


  // Number of columns and rows in our system
  int cols, rows;

  // Initialize columns and rows

  cols = 16;
  rows = 16;

  int num = 0;

  for (int i = 0; i < cols; i++) {

    if (i%2 == 0) {

      for (int j = 0; j < rows; j++) {

        // Scaling up to draw a rectangle at (x,y)
        int x = i*videoScale;
        int y = j*videoScale;

        recs.add( new Rec(num, x, y, videoScale, videoScale) );

        num++;
      }
    } else {


      for (int j = rows - 1; j >= 0; j--) {

        // Scaling up to draw a rectangle at (x,y)
        int x = i*videoScale;
        int y = j*videoScale;

        recs.add( new Rec(num, x, y, videoScale, videoScale) );

        num++;
      }
    }
  }




  // for the sliders
  sliders = new ArrayList<Slider>();

  cp5 = new ControlP5(this);

  String sliderNames[] = {"red", "green", "blue"};

  for (int i = 0; i < sliderNames.length; i++) {

    String name = sliderNames[i];

    // int x = (displayW + recs.get(recs.size()-1).getX()) / 2;
    int x = displayWidth - 231;
    int y = i*videoScale;

    int w = 200;
    int h = 50;

    float min = 0;
    float max = 255;
    color cVal = color(0, 0, 0);

    if (name.equalsIgnoreCase("red")) {
      cVal = color(255, 0, 0);
    } else if (name.equalsIgnoreCase("green")) {
      cVal = color(0, 255, 0);
    } else {
      cVal = color(0, 0, 255);
    }

    float sVal = 255;
    color cAct = color(0, 0, 0);

    sliders.add(new Slider(name, x, y, w, h, min, max, sVal, cVal, cAct));
  }

  buttons = new ArrayList<Button>();

  int x = displayWidth - 231;
  int w = 200;
  int h = 50;
  int val = 0;

  buttons.add(new Button("clear", 800, 600, w, h, val));
  buttons.add(new Button("save", x, 700, w, h, val));
  buttons.add(new Button("open", x, 600, w, h, val));
  buttons.add(new Button("delete", x, 500, w, h, val));
  buttons.add(new Button("run all", x, 400, w, h, val));

  /*
String[] lines = loadStrings("list.txt");
   println("there are " + lines.length + " lines");
   for (int i = 0 ; i < lines.length; i++) {
   println(lines[i]);
   }
   */
}

/*

 What a led text file looks like:
 
 255 255 255
 0 0 0
 135 89 47
 
 Need the rgb values of every rectangle.
 
 Starting signal for reading the file.#
 
 Ending signal for reading the file.#
 
 */


// clears the led display

// need to write to arduino to turn of leds on matrix

public void clear() {
  System.out.println("clearing");
    for (int i = recs.size()-1; i >= 0; i--) {
      Rec aRec = (Rec) recs.get(i);
      aRec.resetColor();
    }
    myPort.write("c");
  }


// saves the led matrix 

// not currently working

// try to use the rec objects in the rec array

/*
public void save() {
  if (called != false) {
    System.out.println("Saving");

    String[] ledPattern = new String[256];

    for (int i = 0; i<recs.size(); i++) {
      Rec aRec = (Rec) recs.get(i);

      color recC = aRec.getColor();

      int r=(recC>>16)&255;
      int g=(recC>>8)&255;
      int b=recC&255;

      ledPattern[i] = r + " " + g + " " + b;
    }
    // Writes the strings to a file, each on a separate line
    saveStrings("ledTest.txt", ledPattern);
  }
}
*/

public void save() {
    try {
      FileWriter myWriter = new FileWriter(fileName);
      
      for (int i = 0; i<recs.size(); i++) {
      Rec aRec = (Rec) recs.get(i);

      color recC = aRec.getColor();

      int r=(recC>>16)&255;
      int g=(recC>>8)&255;
      int b=recC&255;
      
      myWriter.write(aRec.num + "," + r + "," + g + "," + b);
      
      }
      myWriter.close();
      System.out.println("Successfully wrote to the file.");
    } catch (IOException e) {
      System.out.println("An error occurred.");
      e.printStackTrace();
    }
}

// opens a file
public void open() {
    try {
       File myObj = new File(fileName);
      Scanner myReader = new Scanner(myObj);
      while (myReader.hasNextLine()) {
        String data = myReader.nextLine();
        print(data);
        
         /*
            c = color(redVal, greenVal, blueVal);

          String rgbData = "<" + num + "," + redVal + "," + greenVal + "," + blueVal + ">";
*/
      //myPort.write("<Banana, 20, 24.7>");
       myPort.write(data);
        
      }
      myReader.close();
    } catch (FileNotFoundException e) {
      print("An error occurred.");
      e.printStackTrace();
    }
}

// delete the selected file
public void delete() {
   File myObj = new File(fileName);
    if (myObj.delete()) { 
      System.out.println("Deleted the file: " + myObj.getName());
    } else {
      System.out.println("Failed to delete the file.");
    } 
}
// run all the saved led patterns

public void runAll() {
    myPort.write("<runAll>");
    //add for loop to add function
  }

// will be getting a micro sd card for file storage.
// this function will save file to sd instead of computer.
/*
void semdFile(String fileName){
 
 String[] ledPattern = loadStrings(fileName);
 println("there are " + ledPattern.length + " lines");
 for (int i = 0 ; i < ledPattern.length; i++) {
 myPort.write(ledPattern[i]);
 }
 
 }
 */

void draw() {

  background(0);
  for (int i = recs.size()-1; i >= 0; i--) {
    Rec aRec = (Rec) recs.get(i);
    aRec.draw();
  }
}

void mousePressed() {
  for (int i = recs.size()-1; i >= 0; i--) {
    Rec aRec = (Rec) recs.get(i);
    aRec.pressCheck(mouseX, mouseY);
  }
}

color rcolor() {
  return color( random(255), random(255), random(255) );
}
