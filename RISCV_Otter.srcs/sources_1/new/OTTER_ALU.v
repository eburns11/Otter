`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 05:56:29 PM
// Design Name: 
// Module Name: OTTER_ALU
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


module OTTER_ALU(
    input [31:0] op1,
    input [31:0] op2,
    input [3:0] func,
    output reg [31:0] result
    );
    parameter [3:0] ADD = 4'b0000, SUB = 4'b1000, OR = 4'b0110, AND = 4'b0111, XOR = 4'b0100,
        SRL = 4'b0101, SLL = 4'b0001, SRA = 4'b1101, SLT = 4'b0010, SLTU = 4'b0011, LUI = 4'b1001;
    
    always @ (func or op1 or op2) begin
        case(func)
            ADD:  result = op1 + op2;
            SUB:  result = op1 - op2;
            OR:   result = op1 | op2;
            AND:  result = op1 & op2;
            XOR:  result = op1 ^ op2;
            SRL:  result = op1 >> op2[4:0];
            SLL:  result = op1 << op2[4:0];
            SRA:  result = $signed(op1) >>> op2[4:0];
            SLT:  result = ($signed(op1) < $signed(op2)) ? 1 : 0;
            SLTU: result = (op1 < op2) ? 1 : 0;
            LUI:  result = op1;
            default: result = 0;
        endcase
    end
endmodule
