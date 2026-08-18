interface alu_inf #(
    parameter DW = 8,
    parameter CW = 4
) (
    input bit clk,
    input bit reset
);
    // inputs alu
    logic [DW-1:0]   OA, OB;
    logic            ce, mode, cin;
    logic [1:0]      inp_valid;
    logic [CW-1:0]   cmd;

    // output alu
    logic [DW*2-1:0] res;
    logic            cout, oflow, g, e, l, err;

    // clocking for driver
    clocking drv_clk @(posedge clk);
        default input #0 output #1;
        output OA, OB, ce, cin, mode, cmd, inp_valid;
    endclocking

    // clocking for input monitor
    clocking ip_mon_clk @(posedge clk);
        default input #1step output #0;
        input OA, OB, ce, cin, mode, cmd, inp_valid;
    endclocking

    // clocking for output monitor
    clocking op_mon_clk @(posedge clk);
        default input #1step output #0;
        input OA, OB, ce, cin, mode, cmd, inp_valid, res, cout, oflow, g, e, l, err;
    endclocking

    // modport
    modport drv_mod(clocking drv_clk);
    modport ipm_mod(clocking ip_mon_clk);
    modport opm_mod(clocking op_mon_clk);
endinterface
