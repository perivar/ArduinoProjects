//Code by Reichenstein7 (thejamerson.com), adapted for my application

//Keyboard Controls:
//
// 1 -Motor 1 Left
// 2 -Motor 1 Stop
// 3 -Motor 1 Right
//
// 4 -Motor 2 Left
// 5 -Motor 2 Stop
// 6 -Motor 2 Right

// Declare L298N Dual H-Bridge Motor Controller directly since there is not a library to load.

int SPEED = 255;

// Motor 1
int enA = 10; // Needs to be a PWM pin to be able to control motor speed
int in1 = 9;
int in2 = 8;

// Motor 2
int in3 = 7;
int in4 = 6;
int enB = 5; // Needs to be a PWM pin to be able to control motor speed

void setup() {  // Setup runs once per reset
	// initialize serial communication @ 9600 baud:
	Serial.begin(9600);

	//Define L298N Dual H-Bridge Motor Controller Pins
  pinMode(enA,OUTPUT);
  pinMode(enB,OUTPUT);
	pinMode(in1,OUTPUT);
	pinMode(in2,OUTPUT);
	pinMode(in3,OUTPUT);
	pinMode(in4,OUTPUT);
}

void loop() {
  
  // Initialize the Serial interface:
	if (Serial.available() > 0) {
		int inByte = Serial.read();

		switch (inByte) {

			//______________Motor 1______________
		case '1': // Motor 1 Forward
      analogWrite(enA, SPEED);//Sets speed variable via PWM 
			digitalWrite(in1, LOW);
			digitalWrite(in2, HIGH);
			Serial.print("Motor 1 Forward (Speed: "); // Prints out “Motor 1 Forward” on the serial monitor
      Serial.print(SPEED);
			Serial.println(")   "); // Creates a blank line printed on the serial monitor
			break;

		case '2': // Motor 1 Stop (Freespin)
      analogWrite(enA, 0);
			digitalWrite(in1, LOW);
			digitalWrite(in2, HIGH);
			Serial.println("Motor 1 Stop");
			Serial.println("   ");
			break;

		case '3': // Motor 1 Reverse
      analogWrite(enA, SPEED);
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      Serial.print("Motor 1 Reverse (Speed: ");
      Serial.print(SPEED);
      Serial.println(")   "); // Creates a blank line printed on the serial monitor
			break;

			//______________Motor 2______________

		case '4': // Motor 2 Forward
      analogWrite(enB, SPEED);
			digitalWrite(in3, LOW);
			digitalWrite(in4, HIGH);
      Serial.print("Motor 2 Forward (Speed: ");
      Serial.print(SPEED);
      Serial.println(")   "); // Creates a blank line printed on the serial monitor
			break;

		case '5': // Motor 1 Stop (Freespin)
      analogWrite(enB, 0);
			digitalWrite(in3, LOW);
			digitalWrite(in4, HIGH);
			Serial.println("Motor 2 Stop");
			Serial.println("   ");
			break;

		case '6': // Motor 2 Reverse
      analogWrite(enB, SPEED);
			digitalWrite(in3, HIGH);
			digitalWrite(in4, LOW);
      Serial.print("Motor 2 Reverse (Speed: ");
      Serial.print(SPEED);
      Serial.println(")   "); // Creates a blank line printed on the serial monitor
			break;
		}
	}
}
