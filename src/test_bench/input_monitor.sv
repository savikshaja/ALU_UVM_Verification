class input_monitor extends uvm_monitor;
    `uvm_component_utils(input_monitor)

    uvm_analysis_port #(seq_item) inp_mon_port;

    virtual alu_inf.ipm_mod vif;
    alu_config              m_cfg;
    seq_item                drv2mon;

    bit                     prev_valid;

    function new(string name = "input_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(alu_config)::get(this, "", "alu_config", m_cfg))
            `uvm_fatal(get_type_name(), "Input_Monitor Getting Failed")
        inp_mon_port = new("inp_mon_port", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = m_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        @(vif.ip_mon_clk);
        forever
            collect_ip();
    endtask

    virtual task collect_ip();
        drv2mon = seq_item::type_id::create("drv2mon");

        @(vif.ip_mon_clk);
        //@(vif.ip_mon_clk);
        drv2mon.ce        = vif.ip_mon_clk.ce;
        drv2mon.inp_valid = vif.ip_mon_clk.inp_valid;
        drv2mon.OA        = vif.ip_mon_clk.OA;
        drv2mon.OB        = vif.ip_mon_clk.OB;
        drv2mon.mode      = vif.ip_mon_clk.mode;
        drv2mon.cmd       = vif.ip_mon_clk.cmd;

        if ((drv2mon.mode == 1) && ((drv2mon.cmd == 4'b0010) || (drv2mon.cmd == 4'b0011)))
            drv2mon.cin = vif.ip_mon_clk.cin;
        else
            drv2mon.cin = 0;

        `uvm_info("INPUT_MONITOR", $sformatf("CAPTURE @%0t: OA=%0h OB=%0h ce=%0b mode=%0b cmd=%0d inp_valid=%0b",
                  $time, drv2mon.OA, drv2mon.OB, drv2mon.ce, drv2mon.mode, drv2mon.cmd, drv2mon.inp_valid), UVM_NONE)

        inp_mon_port.write(drv2mon);
    endtask
endclass
