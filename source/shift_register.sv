

`include "includes.svh"
/* shift register consisting of `DATA_LEN register_cells with data in and data out port */
module shift_register
(
        input logic data_in,
        input logic clk,
        input logic update,
        input logic reset,
        input logic enable,
        output logic data_out,
        output logic [`DATA_LEN - 1 : 0]bit_out
);

logic cells_out[`DATA_LEN - 1 : 0];

assign data_out = cells_out[0];

generate
    genvar i;
    for (i = `DATA_LEN - 1; i >= 0; i--) begin : chain_generate
        /* beginning of the chain */
        if (i == `DATA_LEN - 1) begin : chain_begin
            register_cell cell_reg(
                .chain_in(data_in),
                .update(update),
                .clk(clk),
					 .enable(enable),
                .reset(reset),
                .chain_out(cells_out[i]),
                .bit_out(bit_out[i])
            );
        end
        /* middle and end cells */
        else begin : chain_middle_and_end
            register_cell cell_reg(
                .chain_in(cells_out[i+1]),
                .update(update),
                .clk(clk),
					 .enable(enable),
                .reset(reset),
                .chain_out(cells_out[i]),
                .bit_out(bit_out[i])
            );
            end    
        end
endgenerate
endmodule