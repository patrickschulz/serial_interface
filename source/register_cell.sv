/* chaincell consisting of 3 flip flops to minimize hold violations and buffer output that gets active when update signal is high */
module register_cell
(
  input logic chain_in, /* chain in from before chaincell or controller */
  input logic update,
  input logic clk,
  input logic reset,
  input logic enable,
  output logic chain_out, /* chain out to next chaincell */
  output logic bit_out    /* bit to PLL */
);

logic ff_in_q;
logic ff_out_clk;
logic ff_buf_en;

assign ff_out_clk = ~clk;

assign ff_buf_en = (!reset) ? clk : update;

dflipflop ff_in (
  .clk(clk),
  .reset_n(reset),
  .d(chain_in),
  .en(enable),
  .q(ff_in_q)
  );

dflipflop ff_buf (
  .clk(clk),
  .reset_n(reset),
  .d(ff_in_q),
  .en(ff_buf_en),
  .q(bit_out)
  );

dflipflop ff_out (
  .clk(ff_out_clk),
  .reset_n(reset),
  .d(ff_in_q),
  .en(enable),
  .q(chain_out)
  );

endmodule