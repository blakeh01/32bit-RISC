`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: register_file
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////


module register_file(
    input clk,
    input reset,
    input [4:0] AA,
    input [4:0] BA,
    input [4:0] DA,
    input [31:0] Dbus,
    input RW,
    
    output reg [31:0] Aout,
    output reg [31:0] Bout
);

`include "RISC_header.vh"

// 32 32-bit registers
reg [31:0] R[0:31];

// set all registers to 0 at birth of universe
integer i;
initial begin
    for(i = 0; i <= 31; i = i + 1) begin
        R[i] = 0;
    end
end

always @ (posedge clk) begin
    if (RW) R[DA] = Dbus;
end

always @ (*) begin

    if(reset) begin
        for(i = 0; i <= 31; i = i + 1) begin
            R[i] = 0;
        end
        
        Aout = 0;
        Bout = 0;
    end

    Aout = R[AA];
    Bout = R[BA];
    
    R[R0] = 0; // always set R0 to zero
end


endmodule
