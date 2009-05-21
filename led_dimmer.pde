#include <stdlib.h>
#include <string.h>
#include <Nixie.h>
#include <MultiDAC.h>
#include "messaging.h"

Nixie nixie(NIXIE_PIN_DATA, NIXIE_PIN_CLK, NIXIE_PIN_LATCH);
MultiDAC barGraph(GRAPH_PIN_DATA, GRAPH_PIN_CLK, GRAPH_PIN_LATCH);

boolean demo_running = true;
int demo_count = 0;
int demo_direction = 1;
unsigned long demo_timer = 0;

int demo_count_2 = 0;
int demo_direction_2 = 1;
unsigned long demo_timer_2 = 0;

void setup() {  
  Serial.begin(9600);
  Serial.println("ready!");
  
  nixie.clear(NIXIE_NUM_DIGITS);
  barGraph.clear(1);
}

void print_err(int err) {
  switch (err) {
    case SERIAL_READ_OK:
      Serial.println("The operation completed successfully");
      break;
      
    case SERIAL_READ_ERR_FORMAT:
      Serial.println("The message was improperly formatted or incomplete");
      break;
      
    case SERIAL_READ_ERR_EMPTY:
      Serial.println("No message was found");
      break;
      
    default:
      Serial.println("Invalid error id");
      break;
  }
}

/* Reads and stores a null-terminated message from the serial port
 *
 * Returns size of message, including null character
 *
 */ 
int serial_read_message(char *msg) {
  char read;
  int read_len = -1, ret = SERIAL_READ_NONE;
  boolean loop = true;
  
  if (Serial.available() >= 4) {
    read = Serial.read();

    while (read_len < SERIAL_MAX_MSG_LEN && loop) {
      switch (read) {
        case SERIAL_READ_START_CHAR:
          read_len = 0;
          break;

        case SERIAL_READ_END_CHAR:
          if (read_len > 0) {
            ret = read_len;
            loop = false;
          } else {
            ret = -SERIAL_READ_ERR_FORMAT;
          }
          break;

        case SERIAL_READ_ERR_CHAR:
          ret = -SERIAL_READ_ERR_EMPTY;
          break;

        default:
          if (read_len < 0) {
            ret = -SERIAL_READ_ERR_FORMAT;
          } else {
            msg[read_len++] = read;          
          }
          break;
      }      
      read = Serial.read();
    }
  }
  
  return ret;
}

/* Using the last known message, fire off whatever action it requested */
void process_message(char *msg) {
  char type_s[3] = {0x00};
  int type;
  
  memcpy(type_s, msg, 2);
  type = atoi(type_s);
  
  demo_running = false;

  switch(type)
  {
    case MSG_TYPE_DEMO:
      Serial.println("demo");
      demo_running = true;
      run_demo();
      break;
      
    case MSG_TYPE_DISPLAY:
      Serial.println("display");
      display_nixie_message(&msg[2]);
      break;
      
    case MSG_TYPE_CLEAR_DISPLAY:
      Serial.println("clear display");
      clear_nixies();
      break;
      
    case MSG_TYPE_GRAPH:
      Serial.println("graph");
      display_bargraph_message(&msg[2]);
      break;
      
    case MSG_TYPE_CLEAR_GRAPH:
      Serial.println("clear graph");
      clear_bargraph(&msg[2]);
      break;
  }
}

void display_nixie_message(char *msg) {
  int output = atoi(msg);
  nixie.writeNumZero(output, NIXIE_NUM_DIGITS);
}

void clear_nixies() {
  nixie.clear(NIXIE_NUM_DIGITS);
}

void display_bargraph_message(char *msg) {
  char graph_s[2] = {0x00}, value_s[4] = {0x00};
  int graph, value;
  
  memcpy(graph_s, msg, 1);
  memcpy(value_s, &msg[1], 3);
  
  graph = atoi(graph_s);
  value = atoi(value_s);
  
  barGraph.writeValue(graph, value);
}

void clear_bargraph(char *msg) {
  int graph = atoi(msg);
  barGraph.writeValue(graph, 0);
}

void loop() {
  char msg[SERIAL_MAX_MSG_LEN] = {0x00};
  int ret;
  
  if (demo_running)
    run_demo();
  
  ret = serial_read_message(msg);
  
  if (ret < 0) {
    print_err(ret);
  } else if (ret > 0) {
    process_message(msg);
  }
}

void run_demo() {
  unsigned long timer = millis();
  
  if (timer >= (demo_timer_2 + DEMO_DELAY_2)) {
    demo_timer_2 = timer;
    barGraph.writeValue(1, demo_count_2);
    
    // reverse the direction if we've hit the bounds
    demo_count_2 += demo_direction_2;
    if ((demo_count_2 >= 170) || (demo_count_2 < 1))
      demo_direction_2 *= -1;
  }
  
  if (timer >= (demo_timer + DEMO_DELAY)) {
    demo_timer = timer;

    if (demo_direction < 0) { // right justified
      nixie.writeNumTrim(demo_count, NIXIE_NUM_DIGITS);
    } else { // left justified with no shift
      nixie.clear(NIXIE_NUM_DIGITS);
      nixie.writeNumLeft(demo_count);
    }
    
    // reverse the direction if we've left the bounds (0-9)
    demo_count += demo_direction;
    if ((demo_count >= 9) || (demo_count < 0))
      demo_direction *= -1;
  }
}
