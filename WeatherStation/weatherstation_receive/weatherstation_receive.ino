boolean debug=1;   //Set to 1 for console debugging

// see: https://github.com/mrkrasser/WeatherStation/blob/master/DisplayNode/DisplayNode.ino

#include <RH_ASK.h>
#include <SPI.h>   // from RH_ASK: not actually used but needed to compile
#include <Wire.h> // Date and time functions using a DS1307 RTC connected via I2C and Wire lib
#include "RTClib.h"
#include <LiquidCrystal_I2C.h>
#include <SD.h>

#include <ClickEncoder.h> // Quad encoder
#include <TimerOne.h> 
#include <menu.h>//menu macros and objects
#include <menuLCDs.h>//F. Malpartida LCD's
#include <menuFields.h>
#include <ClickEncoderStream.h> // New quadrature encoder driver and fake stream

////////////////////////////////////////////
// ENCODER (aka rotary switch) PINS
// rotary
#define CK_ENC  2 // Quand encoder on an ISR capable input
#define DT_ENC  3
#define SW_ENC  4

LiquidCrystal_I2C display(0x3f, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);
// Addr, En, Rw, Rs, d4, d5, d6, d7, backlighpin, polarity

RTC_DS1307 rtc;

RH_ASK radio;
// RH_ASK radio(2000, 2, 4, 5); // UNO: use pin 11

struct SensorData { 
	float dht11_t;
	float dht11_h;
	float bmp180_t;
	float bmp180_p;
	float bmp180_a;
	long battery;
};

SensorData sensor;

// On the Ethernet Shield, CS is pin 4. It's set as an output by default.
// Note that even if it's not used as the CS pin, the hardware SS pin 
// (10 on most Arduino boards, 53 on the Mega) must be left as an output 
// or the SD library functions will not work. 
const int chipSelect = 5;         // CS for SD card // CHANGED FROM DEFAULT 4 to 5
const int defaultSelectPin = 10;  // Uno R3

// set up variables using the SD utility library functions:
char filename[] = "00000000.CSV";
File dataFile;

void setup()
{
	if (debug==1)
	{ 
		Serial.begin(9600); 
		Serial.println(F("Initializing ..."));
	}

	// Setting up LCD
	display.begin(16, 2);
	display.backlight();
	display.setCursor(0, 0);
	display.print("Reidar's");
	display.setCursor(0, 1);
	display.print("Vaerstasjon");
	delay(3000);
	//display.noBacklight();

	if (!rtc.begin()) {
		Serial.println(F("Couldn't find RTC"));
		while (1);
	}

	if (!rtc.isrunning()) {
		Serial.println(F("RTC is NOT running!"));
	} else {
		// following line sets the RTC to the date & time this sketch was compiled
		rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

		// Print Now
		DateTime now = rtc.now();      
		display.clear();
		display.setCursor(0, 0);
		display.print(now.year(), DEC);
		display.print('/');
		display.print(now.month(), DEC);
		display.print('/');
		display.print(now.day(), DEC);
		display.setCursor(0, 1);
		display.print(now.hour(), DEC);
		display.print(':');
		display.print(now.minute(), DEC);
		display.print(':');
		display.print(now.second(), DEC);    
		delay(2000);
	}

	if (!radio.init()) {
		Serial.println(F("Init failed!"));
	} else {
		Serial.println(F("Init successful."));
		radio.setModeRx();
	}

	Serial.println(F("Initializing SD card..."));
	// make sure that the default chip select pin is declared OUTPUT, even if it's not used!
	pinMode(defaultSelectPin, OUTPUT);

  Serial.println(F("Initialization done!"));
}

void loop()
{
	uint8_t buf[RH_ASK_MAX_MESSAGE_LEN];
	uint8_t buflen = sizeof(buf);
	
	if (radio.recv(buf, &buflen)) // Non-blocking
	{
		memcpy(&sensor, &buf, sizeof(sensor)); 
		
		// show data on screen
		display.backlight();
		//display.clear();
		display.setCursor(0, 0);
		display.print(F("Temp: ")); 
		display.print(sensor.dht11_t);
		display.print(F(" *C"));
		
		display.setCursor(0, 1);
		display.print(F("Bat.: "));
		display.print(sensor.battery);
		display.print(F(" mV"));
		delay(3000);
		//display.clear();
		display.noBacklight();

		// get now
		DateTime now = rtc.now();  
		
		// store to SD card
		getFileName(filename);

		dataFile = SD.open(filename, FILE_WRITE);

		// if the file is available, write to it:
		if (dataFile) {
			Serial.print(F("Saving to: "));
			Serial.print(filename);
			Serial.println();
			
			dataFile.print(now.day(), DEC);
      dataFile.print(F("/"));
			dataFile.print(now.month(), DEC);
      dataFile.print(F("/"));
			dataFile.print(now.year(), DEC);
			dataFile.print(F(" , "));
			dataFile.print(now.hour(), DEC);
      dataFile.print(F(":"));
			dataFile.print(now.minute(), DEC);
		  dataFile.print(F(" , "));
      dataFile.print(sensor.dht11_t);
      dataFile.print(F(" , "));
			dataFile.print(sensor.dht11_h);
      dataFile.print(F(" , "));
			dataFile.print(sensor.bmp180_t);
      dataFile.print(F(" , "));
			dataFile.print(sensor.bmp180_p);
      dataFile.print(F(" , "));
			dataFile.print(sensor.bmp180_a);
      dataFile.print(F(" , "));
			dataFile.print(sensor.battery);
			dataFile.println();
			dataFile.close();
			Serial.println(F("Done writing to SD card."));
		}
		
		// print data for debugging
		if (debug==1)
		{ 
			// Print Now    
			Serial.print(now.year(), DEC);
      Serial.print(F("/"));
			Serial.print(now.month(), DEC);
      Serial.print(F("/"));
			Serial.print(now.day(), DEC);
      Serial.print(F(" "));
			Serial.print(now.hour(), DEC);
      Serial.print(F(":"));
			Serial.print(now.minute(), DEC);
      Serial.print(F(":"));
			Serial.print(now.second(), DEC);
			Serial.println();
			
			// Message with a good checksum received, dump it.
			radio.printBuffer("Received:", buf, buflen);
			
			Serial.print(F("DHT11    T:")); 
			Serial.print(sensor.dht11_t);
			Serial.print(F("*C "));
			Serial.print(F("H:")); 
			Serial.print(sensor.dht11_h);
			Serial.println(F("%"));
			
			Serial.print(F("BMP180   T:"));
			Serial.print(sensor.bmp180_t);
			Serial.print(F("*C "));
			Serial.print(F("P:"));
			Serial.print(sensor.bmp180_p);
			Serial.print(F("Pa "));
			Serial.print(F("A:"));
			Serial.print(sensor.bmp180_a);
			Serial.println(F("m"));

			Serial.print(F("BATT     V:")); 
			Serial.print(sensor.battery);
			Serial.println(F(" mV"));
		}        
	}
}

// don't use sprintf since it consumes more ram
// https://forum.arduino.cc/index.php?topic=127933.0
void getFileName(char *filename) {
	DateTime now = rtc.now(); 
	int year = now.year(); 
	int month = now.month(); 
	int day = now.day();
	filename[0] = '2';
	filename[1] = '0';
	filename[2] = (year-2000)/10 + '0';
	filename[3] = year%10 + '0';
	filename[4] = month/10 + '0';
	filename[5] = month%10 + '0';
	filename[6] = day/10 + '0';
	filename[7] = day%10 + '0';
	filename[8] = '.';
	filename[9] = 'C';
	filename[10] = 'S';
	filename[11] = 'V';
	return;
}


