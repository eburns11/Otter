`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2025 06:44:37 PM
// Design Name: 
// Module Name: CU_Decoder
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


module CU_Decoder(
    input [6:0] OPCODE,
    input [2:0] FUNC3,
    input FUNC7,
    input int_taken,
    input br_eq,
    input br_lt,
    input br_ltu,
    output reg [3:0] ALU_FUN,
    output reg [1:0] ALU_A_Sel,
    output reg [2:0] ALU_B_Sel,
    output reg [2:0] PC_SEL,
    output reg [1:0] RF_SEL
    );
    
    typedef enum logic [6:0] {  //opcode types
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
    opcode_t opcode;
    assign opcode = opcode_t'(OPCODE);
    
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
   } func3_t;    
   func3_t func3;
   assign func3 = func3_t'(FUNC3);
    
    always_comb begin
        ALU_FUN = '0;
        ALU_A_Sel = '0;
        ALU_B_Sel = '0;
        PC_SEL = '0;
        RF_SEL = '0;
        case(opcode)
            LUI: begin  //lui
                ALU_FUN = 4'b1001;
                ALU_A_Sel = 2'b01;
                ALU_B_Sel = '0;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = 2'b11;
            end
            AUIPC: begin  //auipc
                ALU_FUN = 4'b0000;
                ALU_A_Sel = 2'b01;
                ALU_B_Sel = 3'b011;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = 2'b11;
            end
            JAL: begin  //jal
                ALU_FUN = '0;
                ALU_A_Sel = '0;
                ALU_B_Sel = '0;
                PC_SEL = (int_taken) ? 3'b100 : 3'b011;
                RF_SEL = 2'b0;
            end
            JALR: begin  //jalr
                ALU_FUN = '0;
                ALU_A_Sel = '0;
                ALU_B_Sel = '0;
                PC_SEL = (int_taken) ? 3'b100 : 3'b001;
                RF_SEL = 2'b0;
            end
            LOAD: begin //load
                ALU_FUN = 4'b0000;
                ALU_A_Sel = 2'b00;
                ALU_B_Sel = 3'b001;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = 2'b10;
            end
            OP_IMM: begin //operations w immediate
                ALU_A_Sel = 2'b00;
                ALU_B_Sel = 3'b001;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = 2'b11;
                if (FUNC3 == 3'b101) begin
                    ALU_FUN = {FUNC7,FUNC3};
                end else begin
                    ALU_FUN = {1'b0,FUNC3};
                end
             end
             BRANCH: begin //branch
                ALU_FUN = '0;
                ALU_A_Sel = '0;
                ALU_B_Sel = '0;
                RF_SEL = '0;
                case(func3)
                    BEQ: PC_SEL = (int_taken) ? 3'b100 : {br_eq,1'b0};
                    BNE: PC_SEL = (int_taken) ? 3'b100 : {~br_eq,1'b0};
                    BLT: PC_SEL = (int_taken) ? 3'b100 : {br_lt,1'b0};
                    BGE: PC_SEL = (int_taken) ? 3'b100 : {~br_lt,1'b0};
                    BLTU: PC_SEL = (int_taken) ? 3'b100 : {br_ltu,1'b0};
                    BGEU: PC_SEL = (int_taken) ? 3'b100 : {~br_ltu,1'b0};
                    default: PC_SEL = (int_taken) ? 3'b100 : '0;
                endcase
            end
            STORE: begin //store
                ALU_FUN = 4'b0000;
                ALU_A_Sel = 2'b00;
                ALU_B_Sel = 3'b010;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = '0;
            end
            OP_RG3: begin
                ALU_A_Sel = '0;
                ALU_B_Sel = '0;
                PC_SEL = (int_taken) ? 3'b100 : '0;
                RF_SEL = 2'b11;
                if (FUNC3 == 3'b000) ALU_FUN = {FUNC7,FUNC3};
                else if (FUNC3 == 3'b101) ALU_FUN = {FUNC7,FUNC3};
                else ALU_FUN = {1'b0,FUNC3};
            end
            SYS: begin
                case (FUNC3)
                    3'b001: begin  //CSRRW
                        ALU_FUN = 4'b1001;
                        ALU_A_Sel = 2'b00;
                        ALU_B_Sel = '0;
                        PC_SEL = (int_taken) ? 3'b100 : '0;
                        RF_SEL = 2'b01;
                    end
                    3'b011: begin  //CSRRC
                        ALU_FUN = 4'b0111;
                        ALU_A_Sel = 2'b10;
                        ALU_B_Sel = 3'b100;
                        PC_SEL = (int_taken) ? 3'b100 : '0;
                        RF_SEL = 2'b01;
                    end
                    3'b010: begin  //CSRRS
                        ALU_FUN = 4'b0110;
                        ALU_A_Sel = 2'b00;
                        ALU_B_Sel = 3'b100;
                        PC_SEL = (int_taken) ? 3'b100 : '0;
                        RF_SEL = 2'b01;
                    end
                    3'b000: begin  //MRET
                        ALU_FUN = '0;
                        ALU_A_Sel = '0;
                        ALU_B_Sel = '0;
                        PC_SEL = (int_taken) ? 3'b100 : 3'b101;
                        RF_SEL = '0;
                    end
                endcase
            end
        endcase
    end
endmodule
