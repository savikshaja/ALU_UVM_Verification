class output_monitor extends uvm_monitor;
    `uvm_component_utils(output_monitor)

    uvm_analysis_port #(seq_item) out_mon_port;

    virtual alu_inf.opm_mod vif;
    alu_config              m_cfg;

    seq_item                dut2mon;

    function new(string name = "output_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(alu_config)::get(this, "", "alu_config", m_cfg))
            `uvm_fatal(get_type_name(), "Output_Monitor Getting Failed")
        out_mon_port = new("out_mon_port", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = m_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        //@(vif.op_mon_clk);
        @(vif.op_mon_clk);
        forever
            collect_ip();
    endtask

    virtual task collect_ip();
        dut2mon = seq_item::type_id::create("dut2mon");
        //repeat(2)
        @(vif.op_mon_clk);

        dut2mon.res   = vif.op_mon_clk.res;
        dut2mon.err   = vif.op_mon_clk.err;
        dut2mon.cout  = vif.op_mon_clk.cout;
        dut2mon.oflow = vif.op_mon_clk.oflow;
        dut2mon.g     = vif.op_mon_clk.g;
        dut2mon.l     = vif.op_mon_clk.l;
        dut2mon.e     = vif.op_mon_clk.e;

        `uvm_info("OUTPUT_MONITOR", $sformatf("RESULT @%0t: res=%0h cout=%0b oflow=%0b G=%b E=%b L=%b err=%b",
                  $time, dut2mon.res, dut2mon.cout, dut2mon.oflow, dut2mon.g, dut2mon.e, dut2mon.l, dut2mon.err), UVM_NONE)

        out_mon_port.write(dut2mon);
    endtask

endclass
