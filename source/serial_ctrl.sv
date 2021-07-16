`include "includes.svh"

module serial_ctrl
#(
  parameter BIT_COUNT_LEN = $clog2(`DATA_LEN + 1) /* to scale the bit count variable size to the data length*/
)
(
  inout logic data_inout,
  input logic clk,
  output logic [`DATA_LEN - 1 : 0]bit_out
/*
  output wire [2 : 0]curr_state_debug,
  output wire [2 : 0]next_state_debug,
  
  output wire bidir_write_debug
*/
);

  logic bidir_write; /* flag 0: reading from data_inout, 1: writing to data_inout */
  logic cmd_rcv_done;
  logic send_done;
  logic rcv_done;
  logic got_start_bit;

  logic data_inout_reg;
  assign data_inout = (bidir_write) ? data_inout_reg : 1'bZ;

  ctrl_state_t curr_state;
  ctrl_state_t next_state;
  
  bit unsigned [BIT_COUNT_LEN:0]bit_count;
  
  logic [`CMD_LEN - 1 : 0]cmd_reg; /* register for saving incoming command */

  logic update_shift_reg;
  logic reset_shift_reg;
  logic en_shift_reg;
  logic data_in_shift_reg;
  logic data_out_shift_reg;
  
  /* debug ports */
  
	assign next_state_debug = next_state;
	assign curr_state_debug = curr_state;
	assign bidir_write_debug = en_shift_reg;
	
  /* end of debug ports */
 
  /* shift register to save the incoming data */
  shift_register daisychain (
    .clk(clk),
    .data_in(data_in_shift_reg),
    .update(update_shift_reg),
    .reset(reset_shift_reg),
    .enable(en_shift_reg),
    .data_out(data_out_shift_reg),
    .bit_out(bit_out)
  );

  /* combinational state machine to select next state */
  always_comb begin : next_state_logic
    next_state = ctrl_state_t'('X); /* to spot errors during simulation */
    case (curr_state)
      IDLE_ST : begin
        next_state = (got_start_bit == 1) ? RCV_CMD_ST : IDLE_ST; /* start bit arrived ? */
      end
      RCV_CMD_ST : begin /* get command after start bit */
        if (cmd_rcv_done) begin
          next_state = ACK_CMD_ST;
        end
        else begin
          next_state = RCV_CMD_ST;
        end
      end
      ACK_CMD_ST : begin
		if(cmd_rcv_done) begin
        case (cmd_reg)
          START_SND_CMD: begin
            next_state = SND_DATA_ST;
          end
          START_RCV_CMD: begin
            next_state = RCV_DATA_ST;
          end
          RESET_CMD: begin
            next_state = RESET_ST;
          end
          UPDATE_CMD: begin
            next_state = UPDATE_ST;
          end
        endcase
		  end
      end
      SND_DATA_ST: begin
        if (send_done) begin
          next_state = IDLE_ST;
        end 
        else begin
          next_state = SND_DATA_ST;
        end
      end
      RCV_DATA_ST: begin
        if (rcv_done) begin
          next_state = IDLE_ST;
        end
        else begin
          next_state = RCV_DATA_ST;
        end
      end
      UPDATE_ST: begin
        next_state = IDLE_ST;
      end
      default : begin 
         next_state = IDLE_ST;
      end
    endcase
  end

  /* state machine to select the outputs and registers for the next state*/
  always_ff @ (posedge clk) begin
    en_shift_reg <= 0;
    data_in_shift_reg <= 0;
    update_shift_reg <= 0;
    reset_shift_reg <= 1;
    bidir_write <= 0;
    rcv_done <= 0;
    send_done <= 0;
    got_start_bit <= 0;
    case (next_state)
      RESET_ST: begin
        en_shift_reg <= 1;
        reset_shift_reg <= 0; 
      end
      UPDATE_ST: begin
        update_shift_reg <= 1;
      end
      RCV_CMD_ST: begin
        if (bit_count < `CMD_LEN) begin
          bit_count <= bit_count + 1;
          cmd_reg <= (cmd_reg << 1) | data_inout; /* save incoming bit into command register */
          cmd_rcv_done <= 0;
        end 
        else begin
          cmd_rcv_done <= 1;
          bit_count <= 0;
        end
      end
      ACK_CMD_ST: begin
        /* todo send ! */
      end
      RCV_DATA_ST: begin
        if (bit_count < `DATA_LEN) begin
          en_shift_reg <= 1;
          data_in_shift_reg <= data_inout;
          bit_count <= bit_count+1;
        end
        else begin
          rcv_done <= 1;
          bit_count <= 0;  
        end
      end
      SND_DATA_ST: begin
        if (bit_count <= `DATA_LEN + 1) begin
          bidir_write <= 1;
          en_shift_reg <= 1;
          data_inout_reg <= data_out_shift_reg;
          bit_count <= bit_count+1;
        end
        else begin
          send_done <= 1;
          bit_count <= 0;
        end
      end
      default : begin
        /* recognition of startbit */
        if(data_inout == 1) begin
          got_start_bit <= 1;
        end
      end
    endcase
  end
    
  /* switch to next state with each clock */
  always_ff @ (posedge clk) begin
    curr_state <= next_state;
  end
endmodule
