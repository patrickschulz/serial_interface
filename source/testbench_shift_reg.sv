`include "includes.svh"
module testbench_shift_reg;
        initial
        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 2, " ns", 20);
        logic clk;
        always #5 clk <= ~clk;

        logic data_in_shift_reg;
        logic update_shift_reg;
        logic reset_shift_reg;
        logic en_shift_reg;
        logic data_out_shift_reg;
        logic [`DATA_LEN - 1 : 0]bit_out_shift_reg;

        shift_register shift_reg_dut(
                .data_in(data_in_shift_reg),
                .clk(clk),
                .update(update_shift_reg),
                .reset(reset_shift_reg),
                .enable(en_shift_reg),
                .data_out(data_out_shift_reg),
                .bit_out(bit_out_shift_reg)
        );

        initial begin
                clk <= 0;
                data_in_shift_reg <= 0;
                reset_shift_reg <= 0;
                update_shift_reg <= 0;
                en_shift_reg <= 0;
                #10
                reset_shift_reg <= 1;
                #20;
                data_in_shift_reg <= 1;
                en_shift_reg <= 1;
                #80;
                update_shift_reg <= 1;
                data_in_shift_reg <= 0;
                #10;
                update_shift_reg <= 0;

        end







endmodule
