`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: function_unit
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////

module function_unit(
    input [31:0] A,
    input [31:0] B,
    input [4:0] SH,
    input [4:0] FS,
    
    output reg [31:0] F,
    output reg Z, V, N, C
);

`include "RISC_header.vh"

initial {F, Z, V, N, C} = 0;

always @ (*)
begin

    {F, Z, V, N, C} = 0;

    case(FS)
        // A Pass thru
        5'b00000:
        begin
            F = A;
        end
    
        // B pass thru
        5'b00001:
        begin
            F = B;
        end
    
        // ADD
        5'b00010:
        begin
            {C, F} = A + B;
            V = ((~A[31] & ~B[31] & F[31]) | (A[31] & B[31] & ~F[31])); 
        end
        
        // SUB
        5'b00101:
        begin
            {C, F} = A - B;
            V = ((~A[31] & B[31] & F[31]) | (A[31] & ~B[31] & ~F[31]));
        end
        
        // AND
        5'b01000:
        begin
            F = A & B;
        end
        
        // OR
        5'b01010:
        begin
            F = A | B;
        end
        
        // XOR
        5'b01100:
        begin
            F = A ^ B;
        end
        
        // NOT
        5'b01110:
        begin
            F = ~A;
        end
        
        // LSL
        5'b10000:
        begin
            F = A << SH;
        end
        
        // LSR
        5'b10001:
        begin
            F = A >> SH;
        end
        
        // SET BIT 
        5'b10111:
        begin
            F = A | (1 << B);
        end

    endcase
    
    N = F[31];  //set negative flag high if signed bit is high
    Z = F == 0; //set zero flag if output is zero
end
    
endmodule
