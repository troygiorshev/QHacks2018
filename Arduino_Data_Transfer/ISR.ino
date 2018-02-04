void int_clock(void) {
  if(cur_clk_data)
    data_low;
  else
    data_high;
  if(clk_bytes < DATA_PACKET_SIZE_BYTES){
    clk_tmp <<= 1;
    clk_bits++;
    if(clk_bits == 8) {
      clk_bits = 0;
      clk_bytes++;
      clk_tmp = clk_buf[clk_bytes];
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
  if(buf_active){
    clk_buf = buf_b;
    led_low;
  }
  else {
    clk_buf = buf_a;
    led_high;
  }
  clk_tmp = clk_buf[0];
  cur_clk_data = clk_tmp & 0x80;
  
  clocks = 0;
  int_clock();
  return;
}

