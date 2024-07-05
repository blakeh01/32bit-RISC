`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: instruction_memory
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////

module instruction_memory(
    input [0:31] address,

    output [0:31] instruction_out
);

`include "RISC_header.vh"

reg [31:0] instruction_mem [0:1023]; // 1024 x 32-bit
reg [31:0] instruction;

integer i;

initial begin
    instruction = 0;
    for(i = 0; i <= 1023; i = i + 1) begin
        instruction_mem[i] = 0;
    end
    
    // DIVISION code
    // R1 => dividend_HIGH
    // R2 => dividend_LOW
    // R3 => divisor
    // R4 => quotient
    // R5 => remainder
    // R6 => DIV BY ZERO FLAG (0 no div/0, 1 div/0)
    // R7 => OVERFLOW FLAG (0 no overflow, 1 overflow)
    // R8 => SIGN FLAG (0 positive, 1 negative)
    // R9 - R12 => temp registers
    
    // algorithm
    /*
        D = 0, set R6, exit.
        MSB[R1] xor MSB[R3] = R8
        
        for i = 31 to 0:
            shift remainder
            set LSB remainder to dividend [HIGH] @ i
            if R >= D
                set remainder to R - D
                set quotient (i) to 1
                
        for i = 31 to 0:
            shift remainder
            set LSB remainder to dividend [LOW] @ i
            if R >= D
                set remainder to R - D
                set quotient (i) to 1
        
        check overflow set R7, exit if so
        if R8, take twos comp.
        
        dividend @ i implemented using a mask register which shifts a 1 from MSB to LSB
        setting quotient @ i implemented using custom instruction 'SBIR' motiviated by AVR SBI.
            - an implementation wiwthout this is possible, but would require 6-ish instructions
    */
    
    // LOAD in dividend/divisor from data memory (eaisly supports 32 bits instead of LDI-ing 15 bits at a time)
    instruction_mem[1] = {LD, R1, R0, 15'b0};   // H byte dividend
    instruction_mem[2] = {LDI, R9, R9, 15'd1};
    instruction_mem[3] = {LD, R2, R9, 15'b0};   // L byte dividend
    instruction_mem[4] = {LDI, R9, R9, 15'd2};
    instruction_mem[5] = {LD, R3, R9, 15'b0};   // Divisor
    
    // Check if divisor is 0
    instruction_mem[6] = {CMP, R6, R3, R0, 10'b0};  //compare r3 == r0 (is divisor 0?)
    instruction_mem[7] = {BNZ, R6, R6, 15'd1020}; //if so, branch to  end of program
        
    // Set sign bit (XOR sign bits)
    instruction_mem[10] = {SLT, R9, R1, R0, 10'd0};  //is H byte less than 0 ? If so, set R9
    instruction_mem[11] = {SLT, R10, R3, R0, 10'd0}; //is divisor less than 0 ? If so, set R10
    instruction_mem[12] = {XOR, R8, R9, R10, 10'd0}; //set sign bit.
    
    // Do sign correction if needed (keep R9 R10 for now)
    
    //dividend sign correction
    instruction_mem[13] = {CMP, R11, R0, R9, 10'b0}; //check r9 == 0
    instruction_mem[14] = {BNZ, R11, R11, 15'd10};   //if zero, this means negative, go check divisor
    instruction_mem[17] = {NOT, R2, R2, 15'd0};
    instruction_mem[18] = {NOT, R1, R1, 15'd0};
    instruction_mem[19] = {ADI, R2, R2, 15'd1};     // poor mans add w/ carry
    instruction_mem[20] = {BNC, R0, R0, 15'd4};      //unused register as using previous C
    instruction_mem[23] = {ADI, R1, R1, 15'd1};
    
    //divisor sign correction
    instruction_mem[24] = {CMP, R11, R0, R10, 10'd0}; //two's comp divisor if its negative 
    instruction_mem[25] = {BNZ, R11, R11, 15'd5};
    instruction_mem[28] = {NOT, R3, R3, 15'd0};
    instruction_mem[29] = {ADI, R3, R3, 15'd1};
        
    // Begin division (HIGH BYTE)
    instruction_mem[30] = {LDI, R9, R9, 15'd31};
    instruction_mem[31] = {LDI, R10, R10, 15'b1}; //create mask
    instruction_mem[32] = {LSL, R10, R10, 10'b0, 5'b11111}; //shift to start with MSB
    
    // top of loop
    instruction_mem[33] = {LSL, R5, R5, 10'b0, 5'b1};
    instruction_mem[34] = {AND, R11, R1, R10, 10'b0};
    instruction_mem[35] = {CMP, R12, R11, R0, 10'b0};
    instruction_mem[36] = {BNZ, R12, R12, 15'd4};
    instruction_mem[39] = {AIU, R5, R5, 15'd1};
    
    // if R >= D
    
    // check R == D
    instruction_mem[40] = {CMP, R11, R5, R3, 10'b0};
    instruction_mem[41] = {BNZ, R11, R11, 15'd8}; //branch if R == D;
    
    // check R > D or 0 > D - R or D - R < 0
    instruction_mem[44] = {SUB, R11, R3, R5, 10'b0};
    instruction_mem[45] = {SLT, R11, R11, R0, 10'b0}; //1 failed check
    instruction_mem[46] = {BZ, R11, R11, 15'd5};  //branch if R < D
    
    // only here if R == D or R > D.
    instruction_mem[49] = {SUB, R5, R5, R3, 10'b0};
    instruction_mem[50] = {SBIR, R4, R4, R9, 10'b0};
    
    instruction_mem[51] = {LSR, R10, R10, 10'b0, 5'b1};
    instruction_mem[52] = {SBI, R9, R9, 15'd1};
    instruction_mem[53] = {ADI, R11, R9, 15'd1}; //gets the loop to go an extra time (super hacky)
    instruction_mem[54] = {BNZ, R11, R11, 15'b111111111101011};
    
    // Begin division (LOW BYTE)
    instruction_mem[57] = {LDI, R9, R9, 15'd31};
    instruction_mem[58] = {LDI, R10, R10, 15'b1}; //create mask
    instruction_mem[59] = {LSL, R10, R10, 10'b0, 5'b11111}; //shift to start with MSB
    
    // top of loop
    instruction_mem[60] = {LSL, R5, R5, 10'b0, 5'b1};
    instruction_mem[61] = {AND, R11, R2, R10, 10'b0};
    instruction_mem[62] = {CMP, R12, R11, R0, 10'b0};
    instruction_mem[63] = {BNZ, R12, R12, 15'd4};
    instruction_mem[66] = {AIU, R5, R5, 15'd1};
    
    // if R >= D
    
    // check R == D
    instruction_mem[67] = {CMP, R11, R5, R3, 10'b0};
    instruction_mem[68] = {BNZ, R11, R11, 15'd8}; //branch if R == D;
    
    // check R > D or 0 > D - R or D - R < 0
    instruction_mem[71] = {SUB, R11, R3, R5, 10'b0};
    instruction_mem[72] = {SLT, R11, R11, R0, 10'b0}; //1 failed check
    instruction_mem[73] = {BZ, R11, R11, 15'd5};  //branch if R < D
    
    // only here if R == D or R > D.
    instruction_mem[76] = {SUB, R5, R5, R3, 10'b0};
    instruction_mem[77] = {SBIR, R4, R4, R9, 10'b0};
    
    instruction_mem[78] = {LSR, R10, R10, 10'b0, 5'b1};
    instruction_mem[79] = {SBI, R9, R9, 15'd1};
    instruction_mem[80] = {ADI, R11, R9, 15'd1}; //gets the loop to go an extra time while keeping the indexing i want (super hacky)
    instruction_mem[81] = {BNZ, R11, R11, 15'b111111111101011};
        
    //fix signs
    instruction_mem[84] = {CMP, R11, R8, R0, 10'b0};
    instruction_mem[85] = {BNZ, R11, R11, 15'd5};
    instruction_mem[88] = {NOT, R4, R4, 15'b0};
    instruction_mem[89] = {ADI, R4, R4, 15'b1};
    
    //check overflow
    instruction_mem[90] = {SUB, R11, R1, R3, 10'b0}; //if high byte is greater than divisor, it WILL overflow (R1 > R3 or R1 - R3 > 0)
    instruction_mem[91] = {SLT, R7, R0, R11, 10'b0};
        
end

// read instruction from memory based on the address
always @(*) begin
    instruction = instruction_mem[address];
end

assign instruction_out = instruction;

endmodule
