`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2025 04:58:08 PM
// Design Name: 
// Module Name: intr_tb
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


module intr_tb();
    
    reg clk = 0;
    reg [4:0] buttons = 0;
    reg [15:0] switches = 0;
    wire [7:0] segs;
    
    always #1 clk = ~clk;

    OTTER_Wrapper OTTER (
    .clk      (clk),
    .buttons  (buttons),
    .switches (switches),
    .leds     (),
    .segs     (segs),
    .an       ());
    
    initial begin
        buttons[3] = 1;
        #8
        buttons[3] = 0;
        #150
        buttons[4] = 1;
        #6
        buttons[4] = 0;
    end        
endmodule
