class subscriber extends uvm_subscriber #(seq_item);
	`uvm_component_utils(subscriber)

	seq_item tr;

	covergroup alu_input_cg;
		ce_cp: coverpoint tr.ce {
			bins disabled = {0};
			bins enabled  = {1};
		}

		mode_cp: coverpoint tr.mode {
			bins logic_mode = {0};
			bins arith_mode = {1};
		}

		inp_valid_cp: coverpoint tr.inp_valid {
			bins invalid    = {2'b00};
			bins opa_only   = {2'b01};
			bins opb_only   = {2'b10};
			bins both_valid = {2'b11};
		}

		cin_cp: coverpoint tr.cin {
			bins zero = {0};
			bins one  = {1};
		}

		cmd_cp: coverpoint tr.cmd {
			bins valid_cmds[]   = {[4'b0000:4'b1101]};
			bins invalid_cmds[] = {4'b1110, 4'b1111};
		}

		OA_cp: coverpoint tr.OA {
			bins zero    = {8'h00};
			bins max     = {8'hFF};
			bins range[] = {[8'h01:8'hFE]};
		}

		OB_cp: coverpoint tr.OB {
			bins zero    = {8'h00};
			bins max     = {8'hFF};
			bins range[] = {[8'h01:8'hFE]};
		}

		mode_x_cmd:       cross mode_cp, cmd_cp;
		mode_x_inp_valid: cross mode_cp, inp_valid_cp;
		ce_x_mode:        cross ce_cp, mode_cp;
	endgroup

	function new(string name="subscriber", uvm_component parent);
		super.new(name, parent);
		alu_input_cg = new();
	endfunction

	virtual function void write(seq_item t);
		tr = t;
		alu_input_cg.sample();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(),
			$sformatf("Overall Input Functional Coverage = %0.2f %%", alu_input_cg.get_inst_coverage()),
			UVM_LOW)
	endfunction
endclass
