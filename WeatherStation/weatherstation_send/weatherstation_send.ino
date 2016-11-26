boolean debug=1;   //Set to 1 for console debugging

// see: https://github.com/mrkrasser/WeatherStation/blob/master/SensorNode/SensorNode.ino

#include <RH_ASK.h>
#include <SPI.h>   // from RH_ASK: not actually used but needed to compile

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

    Serial.print("Battery   :"); 
		Serial.print(readVcc());
    Serial.println(" mV");
	}

	// Sleep for next reading    
	delay(3000);
}

