#include <stdlib.h>
#include <string.h>
#include <Nixie.h>

// message types
#define NO_MESSAGE_ID '0'
#define DEMO_ID '1'
#define MESSAGE_ID '3'
#define ZERO_MESSAGE_ID '4'
#define CLEAR_ID '2'

#define MESSAGE_SIZE 2
#define DEMO_DELAY 175

#define numDigits 2

#define dataPin 2  // data line or SER
#define clockPin 3 // clock pin or SCK
#define latchPin 4 // latch pin or RCK

Nixie nixie(dataPin, clockPin, latchPin);
char message_type = DEMO_ID;

int demo_count = 0;
int demo_direction = 1;
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
    case DEMO_ID: // keep the demo running, no NOOP
      run_demo();
      break;
    case ZERO_MESSAGE_ID: // recieve a message and then NOOP
    case MESSAGE_ID: 
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

    if (demo_direction < 0) { // right justified
      nixie.writeNumTrim(demo_count, numDigits);
    } else { // left justified with no shift
      nixie.clear(numDigits);
      nixie.writeNumLeft(demo_count);
    }
    
    // reverse the direction if we've left the bounds (0-9)
    demo_count += demo_direction;
    if ((demo_count >= 9) || (demo_count < 0))
      demo_direction *= -1;
  }
}

void recieve_message() {    
  char msg[MESSAGE_SIZE];
  
  // sleep until the buffer is full
  while (Serial.available() < MESSAGE_SIZE)
    delay(10);
    
  // collect the message
  for(int i = 0; i < MESSAGE_SIZE; i++)
    msg[i] = Serial.read();
      
  // convert and update the tubes
  int val = atoi(msg);
  switch (message_type) {
    case ZERO_MESSAGE_ID: // right justified with 0 padding
      nixie.writeNumZero(val, MESSAGE_SIZE);
      break;
    case MESSAGE_ID: // right justified with blank padding
      nixie.writeNumTrim(val, MESSAGE_SIZE);
      break;
    default: // left justified (continue to shift)
      nixie.writeNumLeft(val);
      break;
  }
}
