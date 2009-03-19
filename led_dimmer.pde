#include <Ethernet.h>
#include <stdlib.h>
#include <string.h>

#define LED1_PIN 6
#define LED2_PIN 9
#define MESSAGE_SIZE 4

Server server(23);
  
void setup() {
  byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
  byte ip[] = { 10, 0, 0, 20 };

  Ethernet.begin(mac, ip);
  server.begin();
  
  Serial.begin(9600);
  Serial.println("ready");

  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  
  // blink pins when booted
  for(int i = 0; i < 7; i++) {
    digitalWrite(LED1_PIN, (i % 2 == 0 ? LOW : HIGH));
    digitalWrite(LED2_PIN, (i % 2 == 0 ? LOW : HIGH));
    delay(125);
  }
}

void loop() {
  bool update_pin = false;
  char msg[MESSAGE_SIZE];
  
  Client client = server.available();
  if (client.available() == MESSAGE_SIZE) { // message ready to be collected
    update_pin = true;
    
    for(int i = 0; i < MESSAGE_SIZE; i++)
      msg[i] = client.read();
      
  } else if (client.available() > MESSAGE_SIZE) {
    client.flush(); // clean garbage
  }
  
  if (Serial.available() == MESSAGE_SIZE) { // message ready to be collected
    update_pin = true;
    
    for(int i = 0; i < MESSAGE_SIZE; i++)
      msg[i] = Serial.read();
      
  } else if (Serial.available() > MESSAGE_SIZE) {
    Serial.flush(); // clean garbage
  }
  
  if (update_pin) {
    int value = atoi(msg);
    int led_pin = value / 1000; // pin is first character in msg
    value %= 1000; // value is last 3 characters in msg
    
    // log status message
    Serial.print("LED: ");
    Serial.println(led_pin);
    Serial.print("Value: ");
    Serial.println(value);
    Serial.println();
    
    switch( led_pin ) { // update appropriate output
      case 1:
        analogWrite(LED1_PIN, value);
        break;
      case 2:
        analogWrite(LED2_PIN, value);
        break;
    }
  }
}
