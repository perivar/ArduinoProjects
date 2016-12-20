/********************
Arduino generic menu system
LCD menu - unsing arduino classic LCD library
http://www.r-site.net/?at=//op%5B%40id=%273090%27%5D

Sept.2014 Rui Azevedo - ruihfazevedo(@rrob@)gmail.com
creative commons license 3.0: Attribution-ShareAlike CC BY-SA
This software is furnished "as is", without technical support, and with no
warranty, express or implied, as to its usefulness for any purpose.

Thread Safe: No
Extensible: Yes
*/
#include <Arduino.h>
#include <Wire.h> 
#include <ClickEncoder.h> // Quad encoder
#include <TimerOne.h> 
#include <LiquidCrystal_I2C.h>
#include <menu.h>//menu macros and objects
#include <menuLCDs.h>//F. Malpartida LCD's
#include <menuFields.h>
#include <ClickEncoderStream.h> // New quadrature encoder driver and fake stream

#define LEDPIN LED_BUILTIN

LiquidCrystal_I2C lcd(0x3f, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);
// Addr, En, Rw, Rs, d4, d5, d6, d7, backlighpin, polarity

menuLCD menu_lcd(lcd,16,2);
////////////////////////////////////////////
// ENCODER (aka rotary switch) PINS
// rotary
#define CK_ENC  2 // Quand encoder on an ISR capable input
#define DT_ENC  3
#define SW_ENC  4

ClickEncoder qEnc(DT_ENC, CK_ENC, SW_ENC, 4, LOW);

/* Quad encoder */
ClickEncoderStream enc(qEnc, 1);// simple quad encoder fake Stream

void timerIsr() {qEnc.service();}

///////////////////////////////////////////////////////////////////////////
//functions to wire as menu actions
int frequency = 50;

//aux function
bool ledOn() {
    digitalWrite(LEDPIN,1);
    return true;
}

bool ledOff() {
  digitalWrite(LEDPIN,0);
  return true;
}

// close menu
bool exitMenu() {
  return true;
}

/////////////////////////////////////////////////////////////////////////
// MENU DEFINITION WITH MACROS
int adc_prescale = 64;

//a submenu
MENU(ledMenu,"LED on pin 13",
    OP("LED On",ledOn),
    OP("LED Off",ledOff)
);

CHOOSE(adc_prescale,sclock,"Sample:",
    VALUE("/ 128",128,menu::nothing),
    VALUE("/ 64",64,menu::nothing),
    VALUE("/ 32",32,menu::nothing),
    VALUE("/ 16",16,menu::nothing),
    VALUE("/ 8",8,menu::nothing)
);

MENU(mainMenu,"Main menu",
  FIELD(frequency,"Freq","Hz",0,100,1,0),
  OP("Empty",menu::nothing),
  OP("Empty",menu::nothing),
  SUBMENU(sclock),
  SUBMENU(ledMenu),
  OP("< BACK",exitMenu)
);
 
void setup() {
  Serial.begin(9600);
  Serial.println("menu system test");
  lcd.begin(16,2);
  
  // Encoder init
  qEnc.setAccelerationEnabled(false);
  qEnc.setDoubleClickEnabled(true); // must be on otherwise the menu library Hang

  // ISR init
  Timer1.initialize(5000); // every 0.05 seconds
  Timer1.attachInterrupt(timerIsr);
}

///////////////////////////////////////////////////////////////////////////////
// testing the menu system
void loop() {
      mainMenu.poll(menu_lcd,enc);
}
