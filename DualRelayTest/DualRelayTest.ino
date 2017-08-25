const int Relay1 = 4; 
const int Relay2 = 5; 

void setup() 
{ 
  Serial.begin(115200);
  
  pinMode(Relay1, OUTPUT);  
  pinMode(Relay2, OUTPUT);

  Serial.print("Using pins ");
  Serial.print(Relay1);
  Serial.print(" and ");
  Serial.print(Relay2);
  Serial.println();
} 

void loop() 
{ 
  Serial.print("Sending LOW to pin ");
  Serial.println(Relay1);
  digitalWrite(Relay1, LOW);    // Turn on relay 
  
  Serial.print("Sending LOW to pin ");
  Serial.println(Relay2);
  digitalWrite(Relay2, LOW);    // Turn on relay 
  
  delay(1000); 
  Serial.print("Sending HIGH to pin ");
  Serial.println(Relay1);
  digitalWrite(Relay1, HIGH);   // Turn off relay 
  
  Serial.print("Sending HIGH to pin ");
  Serial.println(Relay2);
  digitalWrite(Relay2, HIGH);   // Turn off relay 
  
  delay(1000); 
}

