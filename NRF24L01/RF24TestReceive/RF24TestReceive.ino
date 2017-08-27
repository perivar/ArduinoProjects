/*
Receiver for nRF24L01

nRF24L01 pin    Nano pin    Color (arbitrary)
CE   03         9           orange
CS/N 04         10          yellow
SCK  05         13          green
MOSI 06         11          blue
MISO 07         12          purple
IRQ  08         (none)      grey

Nano pins, in order   Color
9                     orange
10                    yellow
11                    blue
12                    purple
13                    green
*/

// SimpleRx - the slave or the receiver
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include "printf.h"

#define CE_PIN   9
#define CSN_PIN 10

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

