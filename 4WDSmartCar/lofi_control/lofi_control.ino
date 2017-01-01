#include <SoftwareSerial.h>
// The Arduino hardware has built-in support for serial communication on pins 0 and 1 
// (which also goes to the computer via the USB connection). 
// Since we want to use the hardware serial at the same time as the bluetooth module
// we need to use SoftwareSerial on different pins.
SoftwareSerial bluetooth(12, 13); // RX, TX

int LEFT_MOTOR_PWM_PIN = 10;
int LEFT_MOTOR_1 = 9;
int LEFT_MOTOR_2 = 8;

int RIGHT_MOTOR_1 = 7;
int RIGHT_MOTOR_2 = 6;
int RIGHT_MOTOR_PWM_PIN = 5;

int BUZZER_PIN = 16;
int LED1_PIN = 9;
int LED2_PIN = 10;

int val = 0;
int horizontal = 50;
int vertical = 50;
int A_state = 0;
int B_state = 0;
char data[5];
int m1;
int m2;

void setup() {

  // Define L298N Dual H-Bridge Motor Controller Pins  
  // motor M1
  pinMode(LEFT_MOTOR_PWM_PIN, OUTPUT);
  pinMode(LEFT_MOTOR_1, OUTPUT);
  pinMode(LEFT_MOTOR_2, OUTPUT);

  // motor M2
  pinMode(RIGHT_MOTOR_PWM_PIN, OUTPUT);
  pinMode(RIGHT_MOTOR_1, OUTPUT);
  pinMode(RIGHT_MOTOR_2, OUTPUT);

  // buzzer
  //pinMode(BUZZER_PIN, OUTPUT);

  // diode LED
  //pinMode(LED1_PIN, OUTPUT);
  //pinMode(LED2_PIN, OUTPUT);

  Serial.begin(9600); // communicataion Arduino->Computer over USB cable
  bluetooth.begin(9600); // communicataion Arduino->HM-10 bluetooth

  // stop the motors
  motor1(true, 0);
  motor2(true, 0);
}

void loop() {

  if (bluetooth.available()) {
    bluetooth.readBytes(data, 5); // reception of data from application

    horizontal = int(data[1]); // horizontal axis joystick
    vertical = int(data[2]); // vertical axis joystick
    A_state = int(data[3]); // left button
    B_state = int(data[4]); // right button

    horizontal = horizontal * 2 - 100;
    vertical = vertical * 2 - 100;

    Serial.print("horizontal = ");
    Serial.print(horizontal);
    Serial.print(" vertical = ");
    Serial.print(vertical);
    Serial.print(" A = ");
    Serial.print(A_state);
    Serial.print(" B = ");
    Serial.println(B_state);

    //digitalWrite(BUZZER_PIN, A_state);
    //digitalWrite(LED1_PIN, B_state);
    //digitalWrite(LED2_PIN, B_state);

    m1 = vertical - horizontal;
    m2 = vertical + horizontal;

    int mm1 = min(255, 2.7 * abs(vertical - horizontal));
    int mm2 = min(255, 2.7 * abs(vertical + horizontal));

    if (m1 > 0) {
      motor1(true, mm1);
    } else {
      motor1(false, mm1);
    }

    if (m2 > 0) {
      motor2(true, mm2);
    } else {
      motor2(false, mm2);
    }

    // stop motors
    if (A_state) {
      motor1(true, 0);
      motor2(true, 0);      
    }
    
  }
}

void motor2(boolean direction, int power) {
  digitalWrite(LEFT_MOTOR_1, !direction);
  digitalWrite(LEFT_MOTOR_2, direction);
  analogWrite(LEFT_MOTOR_PWM_PIN, power);
}

void motor1(boolean direction, int power) {
  digitalWrite(RIGHT_MOTOR_1, !direction);
  digitalWrite(RIGHT_MOTOR_2, direction);
  analogWrite(RIGHT_MOTOR_PWM_PIN, power);
}
