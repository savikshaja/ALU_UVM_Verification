`include "uvm_macros.svh"
`include "alu_pkg.sv"
`include "interface.sv"
`include "alu_rtl.sv"

module top;

import uvm_pkg::*;
import alu_pkg::*;

bit clk;
bit reset;

//Interface
alu_inf #(8,4) DUV_IF(.clk(clk),.reset(reset));

//DUT
ALU_DESIGN #(.DW(8),.CW(4)) DUV (
.INP_VALID(DUV_IF.inp_valid),
.OPA(DUV_IF.OA),
.OPB(DUV_IF.OB),
.CIN(DUV_IF.cin),
.CLK(clk),
.RST(reset),
.CMD(DUV_IF.cmd),
.CE(DUV_IF.ce),
.MODE(DUV_IF.mode),
.COUT(DUV_IF.cout),
.OFLOW(DUV_IF.oflow),
.RES(DUV_IF.res),
.G(DUV_IF.g),
.E(DUV_IF.e),
.L(DUV_IF.l),
.ERR(DUV_IF.err)
);

//Clock generation
initial begin
clk = 0;
forever #5 clk = ~clk;
end

//Reset generation
initial begin
reset = 1;
#10;
reset = 0;
end

//UVM
initial begin
uvm_config_db#(virtual alu_inf)::set(null,"*","alu_if",DUV_IF);

$dumpfile("waves.fsdb");
$dumpvars(0,top);

run_test();
end

endmodule
