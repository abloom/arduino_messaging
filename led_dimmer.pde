// #include <Ethernet.h>
#include <stdlib.h>
#include <string.h>
#include <Nixie.h>

// note the digital pins of the arduino that are connected to the nixie driver
#define dataPin 2  // data line or SER
#define clockPin 3 // clock pin or SCK
#define latchPin 4 // latch pin or RCK

// note the number of digits (nixie tubes) you have (buy more, you need more)
#define numDigits 2

#define MESSAGE_SIZE 2

// Create the Nixie object
// pass in the pin numbers in the correct order
Nixie nixie(dataPin, clockPin, latchPin);

// Server server(23);
  
void setup() {
  // byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
  // byte ip[] = { 10, 0, 0, 20 };

  // Ethernet.begin(mac, ip);
  // server.begin();
  
  nixie.clear(numDigits);
  
  Serial.begin(9600);
  Serial.println("ready");
}

void loop() {
  bool update_pin = false;
  char msg[MESSAGE_SIZE];
  
  // Client client = server.available();
  // if (client.available() == MESSAGE_SIZE) { // message ready to be collected
  //   update_pin = true;
  //   
  //   for(int i = 0; i < MESSAGE_SIZE; i++)
  //     msg[i] = client.read();
  //     
  // } else if (client.available() > MESSAGE_SIZE) {
  //   client.flush(); // clean garbage
  // }
  
  if (Serial.available() == MESSAGE_SIZE) { // message ready to be collected
    update_pin = true;
    
    for(int i = 0; i < MESSAGE_SIZE; i++)
      msg[i] = Serial.read();
      
  } else if (Serial.available() > MESSAGE_SIZE) {
    Serial.flush(); // clean garbage
  }
  
  if (update_pin) {
    int value = atoi(msg);
    
    Serial.print("Value: ");
    Serial.println(value);

    nixie.writeNumLeft(value);
    if (value == 0)
      nixie.writeNumLeft(value);
  }
}
