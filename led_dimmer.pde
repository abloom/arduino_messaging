#include <stdlib.h>
#include <string.h>
#include <Nixie.h>

// message flags
#define NO_MESSAGE_ID '0'
#define DEMO_ID '1'
#define MESSAGE_ID '3'
#define CLEAR_ID '2'

#define MESSAGE_SIZE 2
#define DEMO_DELAY 250

#define numDigits 2

#define dataPin 2  // data line or SER
#define clockPin 3 // clock pin or SCK
#define latchPin 4 // latch pin or RCK

Nixie nixie(dataPin, clockPin, latchPin);
char message_type = NO_MESSAGE_ID;

byte demo_count = 0;
byte demo_direction = 1;
unsigned long demo_timer = 0;

void setup() {
  nixie.clear(numDigits);
  
  Serial.begin(9600);
  Serial.println("ready");
}

void loop() {  
  if (Serial.available() > 0) {
    // new message
    message_type = Serial.read();
    
    Serial.print("cmd: ");
    Serial.println(message_type);
  }
  
  // process message
  switch(message_type) {
    case NO_MESSAGE_ID: // NOOP
      break;
    case DEMO_ID: // keep the demo running
      run_demo();
      break;
    case MESSAGE_ID: // recieve a message and then NOOP
      recieve_message();
      message_type = NO_MESSAGE_ID;
      break;
    case CLEAR_ID: // clear the tubes and then NOOP
      nixie.clear(numDigits);
      message_type = NO_MESSAGE_ID;
      break;
    default: // report the error and then NOOP
      Serial.print("unknown message_type: ");
      Serial.println(message_type);
      message_type = NO_MESSAGE_ID;
      break;
  }
}

void run_demo() {
  unsigned long timer = millis();
  
  // only swap digits if weve waited 250ms
  if (timer >= (demo_timer + DEMO_DELAY)) {
    demo_timer = timer;

    nixie.writeNumLeft(demo_count);   // update the tubes
    demo_count += demo_direction;     // increment the counter
    
    // reverse the direction if we've hit 0 or 9
    if ((demo_count >= 9) || (demo_count <= 0))
      demo_direction *= -1;
  }
}

void recieve_message() {    
  char msg[MESSAGE_SIZE];
  
  for(int i = 0; i < MESSAGE_SIZE; i++)
    msg[i] = Serial.read();

  int value = atoi(msg);
  
  Serial.print("Value: ");
  Serial.println(value);

  nixie.writeNumLeft(value);
  if (value == 0)
    nixie.writeNumLeft(0);
}
