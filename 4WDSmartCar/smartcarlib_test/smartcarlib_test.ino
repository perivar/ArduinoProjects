#include <SmartCarLib.h>

/*
int LEFT_MOTOR_1 = 10;
int LEFT_MOTOR_2 = 11;
int LEFT_MOTOR_PWM_PIN = 6;

int RIGHT_MOTOR_1 = 12;
int RIGHT_MOTOR_2 = 13;
int RIGHT_MOTOR_PWM_PIN = 5;
*/

int LEFT_MOTOR_PWM_PIN = 10;
int LEFT_MOTOR_1 = 9;
int LEFT_MOTOR_2 = 8;

int RIGHT_MOTOR_1 = 7;
int RIGHT_MOTOR_2 = 6;
int RIGHT_MOTOR_PWM_PIN = 5;

SmartCar smartcar(LEFT_MOTOR_1, LEFT_MOTOR_2, LEFT_MOTOR_PWM_PIN, RIGHT_MOTOR_1, RIGHT_MOTOR_2, RIGHT_MOTOR_PWM_PIN);

void setup() {
}

void loop() {
	/*
	handleCar receives: 
	"F\n" - Move forward
	"B\n" - Move backward
	"L\n" - Move left
	"R\n" - Move right
	To Stop simply send the same value again.
	*/
	
	smartcar.handleCar("L\n");
	delay(2000);

	smartcar.handleCar("R\n");
	delay(2000);

	smartcar.handleCar("F\n");
	delay(2000);

	smartcar.handleCar("B\n");
	delay(2000);
}
