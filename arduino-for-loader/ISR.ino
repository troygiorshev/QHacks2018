// -------------------- MAIN LATCH INTERRUPT --------------------

void int_clock(void) {
  if(cur_clk_data)
    data_low;
  else
    data_high;
  if(newDataAvailable && (clk_bytes < DATA_PACKET_SIZE_BYTES)){
    clk_tmp <<= 1;
    clk_bits++;
    if(clk_bits == 8) {
      clk_bits = 0;
      clk_bytes++;
      clk_tmp = dataPacketBuffer[clk_bytes];
    }
    cur_clk_data = clk_tmp & 0x80;
  }
  else
    cur_clk_data = 0;
  clocks++;
}

void int_latch(void) {
  
  clk_bits = 0;
  clk_bytes = 0;
  if(newDataAvailable){
    clk_tmp = dataPacketBuffer[0];
    led_low;
  }
  else {
    clk_tmp = 0;
    led_high;
  }
  cur_clk_data = clk_tmp & 0x80;
  
  clocks = 0;
  int_clock();
  //clk_lo = 0, clk_hi = 0;
  //newDataAvailable=false;
  return;
  /*
  if(newDataAvailable){
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
      bit_count++;
      if (wait_clock()){
        bit_count--;
        break;
      }
    }
  } else {
    tmp = cleanPacketBuffer[0];
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
        tmp = cleanPacketBuffer[bytes];
      }
      bit_count++;
      if (wait_clock()){
        bit_count--;
        break;
      }
    }
  }

  data_low;
  newDataAvailable = false;
  */
}

// -------------------- WAIT CLOCK --------------------

static inline uint8_t wait_clock(void) {
  static uint8_t c8;
  c8 = 0;
  for (; (clk) && (c8 < 250); c8++) {
    _delay_us(0.5); // we delay by a short amount of time to avoid
    //   missing the edge of the clock cycle
    // the time could be shorter but, no need :)
  }
  if (clk)
    return 1;
  c8 = 0;
  for (; (!clk) && (c8 < 250); c8++) {
    _delay_us(0.5);
  }
  if (!clk)
    return 1;
  return 0;
}
