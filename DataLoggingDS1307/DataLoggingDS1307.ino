/*
http://www.bajdi.com
SD card temperature logger and webserver with DS1307 RTC.

Time stamp is taken from a DS1307 RTC. The data of the DHT22, DS18B20 and RTC is also available on a webserver.
The time of the DS1307 RTC is synced with a timeserver once a day. (DS1307 is not accurate over a long time.) 
*/

#include <SPI.h>
#include <Wire.h>
#include "RTClib.h"
#include <DHT11.h>
#include <SD.h>
#include <LiquidCrystal_I2C.h>
#include <Adafruit_BMP085.h>

LiquidCrystal_I2C lcd(0x3f, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);
// Addr, En, Rw, Rs, d4, d5, d6, d7, backlighpin, polarity

int pin = A0;
DHT11 dht11(pin);

Adafruit_BMP085 bmp;

RTC_DS1307 RTC;
char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
int lastTime = -1;
int lastTime2 = -1;

// On the Ethernet Shield, CS is pin 4. It's set as an output by default.
// Note that even if it's not used as the CS pin, the hardware SS pin 
// (10 on most Arduino boards, 53 on the Mega) must be left as an output 
// or the SD library functions will not work. 
const int chipSelect = 4;         // CS for SD card
const int defaultSelectPin = 10;  // Uno R3

// set up variables using the SD utility library functions:
char filename[] = "00000000.CSV";
File dataFile;
Sd2Card card;
SdVolume volume;
SdFile root;

// Custom symbols
// https://omerk.github.io/lcdchargen/
static const byte DEGREES_CHAR = 1;
byte degrees_glyph[8] = { 0x00, 0x07, 0x05, 0x07, 0x00 };
static const byte SLASH_CHAR = 2;
byte slash_glyph[8] = {0x00,0x20,0x10,0x08};

void setup()
{
  lcd.begin(16, 2);
  // Register the custom symbols...
  lcd.createChar(DEGREES_CHAR, degrees_glyph);
  lcd.createChar(SLASH_CHAR, slash_glyph);
  lcd.backlight();

  Wire.begin();
  Serial.begin(9600);

  delay(300);//Wait for newly restarted system to stabilize  

  lcd.setCursor (0,0);
  lcd.print("Initializing");
  //lcd.print((char)DEGREES_CHAR); // print custom character
  //lcd.print((char)SLASH_CHAR); // print custom character
  delay(2000);
  lcd.setCursor (0,1);

  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP180 sensor, check wiring!");
    while (1) {}
  }

  if (!RTC.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  if (!RTC.isrunning()) {
    Serial.println("RTC is NOT running!");
    // following line sets the RTC to the date & time this sketch was compiled
    //rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    // rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
  }

  delay(100);
  Serial.println("Initializing SD card...");

  // make sure that the default chip select pin is declared OUTPUT, even if it's not used!
  pinMode(defaultSelectPin, OUTPUT);

  if (!SD.begin(4)) {
    Serial.println("SD initialization failed!");
    return;
  }
  Serial.println("SD initialization done.");
}

void loop()
{
  int err;
  float temp_dht11, humi_dht11;
  float temp_bmp180, press_bmp180;

  DateTime now = RTC.now();                              // get time from RTC

  int time = now.minute();
  if (abs(time - lastTime) > 5)
  {
    Serial.print(now.year(), DEC);
    Serial.print('/');
    Serial.print(now.month(), DEC);
    Serial.print('/');
    Serial.print(now.day(), DEC);
    Serial.print(" (");
    Serial.print(daysOfTheWeek[now.dayOfTheWeek()]);
    Serial.print(") ");
    Serial.print(now.hour(), DEC);
    Serial.print(':');
    Serial.print(now.minute(), DEC);
    Serial.print(':');
    Serial.print(now.second(), DEC);
    Serial.println();

    Serial.println("Reading Sensors ...");
    if ((err = dht11.read(humi_dht11, temp_dht11)) == 0)
    { 
      Serial.print("Successfully read DHT11 sensors: ");
      Serial.print(temp_dht11);
      Serial.print(" C , ");
      Serial.print(humi_dht11);
      Serial.print(" %");
      Serial.println();

      temp_bmp180 = bmp.readTemperature();
      press_bmp180 = bmp.readPressure();
      
      Serial.print("Successfully read BMP180 sensors: ");
      Serial.print(temp_bmp180);
      Serial.print(" C , ");
      Serial.print(press_bmp180);
      Serial.print(" Pa");
      Serial.println();

      lcd.backlight();
      lcd.clear();
      delay(500);
      lcd.setCursor(0, 0);
      lcd.print("Temp");
      lcd.setCursor(0, 1);
      lcd.print("Humidity");
      lcd.setCursor(9, 0);
      //lcd.print(temp_dht11);
      lcd.print(temp_bmp180);
      lcd.print((char)223);
      lcd.print("C");
      lcd.setCursor(9, 1);
      lcd.print(humi_dht11);
      lcd.print(" %");      

      getFilename(filename);

      dataFile = SD.open(filename, FILE_WRITE);

      // if the file is available, write to it:
      if (dataFile) {
        Serial.print("Saving to: ");
        Serial.print(filename);
        Serial.println();
        
        dataFile.print(now.day(), DEC);
        dataFile.print('/');
        dataFile.print(now.month(), DEC);
        dataFile.print('/');
        dataFile.print(now.year(), DEC);
        dataFile.print(" , ");
        dataFile.print(now.hour(), DEC);
        dataFile.print(':');
        dataFile.print(now.minute(), DEC);
        dataFile.print(" , ");
        dataFile.print(temp_dht11);
        dataFile.print(" , ");
        dataFile.print(humi_dht11);
        dataFile.print(" , ");
        dataFile.print(temp_bmp180);
        dataFile.print(" , ");
        dataFile.print(press_bmp180);
        dataFile.println();
        dataFile.close();
        Serial.println("Done writing to SD card.");

        //Serial.println(F("Posting!"));
        //postData();
        //delay(1000);
      } else {
        // if the file isn't open, pop up an error:
        Serial.print("Error opening ");
        Serial.println(filename);
      }
      lastTime = time;
    }    
  }

  delay(4000);
  lcd.noBacklight();
  delay(6000);
}

void getFilename(char *filename) {
  DateTime now = RTC.now(); 
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

void getFileName2(){
  DateTime now = RTC.now();
  sprintf(filename, "%02d%02d%02d.csv", now.year(), now.month(), now.day());
}


