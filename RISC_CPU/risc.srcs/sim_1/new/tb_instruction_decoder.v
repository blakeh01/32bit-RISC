`timescale 1ns / 1ps

module tb_instruction_decoder;
    
`include "RISC_header.vh"

reg [31:0] PC = 0;

wire RW;
wire [0:14] IM;
wire [0:4] DA;
wire [0:1] MD;
wire [0:1] BS;
wire PS;
wire MW;
wire [0:4] FS;
wire [0:4] SH;
wire MA;
wire MB;
wire [0:4] AA;
wire [0:4] BA;
wire CS;

wire [31:0] inst_out;

instruction_decoder UUT(inst_out, RW, IM, DA, MD, BS, PS, MW, FS, SH, MA, MB, AA, BA, CS);
instruction_memory mem(PC, inst_out);

always #10 PC = PC + 1;

endmodule
