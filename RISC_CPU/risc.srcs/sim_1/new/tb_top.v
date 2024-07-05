`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2024 10:26:42 PM
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_top;

reg clk;
reg reset;

wire [31:0] pc;

top UUT(clk, reset, pc);

initial {clk, reset} = 0;

always #5 clk = ~clk;

//test reset, code is in instruction memory
initial begin
//    #1000
//    reset = 1;
    
//    #5
//    reset = 0; 
end

endmodule
