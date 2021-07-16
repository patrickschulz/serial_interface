SRC+=dflipflop.sv 
SRC+=register_cell.sv 
SRC+=shift_register.sv 
SRC+=serial_ctrl.sv 
SRC_TB+=testbench.sv

#compiler=vlog
compiler=iverilog

#simulator=vsim
simulator=iverilog

sim_all:	
	$(compiler) -sv -timescale 1ns/1ps $(SRC)
	$(compiler) -sv -timescale 1ns/1ps $(SRC_TB) 
	$(simulator)  -voptargs="+acc -fsmdebug" testbench 

sim_shift_reg: 
	$(compiler) -sv -timescale 1ns/1ps dff.sv register_cell.sv shift_register.sv
	$(compiler) -sv -timescale 1ns/1ps testbench_shift_reg.sv
	$(simulator) -voptargs="+acc" testbench_shift_reg

