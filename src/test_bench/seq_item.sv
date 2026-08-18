class seq_item extends uvm_sequence_item;
    rand bit [7:0] OA, OB;
    rand bit       ce, mode, cin;
    rand bit [1:0] inp_valid;
    rand bit [3:0] cmd;

    bit [4:0]      wait_cycle;
    logic [15:0]   res;
    logic          g, e, l, cout, oflow, err;

    // constraints for ce and inp_valids
    constraint c0 { ce dist {1 := 90, 0 := 10}; }
    constraint c1 { inp_valid dist {0 := 10, 1 := 20, 2 := 20, 3 := 50}; }

    // constraint mode and cin distribution
    constraint c2 { cin dist {1 := 90, 0 := 10}; }
    constraint c3 { mode dist {1 := 90, 0 := 10}; }

    // constraint cmd
    constraint c4 {
        if (mode)
            cmd inside {[4'b0000 : 4'b1010]};
        else
            cmd inside {[4'b0000 : 4'b1101]};
    }

    `uvm_object_utils_begin(seq_item)
        // input register
        `uvm_field_int(OA, UVM_ALL_ON)
        `uvm_field_int(OB, UVM_ALL_ON)
        `uvm_field_int(ce, UVM_ALL_ON)
        `uvm_field_int(mode, UVM_ALL_ON)
        `uvm_field_int(cin, UVM_ALL_ON)
        `uvm_field_int(inp_valid, UVM_ALL_ON)
        `uvm_field_int(cmd, UVM_ALL_ON)
        `uvm_field_int(wait_cycle, UVM_ALL_ON)
        // output register
        `uvm_field_int(res, UVM_ALL_ON)
        `uvm_field_int(g, UVM_ALL_ON)
        `uvm_field_int(e, UVM_ALL_ON)
        `uvm_field_int(l, UVM_ALL_ON)
        `uvm_field_int(cout, UVM_ALL_ON)
        `uvm_field_int(oflow, UVM_ALL_ON)
        `uvm_field_int(err, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction
endclass
