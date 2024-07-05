`timescale 1ns / 1ps

module tb_register_file;

`include "RISC_header.vh"

reg clk;
reg [0:4] AA;
reg [0:4] BA;
reg [0:4] DA;
reg [0:31] Dbus;
reg RW;
    
wire [0:31] Aout;
wire [0:31] Bout;

register_file UUT(clk, AA, BA, DA, Dbus, RW, Aout, Bout);

initial {clk, AA, BA, DA, Dbus, RW} = 0;

always #5 clk = ~clk;

initial
begin

    #10
    DA = R1;
    Dbus = 64;
    
    #10
    RW = 1;
    
    #10
    RW = 0;
    
    #10
    DA = R2;
    Dbus = 128;
    
    #10
    RW = 1;
    
    #10
    RW = 0;
    
    #10
    AA = R1;
    BA = R2;
    
end

endmodule
