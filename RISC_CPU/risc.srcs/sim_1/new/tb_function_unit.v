`timescale 1ns / 1ps

module tb_function_unit;

`include "RISC_header.vh"

reg [0:31] A;
reg [0:31] B;
reg [0:4] FS;
reg [0:4] SH;

wire [0:31] F;
wire Z, V, N, C;

function_unit UUT(A, B, SH, FS, F, Z, V, N, C);

initial {A, B, FS, SH} = 0;

initial 
begin
    #10
    A = 32;
    B = 64;
    
    // test ADD
    #10
    FS = 5'b00010;
    
    // test SUB
    #10
    FS = 5'b00101;
    
    // test AND
    #10
    FS = 5'b01000;
    
    // test OR
    #10
    FS = 5'b01010;
    
    // test XOR
    #10
    FS = 5'b01100;
    
    // test NOT
    #10
    FS = 5'b01110;
    
    // test LSL
    #10
    SH = 5'b00001;
    FS = 5'b10000;
    
    #10
    SH = 5'b00100; 
    
    // test LSR
    #10
    SH = 5'b00001;
    FS = 5'b10001;
    
    #10
    SH = 5'b00100; 
  
end

endmodule
