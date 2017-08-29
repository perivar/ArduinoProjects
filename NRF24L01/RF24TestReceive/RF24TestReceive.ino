/*
Receiver for nRF24L01

nRF24L01 pin    Nano pin    Color (arbitrary)
CE   03         7           orange
CS/N 04         8          yellow
SCK  05         13          green
MOSI 06         11          blue
MISO 07         12          purple
IRQ  08         (none)      grey

Nano pins, in order   Color
7                     orange
8                     yellow
11                    blue
12                    purple
13                    green

Note by perivar@nerseth.com!
We are not using pin 9 and 10 since they are used by the rf24Audio methods since only pin 9 and 10 supports the 16bit timer needed to output to the speaker.
We are also using LOW_POWER as well as using external power since the nrf24 boards are drawing more amps than the USB port can handle.

*/

// SimpleRx - the slave or the receiver
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include "printf.h"

#define CE_PIN  7
#define CSN_PIN 8

const byte thisSlaveAddress[5] = {'R','x','A','A','A'};

RF24 radio(CE_PIN, CSN_PIN);

char dataReceived[10]; // this must match dataToSend in the TX
bool newData = false;

void setup() {
  Serial.begin(115200);
  Serial.println("SimpleRx Starting");
  
  printf_begin();
  radio.begin();

  radio.setDataRate(RF24_2MBPS);
  radio.setPALevel(RF24_PA_LOW);  
  //radio.setPALevel(RF24_PA_MAX);
  radio.printDetails();

  radio.openReadingPipe(1, thisSlaveAddress);
  radio.startListening();
}

void loop() {
    getData();
    showData();
}

void getData() {
    if ( radio.available() ) {
        radio.read( &dataReceived, sizeof(dataReceived) );
        newData = true;
    }
}

void showData() {
    if (newData == true) {
        Serial.print("Data received ");
        Serial.println(dataReceived);
        newData = false;
    }
} 

