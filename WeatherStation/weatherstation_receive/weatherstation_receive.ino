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
#include <menu.h> // menu macros and objects
#include <menuLCDs.h> // F. Malpartida LCD's
#include <menuFields.h>
#include <ClickEncoderStream.h> // New quadrature encoder driver and fake stream

#define LEDPIN LED_BUILTIN

LiquidCrystal_I2C display(0x3f, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);
// Addr, En, Rw, Rs, d4, d5, d6, d7, backlighpin, polarity

////////////////////////////////////////////
// ENCODER (aka rotary switch) PINS
#define CK_ENC  2 // Quad encoder on an ISR capable input
#define DT_ENC  3
#define SW_ENC  4

////////////////////////////////////////////
// Click Encoder
ClickEncoder qEnc(DT_ENC, CK_ENC, SW_ENC, 4, LOW);

int16_t last, value;

void timerIsr() { 
  qEnc.service(); 
}

////////////////////////////////////////////
// ICONS
// http://maxpromer.github.io/LCD-Character-Creator/
static const byte THERMO_CHAR = 1;
byte thermo[8] = 
{
	B00100,
	B01010,
	B01010,
	B01110,
	B01110,
	B11111,
	B11111,
	B01110
};

static const byte DROPLET_CHAR = 2;
byte waterdroplet[8] = 
{
	B00100,
	B00100,
	B01010,
	B01010,
	B10001,
	B10001,
	B10001,
	B01110,
};

static const byte SIGNAL_CHAR = 3;
byte signal[8] = 
{
	B00001,
	B00001,
	B00001,
	B00101,
	B00101,
	B10101,
	B10101,
	B10101
};

static const byte BATTERY_CHAR = 4;
byte battery[8] = {
  B01110,
  B11011,
  B10001,
  B10001,
  B10001,
  B10001,
  B10001,
  B11111
};

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
		Serial.println(F("Init ..."));
	}
 
	// Setting up LCD
	display.begin(16, 2);
	display.backlight();
	display.clear();
	display.createChar(THERMO_CHAR, thermo);
	display.createChar(DROPLET_CHAR, waterdroplet);
	display.createChar(SIGNAL_CHAR, signal);
  display.createChar(BATTERY_CHAR, battery);

	// Print boot sequence
	displayBootSequence();
  display.clear();

	if (!rtc.begin()) {
		Serial.println(F("RTC Missing!"));
		while (1);
	}

	if (!rtc.isrunning()) {
		Serial.println(F("RTC Failed!"));
	} else {
		// following line sets the RTC to the date & time this sketch was compiled
		// comment out after this has been set once.
		rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

    Serial.println(F("RTC OK"));
		
		// Print Now
		displayTime();
	}

	if (!radio.init()) {
		Serial.println(F("Radio Failed!"));
	} else {
		Serial.println(F("Radio OK."));
		radio.setModeRx();
	}

	Serial.println(F("Init SD card ..."));
	// make sure that the default chip select pin is declared OUTPUT, even if it's not used!
	pinMode(defaultSelectPin, OUTPUT);

	Serial.println(F("Init done!"));

	display.setCursor(0, 1);
	display.print(F("Venter ..."));
  
  // Encoder init
  qEnc.setAccelerationEnabled(false);
  qEnc.setDoubleClickEnabled(true); // must be on otherwise the menu library Hang

  /*
  // ISR makes the RF stop working?!
  // ISR init
  Timer1.initialize(5000); // every 0.05 seconds
  Timer1.attachInterrupt(timerIsr);
  */
}

void loop()
{
	uint8_t buf[RH_ASK_MAX_MESSAGE_LEN];
	uint8_t buflen = sizeof(buf);

  /*
  // handle click encoder
  value += qEnc.getValue();
  if (value != last) {
    last = value;
    Serial.print(F("Encoder Value: "));
    Serial.println(value);
  }

  // check the encoder button
  ClickEncoder::Button b = qEnc.getButton();
  if (b != ClickEncoder::Open) {
    Serial.print(F("Button: "));
    #define VERBOSECASE(label) case label: Serial.println(F(#label)); break;
    switch (b) {
      VERBOSECASE(ClickEncoder::Pressed)
      VERBOSECASE(ClickEncoder::Held)
      VERBOSECASE(ClickEncoder::Released)
      case ClickEncoder::Clicked:
        Serial.println("ClickEncoder::Clicked");
        displayBattery();
        break;
      case ClickEncoder::DoubleClicked:
        Serial.println("ClickEncoder::DoubleClicked");
        displayPressure();
        break;
    }   
  }  
  */

  // Check if we have received any data from the RF radio
	if (radio.recv(buf, &buflen)) // Non-blocking
	{
    displaySignalOn();
    
		memcpy(&sensor, &buf, sizeof(sensor)); 

		// get now
		DateTime now = rtc.now();  

    displayTime();
    displayTempAndHumid();
    
		// store to SD card
		getFileName(filename);

		dataFile = SD.open(filename, FILE_WRITE);

		// if the file is available, write to it:
		if (dataFile) {
      if (debug==1) { 
  			Serial.print(F("Saving to: "));
  			Serial.print(filename);
  			Serial.println();
      }
			
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
			if (debug==1) Serial.println(F("Done writing to SD card."));
		}

    debugReceivedData(now, buf, buflen);
    delay(500);
    displaySignalOff(); 
	}
}

// print data for debugging
void debugReceivedData(DateTime now, uint8_t buf, uint8_t buflen) {
  if (debug==1) { 
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

void displayBootSequence() {
	display.setCursor(0, 0);
	display.print(F("Reidar's"));
	display.setCursor(0, 1);
	display.print(F("Vaerstasjon "));
	delay(3000);
	//display.noBacklight();  
}

void displayBatteryLowOn() {
  display.setCursor(15, 1);
  display.print((char)BATTERY_CHAR);
}

void displayBatteryLowOff() {
  display.setCursor(15, 1);
  display.print(' ');
}

void displaySignalOn() {
  display.setCursor(15, 0);
  display.print((char)SIGNAL_CHAR);
}

void displaySignalOff() {
  display.setCursor(15, 0);
  display.print(' ');
}

void clearLine(int col) {
  display.setCursor(0, col);
  display.print(F("                "));
}

void displayTempAndHumid() {
  clearLine(1);

	display.setCursor(1, 1);
	display.print((char)THERMO_CHAR);
	display.setCursor(3, 1);
	//display.print(sensor.dht11_t, 0);
	display.print(sensor.bmp180_t, 0);
	display.setCursor(5, 1);
	display.print((char)223); //degree sign
	display.print("C");

	display.setCursor(9, 1);
	display.print((char)DROPLET_CHAR);
	display.setCursor(11, 1);
	display.print(sensor.dht11_h, 0);
	display.print("%");
	//delay(2000);
}

void displayBattery() {
  clearLine(1);
  
  display.setCursor(0, 1);
  display.print(F("Bat.: "));
  display.print(sensor.battery);
  display.print(F(" mV"));
  //delay(2000);
}

void displayTime() {
	DateTime now = rtc.now();      
	display.setCursor(0, 0);
	displayPrint2Digits(now.hour());
	display.print(':');
	displayPrint2Digits(now.minute());
	//display.print(':');
	//displayPrint2Digits(now.second());    

	display.print(F(" "));
	displayPrint2Digits(now.day());
	display.print(F("/"));
	displayPrint2Digits(now.month());
	display.print(F("/"));
	displayPrint2Digits(now.year()-2000);	
	//delay(2000);
}

void displayPressure() {
  display.clear();
  display.setCursor(0, 0);
  display.print(sensor.bmp180_p);
  display.print(F(" Pa"));
  display.setCursor(0, 1);
  display.print(sensor.bmp180_a);
  display.print(F(" m"));
  //delay(2000);
}

// this adds a 0 before single digit numbers
void displayPrint2Digits(int number) { 
	if (number >= 0 && number < 10) {
		display.write('0');
	}
	display.print(number);
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


