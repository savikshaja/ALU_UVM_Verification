class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(seq_item, scoreboard) inp_export;
    uvm_tlm_analysis_fifo #(seq_item)        out_fifo;

    typedef struct {
        seq_item exp;
        int      latency;
    } exp_entry_t;

    exp_entry_t exp_q[$];

    bit [7:0]   opa, opb;
    bit         opa_valid, opb_valid;
    bit         mode_reg;
    bit [3:0]   cmd_reg;
    bit         cin_reg;
    bit         waiting;
    bit [4:0]   wait_count;
    bit         execute;

    seq_item    exp;
    exp_entry_t item;

    int         pass_count;
    int         fail_count;
    int         total_count;

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        inp_export = new("inp_export", this);
        out_fifo   = new("out_fifo", this);
    endfunction

    function bit two_operand_cmd(bit mode, bit [3:0] cmd);
        if (mode)
            case (cmd)
                4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b1000, 4'b1001, 4'b1010: return 1;
                default: return 0;
            endcase
        else
            case (cmd)
                4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b1100, 4'b1101: return 1;
                default: return 0;
            endcase
    endfunction

    function bit is_opa_only_cmd(bit mode, bit [3:0] cmd);
        if (mode)
            case (cmd)
                4'b0100, 4'b0101: return 1;
                default: return 0;
            endcase
        else
            case (cmd)
                4'b0110, 4'b1000, 4'b1001: return 1;
                default: return 0;
            endcase
    endfunction

    function bit is_opb_only_cmd(bit mode, bit [3:0] cmd);
        if (mode)
            case (cmd)
                4'b0110, 4'b0111: return 1;
                default: return 0;
            endcase
        else
            case (cmd)
                4'b0111, 4'b1010, 4'b1011: return 1;
                default: return 0;
            endcase
    endfunction

    function bit is_error_cmd(bit mode, bit [3:0] cmd);
        if (mode) begin
            case (cmd)
                4'b1011,
                4'b1100,
                4'b1101,
                4'b1110,
                4'b1111: return 1;
                default: return 0;
            endcase
        end else begin
            return 0;
        end
    endfunction

    virtual function void write(seq_item t);
        `uvm_info("SB", $sformatf("WRITE RECEIVED: OA=%0h OB=%0h CE=%0b MODE=%0b CMD=%0h INP_VALID=%0b",
                  t.OA, t.OB, t.ce, t.mode, t.cmd, t.inp_valid), UVM_MEDIUM)

        if (!t.ce) return;

        execute = 0;

        if (waiting) begin
            wait_count++;
            if (wait_count >= 16) begin
                exp           = seq_item::type_id::create("exp");
                exp.res       = 0;
                exp.cout      = 0;
                exp.oflow     = 0;
                exp.g         = 0;
                exp.e         = 0;
                exp.l         = 0;
                exp.err       = 1;
                item.exp      = exp;
                item.latency  = 1;
                exp_q.push_front(item);
                waiting       = 0;
                wait_count    = 0;
                opa_valid     = 0;
                opb_valid     = 0;

                `uvm_info("SB", $sformatf("EXPECTED PUSHED: mode=%0d cmd=%0d latency=%0d queue_size=%0d",
                          mode_reg, cmd_reg, item.latency, exp_q.size()), UVM_MEDIUM)
                return;
            end
        end

        if (t.inp_valid == 2'b00) begin
            opa_valid  = 0;
            opb_valid  = 0;
            waiting    = 0;
            wait_count = 0;
            return;
        end

        mode_reg = t.mode;
        cmd_reg  = t.cmd;
        cin_reg  = t.cin;

        if (two_operand_cmd(mode_reg, cmd_reg)) begin
            case (t.inp_valid)
                2'b01: begin
                    if (opa_valid && t.OA === opa) begin
                    end else begin
                        opa       = t.OA;
                        opa_valid = 1;
                        if (opb_valid) execute = 1;
                        else begin
                            waiting    = 1;
                            wait_count = 0;
                        end
                    end
                end
                2'b10: begin
                    if (opb_valid && t.OB === opb) begin
                    end else begin
                        opb       = t.OB;
                        opb_valid = 1;
                        if (opa_valid) execute = 1;
                        else begin
                            waiting    = 1;
                            wait_count = 0;
                        end
                    end
                end
                2'b11: begin
                    opa       = t.OA;
                    opb       = t.OB;
                    opa_valid = 1;
                    opb_valid = 1;
                    execute   = 1;
                    waiting   = 0;
                    wait_count = 0;
                end
            endcase
        end else if (is_opa_only_cmd(mode_reg, cmd_reg)) begin
            if (t.inp_valid == 2'b01 || t.inp_valid == 2'b11) begin
                opa     = t.OA;
                execute = 1;
            end
        end else if (is_opb_only_cmd(mode_reg, cmd_reg)) begin
            if (t.inp_valid == 2'b10 || t.inp_valid == 2'b11) begin
                opb     = t.OB;
                execute = 1;
            end
        end else if (is_error_cmd(mode_reg, cmd_reg)) begin
            if (t.inp_valid == 2'b11) begin
                opa     = t.OA;
                opb     = t.OB;
                execute = 1;
            end
        end

        if (execute) begin
            waiting      = 0;
            wait_count   = 0;
            exp          = seq_item::type_id::create("exp");
            ref_model(mode_reg, cmd_reg, cin_reg, opa, opb, exp);
            item.exp     = exp;
            item.latency = (mode_reg && (cmd_reg == 4'b1001 || cmd_reg == 4'b1010)) ? 4 : 3;
            exp_q.push_front(item);
            opa_valid    = 0;
            opb_valid    = 0;
        end
    endfunction

    function void ref_model(bit mode, bit [3:0] cmd, bit cin, bit [7:0] a, bit [7:0] b, ref seq_item exp);
        exp.res   = 0;
        exp.cout  = 0;
        exp.oflow = 0;
        exp.g     = 0;
        exp.e     = 0;
        exp.l     = 0;
        exp.err   = 0;

        case (mode)
            1'b1: begin
                case (cmd)
                    4'b0000: begin
                        exp.res  = {1'b0, a} + {1'b0, b};
                        exp.cout = exp.res[8];
                    end
                    4'b0001: begin
                        exp.res   = a - b;
                        exp.oflow = (a < b);
                    end
                    4'b0010: begin
                        exp.res  = {1'b0, a} + {1'b0, b} + cin;
                        exp.cout = exp.res[8];
                    end
                    4'b0011: begin
                        exp.res   = a - b - cin;
                        exp.oflow = (a < (b + cin));
                    end
                    4'b0100: exp.res = a + 1;
                    4'b0101: exp.res = a - 1;
                    4'b0110: exp.res = b + 1;
                    4'b0111: exp.res = b - 1;
                    4'b1000: begin
                        if (a > b)      exp.g = 1;
                        else if (a < b) exp.l = 1;
                        else            exp.e = 1;
                    end
                    4'b1001: exp.res = (a + 1) * (b + 1);
                    4'b1010: exp.res = (a << 1) * b;
                    default: exp.err = 1;
                endcase
            end
            1'b0: begin
                case (cmd)
                    4'b0000: exp.res = {8'b0, a & b};
                    4'b0001: exp.res = {8'b0, ~(a & b)};
                    4'b0010: exp.res = {8'b0, a | b};
                    4'b0011: exp.res = {8'b0, ~(a | b)};
                    4 me: exp.res = {8'b0, a ^ b};
                    4'b0100: exp.res = {8'b0, a ^ b};
                    4'b0101: exp.res = {8'b0, ~(a ^ b)};
                    4'b0110: exp.res = {8'b0, ~a};
                    4'b0111: exp.res = {8'b0, ~b};
                    4'b1000: exp.res = {8'b0, a >> 1};
                    4'b1001: exp.res = {8'b0, a << 1};
                    4'b1010: exp.res = {8'b0, b >> 1};
                    4'b1011: exp.res = {8'b0, b << 1};
                    4'b1100: begin
                        //if (b[7:4] != 0) begin exp.err = 1; /*exp.res = 0;*/ end
                        //else
                        exp.res = {8'b0, (a << b[2:0]) | (a >> (8 - b[2:0]))};
                        exp.err = (b[7:4] != 0);
                    end
                    4'b1101: begin
                        //if (b[7:4] != 0) begin exp.err = 1; /*exp.res = 0;*/ end
                        //else
                        exp.res = {8'b0, (a >> b[2:0]) | (a << (8 - b[2:0]))};
                        exp.err = (b[7:4] != 0);
                    end
                    default: exp.err = 1;
                endcase
            end
        endcase
    endfunction

    task compare(seq_item exp, seq_item act);
        total_count++;
        $display("EXPECTED : RES=%0h COUT=%0b OFLOW=%0b G=%0b E=%0b L=%0b ERR=%0b", exp.res, exp.cout, exp.oflow, exp.g, exp.e, exp.l, exp.err);
        $display("ACTUAL   : RES=%0h COUT=%0b OFLOW=%0b G=%0b E=%0b L=%0b ERR=%0b", act.res, act.cout, act.oflow, act.g, act.e, act.l, act.err);

        if (exp.res == act.res && exp.cout == act.cout && exp.oflow == act.oflow &&
            exp.g == act.g && exp.e == act.e && exp.l == act.l && exp.err == act.err) begin
            pass_count++;
            `uvm_info("SB", "MATCH", UVM_LOW)
        end else begin
            fail_count++;
            `uvm_error("SB", $sformatf("Expected RES=%0h Actual RES=%0h", exp.res, act.res))
        end
    endtask

    task run_phase(uvm_phase phase);
        seq_item actual;
        forever begin
            out_fifo.get(actual);
            foreach (exp_q[i]) exp_q[i].latency--;
            if (exp_q.size() != 0 && exp_q[$].latency <= 0) begin
                compare(exp_q.pop_back().exp, actual);
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf("TOTAL=%0d PASS=%0d FAIL=%0d", total_count, pass_count, fail_count), UVM_NONE)
    endfunction
endclass
