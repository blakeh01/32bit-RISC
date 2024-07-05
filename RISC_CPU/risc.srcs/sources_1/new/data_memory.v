`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Blake Havens
// 
// Create Date: 03/06/2024 11:14:47 PM
// Module Name: data_memory
// Project Name: HWK 5 - Pipelined RISC
//////////////////////////////////////////////////////////////////////////////////

module data_memory(
    input clk,
    input [31:0] address,
    input [31:0] data_in, // on Bus B
    input MW,
    
    output reg [31:0] data_out
);

reg [31:0] data_mem [0:1023]; // 1024 x 32-bit

// set all registers to 0 at birth of universe
integer i;
initial begin
    for(i = 0; i < 1023; i = i + 1) begin
        data_mem[i] = 0;
    end
        
    // division data
    data_mem[0] = 32'h0000_ffff;   // h byte dividend
    data_mem[1] = 32'h0000_abcd;   // l byte dividend
    data_mem[2] = 32'd5;   // divisor

end

always @(posedge clk) begin
    if(MW) data_mem[address] = data_in;
end

always @(*) begin
    data_out = data_mem[address];
end

endmodule
