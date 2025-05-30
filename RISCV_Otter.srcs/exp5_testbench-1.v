`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 01/07/2020 12:59:51 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench file for Exp 5
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module otter_tb();

    reg clk = 0;

    reg [4:0] btns = 0;
    reg [15:0] swit = 0;
    wire [15:0] leds;
    wire [7:0] segs;
    wire [3:0] an;

OTTER_Wrapper  otter(
     .clk       (clk),
     .buttons   (btns),
     .switches  (swit),
     .leds      (leds),
     .segs      (segs), 
     .an        (an)   );
     
   //- Generate periodic clock signal    
   initial    
      begin       
         clk = 0;   //- init signal        
         forever  #10 clk = ~clk;    
      end                        
         
   initial        
   begin           
      btns[3] = 1;
      #40

      btns[3] = 0;  
      btns[4] = 1;
      #400
      btns[4] = 0;
      #8000
      btns[4] = 1;
      #400
      btns[4] = 0;
    end
        
 endmodule
