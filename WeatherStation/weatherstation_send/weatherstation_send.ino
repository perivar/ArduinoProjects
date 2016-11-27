boolean debug=1;   //Set to 1 for console debugging

// see: https://github.com/mrkrasser/WeatherStation/blob/master/SensorNode/SensorNode.ino

#include <RH_ASK.h>
#include <SPI.h>   // from RH_ASK: not actually used but needed to compile
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_BMP085.h>

#define DHTPIN 2     // what digital pin we're connected to

// Uncomment whatever type you're using!
#define DHTTYPE DHT11   // DHT 11
//#define DHTTYPE DHT22   // DHT 22  (AM2302), AM2321
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// Connect pin 1 (on the left) of the sensor to +5V
// NOTE: If using a board with 3.3V logic like an Arduino Due connect pin 1
// to 3.3V instead of 5V!
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

// Initialize DHT sensor.
// Note that older versions of this library took an optional third parameter to
// tweak the timings for faster processors.  This parameter is no longer needed
// as the current DHT reading algorithm adjusts itself to work on faster procs.
DHT dht(DHTPIN, DHTTYPE);

// Connect VCC of the BMP085/BMP180 sensor to 3.3V (NOT 5.0V!)
// Connect GND to Ground
// Connect SCL to i2c clock - on '168/'328 Arduino Uno/Duemilanove/etc thats Analog 5
// Connect SDA to i2c data - on '168/'328 Arduino Uno/Duemilanove/etc thats Analog 4
Adafruit_BMP085 bmp;

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

// https://code.google.com/p/tinkerit/wiki/SecretVoltmeter
// reading power voltage using internal chip 1.1 reference
long readVcc() {
	long result;
	// Read 1.1V reference against AVcc
	ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
	delay(2); // Wait for Vref to settle
	ADCSRA |= _BV(ADSC); // Convert
	while (bit_is_set(ADCSRA,ADSC));
	result = ADCL;
	result |= ADCH<<8;
	result = 1126400L / result; // Back-calculate AVcc in mV
	return result;
}

void setup()
{
  if (debug==1)
  { 
    Serial.begin(9600);    // Debugging only
    Serial.println("Initializing ...");
  }

  // init DHT11 
  dht.begin();
       
  // init BMP 180
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP180 sensor, check wiring!");
  }  

  // init Radio
	if (!radio.init()) {
		Serial.println("Init failed!");
	} else {
		Serial.println("Init successful.");
		radio.setModeIdle();
		Serial.println("Radio Idle.");
	}
}

void loop()
{
  // Read data from DHT11
  sensor.dht11_h = dht.readHumidity();
  sensor.dht11_t = dht.readTemperature();   // Read temperature as Celsius

  // Read data from BMP180
  sensor.bmp180_t = bmp.readTemperature();
  sensor.bmp180_p = bmp.readPressure();
  sensor.bmp180_a = bmp.readAltitude();
    
	// Read Voltage value
	sensor.battery = readVcc();

	// Enable radio and send data
	radio.setModeTx();
  radio.send((uint8_t*)&sensor, sizeof(sensor));
	radio.waitPacketSent();
	radio.setModeIdle();

	// Debugging output
	if (debug==1)
	{ 
		Serial.print("DHT11    T:"); 
		Serial.print(sensor.dht11_t);
		Serial.print("*C ");
		Serial.print("H:"); 
		Serial.print(sensor.dht11_h);
		Serial.println("%\t");
		
		Serial.print("BMP180   T:");
		Serial.print(sensor.bmp180_t);
		Serial.print("*C ");
		Serial.print("P:");
		Serial.print(sensor.bmp180_p);
		Serial.print("Pa ");
		Serial.print("A:");
		Serial.print(sensor.bmp180_a);
		Serial.println("m");

    Serial.print("BATT     V:"); 
		Serial.print(readVcc());
    Serial.println(" mV");
	}

	// Sleep for next reading    
	delay(10000);
}

