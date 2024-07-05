`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: instruction_decoder
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////

module instruction_decoder(
    input [31:0] instruction,
    
    output RW_out,
    output [14:0] IM_out,
    output [4:0] DA_out,
    output [1:0] MD_out,
    output [1:0] BS_out,
    output [2:0] MS_out,
    output PS_out,
    output MW_out,
    output [4:0] FS_out,
    output [4:0] SH_out,
    output MA_out,
    output MB_out,
    output [4:0] AA_out,
    output [4:0] BA_out,
    output CS_out
);

`include "RISC_header.vh"

reg [6:0] opcode;

reg RW;
reg [14:0] IM;
reg [4:0] DA;
reg [1:0] MD;
reg [1:0] BS;
reg [2:0] MS;
reg PS;
reg MW;
reg [4:0] FS;
reg [4:0] SH;
reg MA;
reg MB;
reg [4:0] AA;
reg [4:0] BA;
reg CS;

initial {opcode, RW, IM, DA, MD, BS, PS, MW, FS, SH, MA, MB, AA, BA, CS, MS} = 0;

always @(*)
begin
    {opcode, RW, DA, MD, BS, PS, MW, FS, SH, MA, MB, AA, BA, CS, MS} = 0;
    
    opcode = instruction[31:25];
    DA = instruction[24:20];
    AA = instruction[19:15];
    BA = instruction[14:10];
    IM = instruction[14:0];
    SH = instruction[4:0];
    
    case(opcode)
        NOP: begin
        end
        
        LDI: begin
            RW = 1;
            FS = 5'b00001;
            CS = 1;
            MB = 1;
        end
        
        ADD: begin
            RW = 1;
            FS = 5'b00010;
        end
        
        SUB: begin
            RW = 1;
            FS = 5'b00101;
        end
        
        SLT: begin
            RW = 1;
            FS = 5'b00101;
            MD = 2'b10;
        end
        
        CMP: begin
            RW = 1;
            FS = 5'b00101;
            MD = 2'b11;
        end
        
        AND: begin
            RW = 1;
            FS = 5'b01000;
        end
        
        OR: begin
            RW = 1;
            FS = 5'b01010;
        end
        
        XOR: begin
            RW = 1;
            FS = 5'b01100;
        end
        
        ST: begin
            MW = 1;
        end
        
        LD: begin
            RW = 1;
            MD = 2'b01;
        end
        
        ADI: begin
            RW = 1;
            FS = 5'b00010;
            MB = 1;
            CS = 1;
        end
        
        SBI: begin
            RW = 1;
            FS = 5'b00101;
            MB = 1;
            CS = 1;
        end
        
        NOT: begin
            RW = 1;
            FS = 5'b01110;
        end
        
        ANI: begin
            RW = 1;
            FS = 5'b01000;
            MB = 1;
        end
        
        ORI: begin
            RW = 1;
            FS = 5'b01010;
            MB = 1;
        end
        
        XRI: begin
            RW = 1;
            FS = 5'b01100;
            MB = 1;
        end
        
        AIU: begin
            RW = 1;
            FS = 5'b00010;
            MB = 1;
        end
        
        SIU: begin
            RW = 1;
            FS = 5'b00101;
            MB = 1;
        end
        
        MOV: begin
            RW = 1;
        end
        
        LSL: begin
            RW = 1;
            FS = 5'b10000;
        end
        
        LSR: begin
            RW = 1;
            FS = 5'b10001;
        end
        
        JMR: begin
            BS = 2'b10;
        end
        
        BZ: begin
            BS = 2'b01;
            MB = 1;
            CS = 1;
        end
        
        BNZ: begin
            BS = 2'b01;
            PS = 1;
            MB = 1;
            CS = 1;
        end
        
        BV: begin
            BS = 2'b01;
            MB = 1;
            CS = 1;
            MS = 3'b101;
        end
        
        BNV: begin
            BS = 2'b01;
            PS = 1;
            MB = 1;
            CS = 1;
            MS = 3'b101;
        end
        
        BN: begin
            BS = 2'b01;
            MB = 1;
            CS = 1;
            MS = 3'b110;
        end
        
        BNN: begin
            BS = 2'b01;
            PS = 1;
            MB = 1;
            CS = 1;
            MS = 3'b110;
        end
        
        BC: begin
            BS = 2'b01;
            MB = 1;
            CS = 1;
            MS = 3'b111;
        end
        
        BNC: begin
            BS = 2'b01;
            PS = 1;
            MB = 1;
            CS = 1;
            MS = 3'b111;
        end
        
        JMP: begin
            BS = 2'b11;
            MB = 1;
            CS = 1;
        end
        
        JML: begin
            RW = 1;
            BS = 2'b11;
            FS = 5'b00000;
            MB = 1;
            MA = 1;
            CS = 1;
        end
        
        //set bit in register
        SBIR: begin
            RW = 1;
            FS = 5'b10111;
            MB = 0;
        end
        
    endcase
end

assign RW_out = RW;
assign IM_out = IM;
assign DA_out = DA;
assign MD_out = MD;
assign BS_out = BS;
assign MS_out = MS;
assign PS_out = PS;
assign MW_out = MW;
assign FS_out = FS;
assign SH_out = SH;
assign MA_out = MA;
assign MB_out = MB;
assign AA_out = AA;
assign BA_out = BA;
assign CS_out = CS;

endmodule
