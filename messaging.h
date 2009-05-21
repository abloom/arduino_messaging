#ifndef MESSAGING_H
#define MESSAGING_H

#define SERIAL_MAX_MSG_LEN        32

#define SERIAL_READ_START_CHAR    '['
#define SERIAL_READ_END_CHAR      ']'
#define SERIAL_READ_ERR_CHAR      0xff

#define DEMO_DELAY                175
#define DEMO_DELAY_2              20

#define NIXIE_NUM_DIGITS          2

#define NIXIE_PIN_DATA            2     /* data line or SER */
#define NIXIE_PIN_CLK             3     /* clock pin or SCK */
#define NIXIE_PIN_LATCH           4     /* latch pin or RCK */

#define GRAPH_PIN_DATA            5     /* data line or SER */
#define GRAPH_PIN_CLK             6     /* clock pin or SCK */
#define GRAPH_PIN_LATCH           7     /* latch pin or RCK */

enum {
  MSG_TYPE_DEMO,
  MSG_TYPE_DISPLAY,
  MSG_TYPE_CLEAR_DISPLAY,
  MSG_TYPE_GRAPH,
  MSG_TYPE_CLEAR_GRAPH,
};

enum {
  SERIAL_READ_NONE,
  SERIAL_READ_OK,
  SERIAL_READ_ERR_FORMAT,
  SERIAL_READ_ERR_EMPTY
};

#endif