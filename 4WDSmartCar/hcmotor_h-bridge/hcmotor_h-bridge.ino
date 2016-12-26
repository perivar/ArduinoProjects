/* Include the library */
#include "HCMotor.h"

// Motor 1
int ENA = 10; // Needs to be a PWM pin to be able to control motor speed  
int IN1 = 9;  
int IN2 = 8;  

// Motor 2
int IN3 = 7;  
int IN4 = 6;  
int ENB = 5; // Needs to be a PWM pin to be able to control motor speed  

/* Pins used to drive the motors */
#define MOTOR_PINA IN3 //Connect to IN1 or IN3
#define MOTOR_PINB IN4 //Connect to IN2 or IN4

/* Set the analogue pin the potentiometer will be connected to. */
#define POT_PIN A0

/* Set a dead area at the centre of the pot where it crosses from forward to reverse */
#define DEADZONE 20 

/* The analogue pin will return values between 0 and 1024 so divide this up between 
   forward and reverse */
#define POT_REV_MIN 0
#define POT_REV_MAX (512 - DEADZONE)
#define POT_FWD_MIN (512 + DEADZONE)
#define POT_FWD_MAX 1204

/* Create an instance of the library */
HCMotor HCMotor;

void setup() {
  pinMode(ENA, OUTPUT); //Set all the L298n Pin to output
  pinMode(ENB, OUTPUT);
  analogWrite(ENA, 255); 
  analogWrite(ENB, 255);

  /* Initialise the library */
  HCMotor.Init();

  /* Attach motor 0 to digital pins defined by MOTOR_PINA and MOTOR_PINB. The first parameter specifies the 
     motor number, the second is the motor type, and the third and forth are the 
     digital pins that will control the motor */
  HCMotor.attach(0, DCMOTOR_H_BRIDGE, MOTOR_PINA, MOTOR_PINB);

  /* Set the duty cycle of the PWM signal in 100uS increments. 
     Here 100 x 100uS = 1mS duty cycle. */
  HCMotor.DutyCycle(0, 100);
}

void loop() {
  int Speed, Pot;

  /* Read the analogue pin to determine the position of the pot. */ 
  Pot = analogRead(POT_PIN);

  /* Is the pot in the reverse position ? */
  if (Pot >= POT_REV_MIN && Pot <= POT_REV_MAX) {
    HCMotor.Direction(0, REVERSE);
    Speed = map(Pot, POT_REV_MIN, POT_REV_MAX, 100, 0);

  /* Is the pot in the forward position ? */
  } else if (Pot >= POT_FWD_MIN && Pot <= POT_FWD_MAX) {
    HCMotor.Direction(0, FORWARD);
    Speed = map(Pot, POT_FWD_MIN, POT_FWD_MAX, 0, 100);

  /* Is the pot in the dead zone ? */
  } else {
    Speed = 0;
  }

  /* Set the on time of the duty cycle to match the position of the pot. */
  HCMotor.OnTime(0, Speed);
  
}
