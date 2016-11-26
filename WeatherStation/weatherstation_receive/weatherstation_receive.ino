boolean debug=1;   //Set to 1 for console debugging

// see: https://github.com/mrkrasser/WeatherStation/blob/master/DisplayNode/DisplayNode.ino

#include <RH_ASK.h>
#include <SPI.h>   // from RH_ASK: not actually used but needed to compile
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C display(0x3f, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);
// Addr, En, Rw, Rs, d4, d5, d6, d7, backlighpin, polarity

RH_ASK radio;
// RH_ASK radio(2000, 2, 4, 5); // ESP8266: do not use pin 11

struct SensorData { 
	float dht11_t;
	float dht11_h;
	float bmp180_t;
	float bmp180_p;
	float bmp180_a;
	long battery;
};

SensorData sensor;

void setup()
{
	if (debug==1)
	{ 
		Serial.begin(9600); 
		Serial.println("Initializing ...");
	}

	// Setting up LCD
	display.begin(16, 2);
	display.backlight();
	display.setCursor(0, 0);
	display.print("Reidar's");
	display.setCursor(0, 1);
	display.print("Vaerstasjon");
	delay(4000);
	//display.noBacklight();

	if (!radio.init()) {
		Serial.println("Init failed!");
	} else {
		Serial.println("Init successful.");
		radio.setModeRx();
	}
}

void loop()
{
	uint8_t buf[RH_ASK_MAX_MESSAGE_LEN];
	uint8_t buflen = sizeof(buf);
	
	if (radio.recv(buf, &buflen)) // Non-blocking
	{
		memcpy(&sensor, &buf, sizeof(sensor)); 
				
		// show data on screen
		//display.backlight();
		display.clear();
		display.setCursor(0, 0);
    display.print("Temp: "); 
    display.print(sensor.dht11_t);
    display.print(" *C");
    
    display.setCursor(0, 1);
		display.print("Bat.: ");
		display.print(sensor.battery);
		display.print(" mV");
    delay(3000);
    display.clear();
    //display.noBacklight();
		
		// print data for debugging
		if (debug==1)
		{ 
      // Message with a good checksum received, dump it.
      radio.printBuffer("Received:", buf, buflen);
      
			Serial.print("DHT11    T:"); 
			Serial.print(sensor.dht11_t);
			Serial.print("*C ");
			Serial.print("H:"); 
			Serial.print(sensor.dht11_h);
			Serial.println("%");
			
			Serial.print("BMP180   T:");
			Serial.print(sensor.bmp180_t);
			Serial.print("*C ");
			Serial.print("P:");
			Serial.print(sensor.bmp180_p);
			Serial.print("Pa ");
			Serial.print("A:");
			Serial.print(sensor.bmp180_a);
			Serial.println("m");
			
			Serial.print("Bat.:");
			Serial.print(sensor.battery);
			Serial.println("mV");
		}        
	}
}
