// Example 5 - Receive with start- and end-markers combined with parsing

const byte numChars = 32;
char receivedChars[numChars];
char tempChars[numChars];        // temporary array for use when parsing

// variables to hold the parsed data
//char messageFromPC[numChars] = {0};
//int integerFromPC = 0;
//float floatFromPC = 0.0;

int rgbData[4]; 

boolean newData = false;



// necessary for rgb matrix

#include <FastLED.h>

#define NUM_LEDS  256
#define LED_PIN   2

CRGB leds[NUM_LEDS];


//============

void setup() {
    Serial.begin(9600);
    Serial.println("This demo expects 3 pieces of data - text, an integer and a floating point value");
    Serial.println("Enter data in this style <HelloWorld, 12, 24.7>  ");
    Serial.println();
    
    //setup led matrix
    FastLED.addLeds<WS2812B, LED_PIN, GRB>(leds, NUM_LEDS);
    FastLED.setBrightness(255); // max brightness
    // FastLED.setBrightness(25);  // low brightness
}

//============

/*
 * Will use the link below to have an active image.
 * https://stackoverflow.com/questions/64675252/is-there-a-variable-that-doesnt-reset-each-time-an-application-is-launched
 * 
 * To do so I would need to have a boolean of whether they are drawing or are finished. Aka if pressed save they are not drawing. 
 * If mouse clicks a square they are not finished.
 * 
 * I could set the filename in the custom led file reader to the saved string so there would always be an image/s that the user chose.
 * 
 * Will be getting a micro sd card reader to store text files. 
*/

void loop() {
    recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
            // this temporary copy is necessary to protect the original data
            //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        showParsedData();
        newData = false;
    }
}

//============

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;
    char clearAll = 'c';

    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();
        
        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }

        else if(rc == clearAll){
          clearMatrix();
          }
    }
}

//============

void parseData() {      // split the data into its parts

    char * strtokIndx; // this is used by strtok() as an index

//String Parsing

  //  strtokIndx = strtok(tempChars,",");      // get the first part - the string
  //  strcpy(messageFromPC, strtokIndx); // copy it to messageFromPC

// Integer Parsing
 
    strtokIndx = strtok(tempChars, ","); // this continues where the previous call left off
    rgbData[0] = atoi(strtokIndx);     // convert this part to an integer

     strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    rgbData[1] = atoi(strtokIndx);     // convert this part to an integer

     strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    rgbData[2] = atoi(strtokIndx);     // convert this part to an integer

     strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    rgbData[3] = atoi(strtokIndx);     // convert this part to an integer

// Float Parsing

 //   strtokIndx = strtok(NULL, ",");
  //  floatFromPC = atof(strtokIndx);     // convert this part to a float

}

//============

void showParsedData() {
  /*
    Serial.print("Message ");
    Serial.println(messageFromPC);
    */
    Serial.println("Integer ");
//    Serial.println(integerFromPC);

    for(int i=0; i<4; i++){
      Serial.println(rgbData[i]);
      }
    /*
    Serial.print("Float ");
    Serial.println(floatFromPC);
*/

  leds[rgbData[0]] = CRGB(rgbData[1], rgbData[2], rgbData[3]);
  FastLED.show();
   
}

void clearMatrix()  {
  
  for(int i=0; i<NUM_LEDS; i++){
     leds[i] = CRGB(0, 0, 0);
    }
     FastLED.show();
  }
