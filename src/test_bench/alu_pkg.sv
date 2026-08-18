package alu_pkg;

import uvm_pkg::*;
// package file itself
  parameter int DW = 8;
  parameter int CW = 4;
`include "uvm_macros.svh"

`include "seq_item.sv"
`include "alu_cfg.sv"

`include "sequencer.sv"
`include "sequence.sv"

`include "driver.sv"
`include "input_monitor.sv"
`include "output_monitor.sv"

`include "input_agent.sv"
`include "output_agent.sv"

`include "scoreboard.sv"
`include "env.sv"

`include "test.sv"

endpackage
