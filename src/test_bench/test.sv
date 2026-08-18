class my_test extends uvm_test;
    `uvm_component_utils(my_test)

    env        my_env;
    alu_config m_cfg;

    function new(string name = "my_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_cfg = alu_config::type_id::create("m_cfg");
        if (!uvm_config_db#(virtual alu_inf)::get(this, "", "alu_if", m_cfg.vif))
            `uvm_fatal(get_type_name(), "can't get the interface")
        m_cfg.input_agent_is_active  = UVM_ACTIVE;
        m_cfg.output_agent_is_active = UVM_PASSIVE;
        uvm_config_db#(alu_config)::set(this, "*", "alu_config", m_cfg);
        my_env = env::type_id::create("my_env", this);
    endfunction
endclass

class test_arithmetic extends my_test;
    `uvm_component_utils(test_arithmetic)

    arithmetic_seq seq1;

    function new(string name = "test_arithmetic", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        seq1 = arithmetic_seq::type_id::create("seq1");
        seq1.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_logic extends my_test;
    `uvm_component_utils(test_logic)

    logical_seq log_seq;

    function new(string name = "test_logic", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        log_seq = logical_seq::type_id::create("seq1");
        log_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_mul_seq extends my_test;
    `uvm_component_utils(test_mul_seq)

    mul_seq m_seq;

    function new(string name = "test_mul_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        m_seq = mul_seq::type_id::create("seq1");
        m_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_mul_shift_seq extends my_test;
    `uvm_component_utils(test_mul_shift_seq)

    mul_shift_seq ms_seq;

    function new(string name = "test_mul_shift_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        ms_seq = mul_shift_seq::type_id::create("ms_seq");
        ms_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_rol_seq extends my_test;
    `uvm_component_utils(test_rol_seq)

    rol_seq r_seq;

    function new(string name = "test_rol_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        r_seq = rol_seq::type_id::create("r_seq");
        r_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_ror_seq extends my_test;
    `uvm_component_utils(test_ror_seq)

    ror_seq r_seq;

    function new(string name = "test_ror_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        r_seq = ror_seq::type_id::create("r_seq");
        r_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_err_seq extends my_test;
    `uvm_component_utils(test_err_seq)

    err_seq e_seq;

    function new(string name = "test_err_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        e_seq = err_seq::type_id::create("e_seq");
        e_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_wait_2_seq extends my_test;
    `uvm_component_utils(test_wait_2_seq)

    wait_2_seq w2_seq;

    function new(string name = "test_wait_2_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        w2_seq = wait_2_seq::type_id::create("w2_seq");
        w2_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass

class test_wait_16_seq extends my_test;
    `uvm_component_utils(test_wait_16_seq)

    wait_16_seq w16_seq;

    function new(string name = "test_wait_16_seq", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100ns);
        w16_seq = wait_16_seq::type_id::create("w16_seq");
        w16_seq.start(my_env.inp_agt_h.seqr_h);
        phase.drop_objection(this);
    endtask
endclass
