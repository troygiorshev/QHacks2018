// -------------------- PINS / HARDWARE --------------------

/*
  Important defines:
   These defines control what pins are used for I/O.
   This can be a bit complicated to understand,
    so the default configuration is as follows:

  Arduino:
   https://www.arduino.cc/en/Hacking/Atmega168Hardware
   default pin config is:
   SNES data  to Arduino pin 4
   SNES clock to Arduino pin 3
   SNES latch to Arduino pin 2
*/

// status LED on pin 13
#define led_reg B
#define led_bit 5

// SNES data on pin 4
#define data_reg D
#define data_bit 4

// SNES clock on pin 3
#define clk_reg D
#define clk_bit 3

// SNES latch on pin 2
#define latch_reg D
#define latch_bit 2

// These defines have to be adjusted according to the data sheet
//   if you change the latch pin. Must be falling edge.
// http://www.atmel.com/images/Atmel-8271-8-bit-AVR-Microcontroller-ATmega48A-48PA-88A-88PA-168A-168PA-328-328P_datasheet_Complete.pdf
#define latch_EICRA_val 0x02
#define latch_EIMSK_val _BV(INT0)
#define latch_ISR_vect  INT0_vect

// -------------------- CONSTANTS / MACROS --------------------

#define DATA_PACKET_SIZE_BYTES  12

// Useful defines
#ifndef _BV
#define _BV(n) (1<<(n))
#endif

#define EXPAND(...) __VA_ARGS__
#define CAT(a, ...) PRIMITIVE_CAT(a, __VA_ARGS__)
#define PRIMITIVE_CAT(a, ...) a ## __VA_ARGS__

#define PBV(r,b) _BV(CAT(P,CAT(EXPAND(r),EXPAND(b))))
#define PORT(r)  CAT(PORT,EXPAND(r))
#define PIN(r)   CAT(PIN,EXPAND(r))
#define DDR(r)   CAT(DDR,EXPAND(r))

#define data_low   (PORT(data_reg) &= ~PBV(data_reg,data_bit))
#define data_high  (PORT(data_reg) |=  PBV(data_reg,data_bit))

#define led_toggle (PORT(led_reg) ^=  PBV(led_reg,led_bit))
#define led_high   (PORT(led_reg) |=  PBV(led_reg,led_bit))
#define led_low    (PORT(led_reg) &= ~PBV(led_reg,led_bit))

#define clk   (PIN(clk_reg) & PBV(clk_reg,clk_bit))
#define latch (PIN(latch_reg) & PBV(latch_reg,latch_bit))

// -------------------- DATA --------------------

// Set to true when data is recieved, set to false when SNES requests data it and it is sent
boolean newDataAvailable = false;
uint8_t dataPacketBuffer[DATA_PACKET_SIZE_BYTES];

/*
  Controller data:
  0000 0000 0000 110b dddd dddd ………….
  b = 1 for new data, 0 for old data
*/

// -------------------- SERIAL --------------------

#define SERIAL_BAUD_RATE 115200
#define SERIAL_TIMEOUT 10

// If this is commented, the recieved data is echoed back to the serial port
#define ECHO_SERIAL_DATA

// -------------------- SETUP --------------------

void setup() {

  // -------------------- INIT SERIAL --------------------

  Serial.begin(SERIAL_BAUD_RATE);
  Serial.setTimeout(SERIAL_TIMEOUT);

  // -------------------- INIT PINS --------------------

  // configure pins
  // hopefully this will be optimised into a few instructions
  DDR(data_reg)  |=  PBV(data_reg, data_bit);  // data out
  DDR(led_reg)   |=  PBV(led_reg, led_bit);    // led out
  DDR(clk_reg)   &= ~PBV(clk_reg, clk_bit);    // clk in
  DDR(latch_reg) &= ~PBV(latch_reg, latch_bit); // latch in

  led_low;

  // -------------------- INIT DATA BUFFERS --------------------

  for (int8_t i = 0; i < DATA_PACKET_SIZE_BYTES; i++) {
    dataPacketBuffer[i] = 0;
  }

  // Wait an extra second for the PC's operating system to load drivers
  // and do whatever it does to actually be ready for input
  // I don't think we have to wait for 1 second (maybe on windows?)
  _delay_ms(1000);

  // -------------------- ATTACH INTERRUPT --------------------

  cli();
  EIFR  = 0xff;            // clear interrupt flags (for good luck)
  EICRA = latch_EICRA_val; // interrupt on falling edge of INT0
  EIMSK = latch_EIMSK_val; // enable only INT0 (D0 on ATmega32u4)
  sei();

}

// -------------------- LOOP --------------------

void loop() {

  int8_t dataIn = Serial.readBytes(dataPacketBuffer, DATA_PACKET_SIZE_BYTES);
  
  if (dataIn > 0) {
    newDataAvailable = true;
  
#ifdef ECHO_SERIAL_DATA
    Serial.print("[");
    for (byte i = 0; i < DATA_PACKET_SIZE_BYTES; i++) {
      Serial.write(dataPacketBuffer[i]);
    }
    Serial.println("]");
#endif

    led_high;
    
  } else {
    led_low;
  }

}
