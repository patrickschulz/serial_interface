/* d-Flip-Flop with synchronous low reset */
module dflipflop (
    input  logic clk,
    input  logic d,
	 input	logic en,
    input  logic reset_n,
    output logic q
);

  always @(posedge clk) begin
    if (!reset_n) begin
      q <= 0;
    end
    else begin
	 if (en) begin
      q <= d;
		end
    end
  end
endmodule
