/*
Transmitter for nRF24L01

nRF24L01 pin    Nano pin    Color (arbitrary)
CE   03         9(any)      orange
CS/N 04         10(any)     yellow
SCK  05         13          green
MOSI 06         11          blue
MISO 07         12          purple
IRQ  08         (none)      grey

Nano pins, in order   color
9                     orange
10                    yellow
11                    blue
12                    purple
13                    green

*/

// SimpleTx - the master or the transmitter
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include "printf.h"

#define CE_PIN   9
#define CSN_PIN 10

const byte slaveAddress[5] = {'R','x','A','A','A'};

RF24 radio(CE_PIN, CSN_PIN); // Create a Radio

char dataToSend[10] = "Message 0";
char txNum = '0';

unsigned long currentMillis;
unsigned long prevMillis;
unsigned long txIntervalMillis = 1000; // send once per second

void setup() {
  Serial.begin(115200);
  Serial.println("SimpleTx Starting");
  
  printf_begin();
  radio.begin();

  radio.setDataRate(RF24_2MBPS);
  radio.setPALevel(RF24_PA_LOW);
  //radio.setPALevel(RF24_PA_MAX);
  radio.setRetries(3,5); // delay, count
  radio.printDetails();

  radio.openWritingPipe(slaveAddress);
}

void loop() {
    currentMillis = millis();
    if (currentMillis - prevMillis >= txIntervalMillis) {
        send();
        prevMillis = millis();
    }
}

void send() {

    bool rslt;
    rslt = radio.write( &dataToSend, sizeof(dataToSend) );
    // Always use sizeof() as it gives the size as the number of bytes.
    // For example if dataToSend was an int sizeof() would correctly return 2

    Serial.print("Data Sent ");
    Serial.print(dataToSend);
    if (rslt) {
        Serial.println("  Acknowledge received");
        updateMessage();
    }
    else {
        Serial.println("  Tx failed");
    }
}

void updateMessage() {
    // so you can see that new data is being sent
    txNum += 1;
    if (txNum > '9') {
        txNum = '0';
    }
    dataToSend[8] = txNum;
}
 
