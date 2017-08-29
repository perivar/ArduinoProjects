/*
Transmitter for nRF24L01

nRF24L01 pin    Nano pin    Color (arbitrary)
CE   03         7(any)      orange
CS/N 04         8(any)     yellow
SCK  05         13          green
MOSI 06         11          blue
MISO 07         12          purple
IRQ  08         (none)      grey

Nano pins, in order   color
7                     orange
8                     yellow
11                    blue
12                    purple
13                    green

Note by perivar@nerseth.com!
We are not using pin 9 and 10 since they are used by the rf24Audio methods since only pin 9 and 10 supports the 16bit timer needed to output to the speaker.
We are also using LOW_POWER as well as using external power since the nrf24 boards are drawing more amps than the USB port can handle.

*/

// SimpleTx - the master or the transmitter
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include "printf.h"

#define CE_PIN  7
#define CSN_PIN 8

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
 
