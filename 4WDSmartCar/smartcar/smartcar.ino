#include <SmartCarLib.h>
#include <SoftwareSerial.h>
// The Arduino hardware has built-in support for serial communication on pins 0 and 1 
// (which also goes to the computer via the USB connection). 
// Since we want to use the hardware serial at the same time as the bluetooth module
// we need to use SoftwareSerial on different pins.

SoftwareSerial bluetooth(2, 3); // RX, TX
String receivedBluetoothString = "";

int LEFT_MOTOR_PWM_PIN = 10;
int LEFT_MOTOR_1 = 9;
int LEFT_MOTOR_2 = 8;

int RIGHT_MOTOR_1 = 7;
int RIGHT_MOTOR_2 = 6;
int RIGHT_MOTOR_PWM_PIN = 5;

SmartCar smartcar(LEFT_MOTOR_1, LEFT_MOTOR_2, LEFT_MOTOR_PWM_PIN, RIGHT_MOTOR_1, RIGHT_MOTOR_2, RIGHT_MOTOR_PWM_PIN);

// example variable to test the bluetooth connection
boolean ledState = HIGH;

void setup(){
  Serial.begin(9600);
  bluetooth.begin(9600); // default baud rate
  
  while(!Serial); //if it is an Arduino Micro or Leonardo
  Serial.println("Serial ready to send and receive AT commands.");
}

void loop(){
  
  // read from the bluetooth device and print in the Serial
  //if(bluetooth.available())
  //  Serial.write(bluetooth.read());

  while (bluetooth.available() > 0) {
 
    char receivedBluetoothChar = bluetooth.read();
    receivedBluetoothString += receivedBluetoothChar;
 
    if (receivedBluetoothChar == '\n') {
 
      if (receivedBluetoothString.toInt() == 10) {
        Serial.println("left");
        smartcar.handleCar("L\n");
        delay(1000);
      }
      else if (receivedBluetoothString.toInt() == 20) {
        Serial.println("right");
        smartcar.handleCar("R\n");
        delay(1000);
      }
      else if (receivedBluetoothString.toInt() == 30) {
        Serial.println("forward");
        smartcar.handleCar("F\n");
        delay(1000);
      }
      else if (receivedBluetoothString.toInt() == 40) {
        Serial.println("backward");
        smartcar.handleCar("B\n");
        delay(1000);
      }
      else if (receivedBluetoothString.endsWith("Slider\n")) {
        Serial.print("Slider: ");
        Serial.println(receivedBluetoothString.toInt());
      }

      Serial.print(receivedBluetoothString);
      receivedBluetoothString = "";
    }
  }
  
  // read from the Serial and print to the bluetooth device
  if(Serial.available())
    bluetooth.write(Serial.read());

 /*
  handleCar receives: 
  "F\n" - Move forward
  "B\n" - Move backward
  "L\n" - Move left
  "R\n" - Move right
  To Stop simply send the same value again.
  */

  /*
  smartcar.handleCar("L\n");
  delay(2000);

  smartcar.handleCar("R\n");
  delay(2000);

  smartcar.handleCar("F\n");
  delay(2000);

  smartcar.handleCar("B\n");
  delay(2000);
  */
}


