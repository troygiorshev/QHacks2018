// -------------------- MAIN LATCH INTERRUPT --------------------

ISR(latch_ISR_vect) {
  // do these have to be static? probably not
  static uint8_t bits, bytes, tmp;

  // this interrupt only triggers on the falling edge of latch
  //   so we don't have to check the latch pin or anything

  bits = 0;
  bytes = 0;

  led_low;

  // Set the "new data" bit if new data was read from PC before the SNES requested new data
  dataPacketBuffer[1] = newDataAvailable ? B00001101 : B00001100;
  //                                               ^           ^ 
  //                                            New data    Old data 
  
  newDataAvailable = false;
  tmp = dataPacketBuffer[0];
  while (bytes < DATA_PACKET_SIZE_BYTES) { // this could be done faster in assembly
    //   but it's not necessary
    // push the bits out
    if (tmp & 0x80)
      data_low;
    else
      data_high;
    tmp <<= 1;
    bits++;
    if (bits == 8) {
      bits = 0;
      bytes++;
      tmp = dataPacketBuffer[bytes];
    }
    if (wait_clock())
      return;
  }

  data_low;
}

// -------------------- WAIT CLOCK --------------------

static inline uint8_t wait_clock(void) {
  static uint8_t c8;
  c8 = 0;
  for (; (clk) && (c8 < 16); c8++) {
    _delay_us(0.5); // we delay by a short amount of time to avoid
    //   missing the edge of the clock cycle
    // the time could be shorter but, no need :)
  }
  if (clk)
    return 1;
  c8 = 0;
  for (; (!clk) && (c8 < 16); c8++) {
    _delay_us(0.5);
  }
  if (!clk)
    return 1;
  return 0;
}
