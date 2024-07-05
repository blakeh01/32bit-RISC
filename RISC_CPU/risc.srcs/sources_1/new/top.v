`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: top module for RISC CPU
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,
    input reset,
    
    output reg [31:0] PC
);

// PC control
reg [31:0] PC_t1;
reg [31:0] PC_t2;
wire DHS; // data hazard stall flag

wire [1:0] MC;
wire [31:0] BrA;
wire [31:0] RAA;

// IF Step
reg [31:0] IR;
wire [31:0] loaded_instruction;

// DOF step
wire RW;
wire [4:0] DA;
wire [1:0] MD;
wire [1:0] BS;
wire [1:0] MS;
wire PS;
wire MW;
wire [4:0] FS;
wire [4:0] SH;
wire [14:0] IM;
wire MA;
wire MB;
wire [4:0] AA;
wire [4:0] BA;
wire CS;

wire [31:0] A_out;
wire [31:0] B_out;

wire [31:0] bus_A;
wire [31:0] bus_B;

// EX step
reg RW_ex;
reg [4:0] DA_ex;
reg [1:0] MD_ex;
reg [1:0] BS_ex;
reg [2:0] MS_ex;
reg PS_ex;
reg MW_ex;
reg [4:0] FS_ex;
reg [4:0] SH_ex;

reg [31:0] bus_A_ex;
reg [31:0] bus_B_ex;

// WB step
reg RW_wb;
reg [4:0] DA_wb;
reg [1:0] MD_wb;

reg [31:0] F_wb;
reg [31:0] data_wb;

reg slt_wb;
reg Z, V, N, C;
wire Z_out, V_out, N_out, C_out;

wire [31:0] bus_D;
wire [31:0] D_out;
wire [31:0] F_out;

register_file reg_file(
    .clk(clk),
    .reset(reset),
    .AA(AA),
    .BA(BA),
    .DA(DA_wb),
    .Dbus(bus_D),
    .RW(RW_wb),
    
    .Aout(A_out),
    .Bout(B_out)
);

instruction_memory inst_mem(
    .address(PC), 
    .instruction_out(loaded_instruction)
);

instruction_decoder inst_dec (
    .instruction(IR),
    .RW_out(RW),
    .IM_out(IM),
    .DA_out(DA),
    .MD_out(MD),
    .BS_out(BS),
    .MS_out(MS),
    .PS_out(PS),
    .MW_out(MW),
    .FS_out(FS),
    .SH_out(SH),
    .MA_out(MA),
    .MB_out(MB),
    .AA_out(AA),
    .BA_out(BA),
    .CS_out(CS)
);

function_unit func_unit (
    .A(bus_A_ex),
    .B(bus_B_ex),
    .SH(SH_ex),
    .FS(FS_ex),
    
    .F(F_out),
    .Z(Z_out), .V(V_out), .N(N_out), .C(C_out)
);

data_memory data_mem (
    .clk(clk),
    .address(bus_A_ex),
    .data_in(bus_B_ex),
    .MW(MW_ex),
    
    .data_out(D_out)
);

initial {PC, PC_t1, PC_t2, IR, RW_ex, DA_ex, MD_ex, BS_ex, PS_ex, MW_ex, FS_ex, SH_ex, bus_A_ex, bus_B_ex, RW_wb, DA_wb, MD_wb, F_wb, data_wb, slt_wb, Z, V, N, C} = 0;

always @ (*) begin
    if (reset) begin
        {PC, PC_t1, PC_t2, IR, RW_ex, DA_ex, MD_ex, BS_ex, PS_ex, MW_ex, FS_ex, SH_ex, bus_A_ex, bus_B_ex, RW_wb, DA_wb, MD_wb, F_wb, data_wb, slt_wb, Z, V, N, C} = 0;
    end
    
end

always @ (negedge clk)
begin
    if(~DHS) begin //stop PC from changing if DHS
        PC <= ((MC == 2'b00) ? PC + 1 : 
              (MC == 2'b01 || MC == 2'b11) ? BrA : 
              (MC == 2'b10) ? RAA : PC + 1);
        PC_t2 <= (PC_t1);
        PC_t1 <= (PC);
    end
    
    // IF Step
    if(~DHS) IR <= loaded_instruction; //stop IR from changing if DHS
    
    // DOF Step
    RW_ex <= RW & (~DHS); // force RW, DA, BS, MW to 0 if DHS or BPE (except DA)
    DA_ex <= DA & (~DHS);
    BS_ex <= BS & (~DHS);
    MW_ex <= MW & (~DHS);
    
    MS_ex <= MS;
    MD_ex <= MD;
    PS_ex <= PS;
    FS_ex <= FS;
    SH_ex <= SH;
    
    bus_A_ex <= bus_A;
    bus_B_ex <= bus_B;
    
    //EX Step
    RW_wb <= RW_ex;
    DA_wb <= DA_ex;
    MD_wb <= MD_ex;
    
    F_wb <= F_out;
    data_wb <= D_out;
    
    slt_wb <= N_out ^ V_out;
    Z <= Z_out;
    V <= V_out;
    N <= N_out;
    C <= C_out;

end

assign bus_A = (MA == 0) ? A_out : PC_t1;
assign bus_B = (MB == 0) ? B_out : ((CS == 1) ? {{17{IM[14]}}, IM} : {17'b0, IM}); //select either reg data or constant (zf or se on CS)
assign MS_sel = (MS_ex == 3'b000) ? Z_out :
                (MS_ex == 3'b001) ? V_out :
                (MS_ex == 3'b010) ? N_out :
                (MS_ex == 3'b011) ? C_out : 
                (MS_ex == 3'b100) ? Z :
                (MS_ex == 3'b101) ? V :
                (MS_ex == 3'b110) ? N :
                (MS_ex == 3'b111) ? C :0;
assign MC = {BS_ex[1], ((PS_ex ^ MS_sel) | BS_ex[1]) & BS_ex[0]};
assign RAA = bus_A_ex;
assign BrA = bus_B_ex + PC_t2;
assign bus_D =  (MD_wb == 2'b00) ? F_wb : 
                (MD_wb == 2'b01) ? data_wb :
                (MD_wb == 2'b10) ? {31'b0, slt_wb} : 
                (MD_wb == 2'b11) ? {31'b0, Z} : 32'bx; //CMP logic
assign DHS = ((AA == DA_ex) && (~MA) && (RW_ex) && (|DA_ex)) || ((BA == DA_ex) && (~MB) && (RW_ex) && (|DA_ex));

endmodule
