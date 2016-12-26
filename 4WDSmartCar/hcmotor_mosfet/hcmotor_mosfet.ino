#include "HCMotor.h" //Include HCMotor Code Library
#define MOTOR_PIN 6 // Assign to PWM/Digital Pin 6 
#define POT_PIN A0 // Set analog pin at A0 for the potentiometer 


HCMotor HCMotor; // Create an instance of our code library
void setup()
{

	HCMotor.Init(); //Initialise our library
	HCMotor.attach(0, DCMOTOR, MOTOR_PIN); // Attach our motor to 0 to digital pin 6 
	HCMotor.DutyCycle(0, 100); //Set duty cycle of the PWM Pulse with Modulation signal in 100uS increment to 100uS = 1mS cycle
}

void loop()
{
	int Speed;
	Speed = map(analogRead(POT_PIN), 0, 1024, 0, 100); //Reading the A0 pin to determine the position of the pot. 
	//mapping the motor which could be 0 - 1024 and reduce down to match the cyccle range of 0 to 100 
	HCMotor.OnTime(0, Speed); // Set the duty cycle to match the position
}

