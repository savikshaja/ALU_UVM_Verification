class input_driver extends uvm_driver #(seq_item);
    `uvm_component_utils(input_driver)

    virtual alu_inf.drv_mod vif;
    alu_config              m_cfg;

    seq_item req;

    function new(string name = "input_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(alu_config)::get(this, "", "alu_config", m_cfg))
            `uvm_fatal(get_type_name(), "Input_Driver Getting Failed")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = m_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            repeat (req.wait_cycle) @(vif.drv_clk);
            seq_item_port.item_done();
        end
    endtask

    task drive(seq_item data2duv);
        `uvm_info("DRIVER", $sformatf("DRIVE @%0t: OA=%0h OB=%0h cin=%b ce=%0b mode=%0b cmd=%0d inp_valid=%0b",
                  $time, data2duv.OA, data2duv.OB, data2duv.cin, data2duv.ce, data2duv.mode, data2duv.cmd, data2duv.inp_valid), UVM_NONE)
        @(vif.drv_clk);
        vif.drv_clk.ce        <= data2duv.ce;
        vif.drv_clk.inp_valid <= data2duv.inp_valid;
        vif.drv_clk.OA        <= data2duv.OA;
        vif.drv_clk.OB        <= data2duv.OB;
        vif.drv_clk.mode      <= data2duv.mode;
        vif.drv_clk.cmd       <= data2duv.cmd;

        if ((data2duv.mode == 1) && ((data2duv.cmd == 4'b0010) || (data2duv.cmd == 4'b0011)))
            vif.drv_clk.cin <= data2duv.cin;
        else
            vif.drv_clk.cin <= 0;
    endtask
endclass
