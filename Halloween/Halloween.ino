#include <Servo.h>
#include <SoftwareSerial.h>
#include <DFPlayer_Mini_Mp3.h>

Servo myservo;    // create servo object to control a servo
int ledPin = 8;   // LED connected to digital pin 9
int servoPin = 5; // Servo connected to digital pin 5

SoftwareSerial mySerial(10, 11); // RX, TX

void setup () {

  // setup the sound player
  Serial.begin(9600);
  mySerial.begin(9600);
  mp3_set_serial(mySerial);  // set softwareSerial for DFPlayer-mini mp3 module 
  delay(1);                   // wait 1ms for mp3 module to set volume
  mp3_set_volume(28);        // value 0~30

  // setup led and servo
  pinMode(ledPin,OUTPUT);
  myservo.attach(servoPin); // attaches the servo on pin 5 to the servo object
}

void loop() {

  mp3_next();
 
  // fade in from min to max in increments of 5 points:
  for (int fadeValue = 0 ; fadeValue <= 255; fadeValue += 5) {
    // sets the value (range from 0 to 255):
    analogWrite(ledPin, fadeValue);

    myservo.write(fadeValue*0.7); 
    
    // wait for X milliseconds to see the dimming effect
    delay(60);
  }
  
  // how long LED stays on
  delay(random(100,800)); // Set values between 100 and 800

  // fade out from max to min in increments of 5 points:
  for (int fadeValue = 255 ; fadeValue >= 0; fadeValue -= 5) {
    // sets the value (range from 0 to 255):
    analogWrite(ledPin, fadeValue);

    myservo.write(fadeValue*0.7); 

    // wait for X milliseconds to see the dimming effect
    delay(10);
  }

  // amount of time leds are OFF before next eye turns on 9 seconds is pretty long but makes it harder to locate the eyes
  delay(random(30000,60000));
}
