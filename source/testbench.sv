// Code your testbench here
// or browse Examples

`include "includes.svh"
// `define DEBUG_LEVEL
`define UPPER_LIMIT 255
  

module testbench;

  timeunit 1ns/1ps;
  initial
    /* shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string */
    $timeformat(-9, 2, " ns", 20);

  logic clk;
  always #5 clk <= ~clk;

  wire data_inout_dut;
  logic [0 : `DATA_LEN - 1]bit_out_dut;
  logic bidir_write_to_dut;
  logic data_in_dut;
  logic data_out_dut;
  logic [`DATA_LEN - 1 : 0]bit_out_temp;

  int points = 0;

  logic [0 : `DATA_LEN - 1]test_data;
  logic [0 : `DATA_LEN - 1]test_data_out;

  assign data_out_dut = data_inout_dut;
  assign data_inout_dut = (bidir_write_to_dut == 1'b1) ? data_in_dut : 1'bZ;

  /* switch write to daisychain controller */
  task switch_to_write();
    bidir_write_to_dut = 1'b1;    
  endtask

  /* switch to read from daisychain controller */
  task switch_to_read();
    bidir_write_to_dut = 1'b0; 
  endtask

  task wait_n_clk_cycles(int n_cycles);
    for (int i = 0; i < n_cycles; i++) begin
      @(posedge clk);
      @(negedge clk);
    end
    `ifdef DEBUG_LEVEL
    $display("time is %0t after waiting", $time);
    `endif
  endtask

  task send_startbit();
    @(negedge clk);
    data_in_dut <= 1;
  endtask

  /* sends a command to the DUT */
  task automatic send_command(ctrl_cmd_t cmd);
    for(int i = `CMD_LEN - 1; i >= 0; i--) begin
      @(negedge clk);
      data_in_dut <= cmd[i];
      `ifdef DEBUG_LEVEL
      $display("wrote command bit %b at %0t", cmd[i], $time);
      `endif 
    end
    @(negedge clk);
    data_in_dut <= 0;

    `ifdef DEBUG_LEVEL
    $display("time is %0t after command", $time);
    `endif 
  endtask

  /* sends data to the daisychain controller */
  task automatic send_data(logic [`DATA_LEN - 1 : 0]data);
    for(int i = `DATA_LEN - 1; i >= 0; i--) begin
      @(negedge clk);
      data_in_dut <= data[i];

      `ifdef DEBUG_LEVEL
      assert (ser_ctrl_dut.curr_state == RCV_DATA_ST) else $error("fehler rcv state at %0t", $time);
      $display("wrote data bit %b at %0t", data[i], $time);
      `endif
    end
     @(negedge clk);
     data_in_dut <= 0; 
     `ifdef DEBUG_LEVEL
     $display("time is %0t after data", $time);
     `endif
  endtask

  /* receives data from the daisychain controller */
  task automatic receive_data(ref logic [`DATA_LEN - 1 : 0]data);
    wait_n_clk_cycles(1);
    for(int i = `DATA_LEN - 1; i >= 0; i--) begin
      @(negedge clk);
      data[i] = data_inout_dut; 
      `ifdef DEBUG_LEVEL
      assert (ser_ctrl_dut.curr_state == SND_DATA_ST) else $error("fehler snd state at %0t", $time);
      $display("got data bit %b at %0t", data[i], $time);
      `endif

    end
    @(negedge clk);
    `ifdef DEBUG_LEVEL
    $display("time is %0t after data", $time);
    `endif
  endtask

  /* reverses a vector */
  task automatic reverse_vector(ref logic [`DATA_LEN - 1 : 0]data);
    logic [`DATA_LEN - 1 : 0]data_out;
    for (int i = 0; i < `DATA_LEN; i++) begin
        data_out[i] = data[`DATA_LEN - 1 - i];
    end
    data = data_out;
  endtask


  /* initialize DUT */
  serial_ctrl ser_ctrl_dut(
    .clk(clk),
    .data_inout(data_inout_dut),
    .bit_out(bit_out_dut)
  );

  /* loop to try all possible values that can be stored in the daisychain */
  initial begin
    clk <= 0;
    #20;

    `ifdef DEBUG_LEVEL
    $monitor("data_in_dut = %b", data_in_dut);
    $monitor("ser_ctrl_cmd_reg = %b", ser_ctrl_dut.cmd_reg);
    `endif

    switch_to_write();
    send_startbit();
    send_command(RESET_CMD);
    wait_n_clk_cycles(3);

    `ifdef DEBUG_LEVEL
    assert (ser_ctrl_dut.curr_state == RESET_ST) else $error("fehler reset at %0t", $time);
    `endif

    wait_n_clk_cycles(1);
    for (int j = 0; j <= `UPPER_LIMIT; j++) begin
      test_data = j;

      send_startbit();
      send_command(START_RCV_CMD);
      wait_n_clk_cycles(1);

      

      send_data(test_data);
      wait_n_clk_cycles(3);

      send_startbit();
      send_command(UPDATE_CMD);
      wait_n_clk_cycles(3);

      `ifdef DEBUG_LEVEL
      assert (ser_ctrl_dut.curr_state == UPDATE_ST) else $error("fehler update at %0t", $time);
      `endif

      wait_n_clk_cycles(1);
      bit_out_temp = bit_out_dut;
      reverse_vector(bit_out_temp);
      assert (bit_out_temp == test_data) else $error("bit out %b bei %b", bit_out_dut, test_data);

      send_startbit();
      send_command(START_SND_CMD);
      wait_n_clk_cycles(2);

      switch_to_read();

      receive_data(test_data_out);
      switch_to_write();

      assert (test_data == test_data_out) $display("OK %b", test_data);
            else $error("datenlesefehler! erwartet: %b bekommen: %b", test_data, test_data_out);

      wait_n_clk_cycles(2);
    end
end
endmodule





