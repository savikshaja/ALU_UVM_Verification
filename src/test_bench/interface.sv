`include "uvm_macros.svh"
import uvm_pkg::*;

interface alu_inf #(parameter DW=8, parameter CW=4) (input bit clk, reset);

	logic [DW-1:0] OA, OB;
	logic ce, mode, cin;
	logic [1:0] inp_valid;
	logic [CW-1:0] cmd;

	logic [DW*2-1:0] res;
	logic cout, oflow, g, e, l, err;

	clocking drv_clk @(posedge clk);
		default input #0 output #1;
		output OA, OB, ce, cin, mode, cmd, inp_valid;
	endclocking

	clocking ip_mon_clk @(posedge clk);
		default input #1step output #0;
		input OA, OB, ce, cin, mode, cmd, inp_valid;
	endclocking

	clocking op_mon_clk @(posedge clk);
		default input #1step output #0;
		input OA, OB, ce, cin, mode, cmd, inp_valid, res, cout, oflow, g, e, l, err;
	endclocking

	modport drv_mod(clocking drv_clk);
	modport ipm_mod(clocking ip_mon_clk);
	modport opm_mod(clocking op_mon_clk);

	property p_reset_defaults;
		@(posedge clk)
		reset |-> (res==0 && cout==0 && oflow==0 && g==0 && e==0 && l==0 && err==0);
	endproperty
	a_reset_defaults: assert property(p_reset_defaults)
		else `uvm_error("ASSERT","Outputs not default during reset")

	property p_ce_gates_capture;
		@(posedge clk) disable iff(reset)
		!ce |=> $stable(res);
	endproperty
	a_ce_gates_capture: assert property(p_ce_gates_capture)
		else `uvm_error("ASSERT","res changed while ce was low")

	property p_idle_no_execute;
		@(posedge clk) disable iff(reset)
		(ce && inp_valid==2'b00) |=> $stable(res);
	endproperty
	a_idle_no_execute: assert property(p_idle_no_execute)
		else `uvm_error("ASSERT","res changed after idle inp_valid")

	property p_cmp_onehot;
		@(posedge clk) disable iff(reset)
		(mode && cmd==4'b1000 && inp_valid==2'b11) |=> $onehot({g,e,l});
	endproperty
	a_cmp_onehot: assert property(p_cmp_onehot)
		else `uvm_error("ASSERT","CMP did not produce a onehot g/e/l")

	property p_logic_no_arith_flags;
		@(posedge clk) disable iff(reset)
		!mode |=> (cout==0 && oflow==0);
	endproperty
	a_logic_no_arith_flags: assert property(p_logic_no_arith_flags)
		else `uvm_error("ASSERT","cout/oflow set during logical mode")

	property p_gel_zero_non_cmp;
		@(posedge clk) disable iff(reset)
		(mode && cmd!=4'b1000) |=> (g==0 && e==0 && l==0);
	endproperty
	a_gel_zero_non_cmp: assert property(p_gel_zero_non_cmp)
		else `uvm_error("ASSERT","g/e/l set on a non-CMP arithmetic op")

	property p_rotate_err;
		@(posedge clk) disable iff(reset)
		(!mode && (cmd==4'b1100 || cmd==4'b1101) && inp_valid==2'b11 && OB[7:4]!=0)
		|=> err;
	endproperty
	a_rotate_err: assert property(p_rotate_err)
		else `uvm_error("ASSERT","err not set for invalid rotate amount")

	property p_err_res_exclusive;
		@(posedge clk) disable iff(reset)
		err |-> (res==0);
	endproperty
	a_err_res_exclusive: assert property(p_err_res_exclusive)
		else `uvm_error("ASSERT","res nonzero while err was high")

	property p_undefined_arith_cmd;
		@(posedge clk) disable iff(reset)
		(mode && cmd>4'b1010 && inp_valid==2'b11) |=> err;
	endproperty
	a_undefined_arith_cmd: assert property(p_undefined_arith_cmd)
		else `uvm_error("ASSERT","err not set for undefined arithmetic cmd")

	property p_rst_clears_err;
		@(posedge clk)
		reset |-> !err;
	endproperty
	a_rst_clears_err: assert property(p_rst_clears_err)
		else `uvm_error("ASSERT","err still high during reset")

endinterface
