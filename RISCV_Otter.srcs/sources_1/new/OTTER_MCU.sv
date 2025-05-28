`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 05:49:46 PM
// Design Name: 
// Module Name: OTTER_MCU
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


module OTTER_MCU(
    input RST,
    input intr,
    input clk,
    input [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output iobus_wr
    );
    
    //program counter
    wire [31:0] pc;
    wire pc_we;
    wire pc_reset;
    wire [2:0] pc_sel;
    wire [31:0] pc_mux_out;
    wire [31:0] plus_4;
    assign plus_4 = pc + 4;
    
    //memory
    wire [31:0] ir;
    wire memrden1;
    wire memrden2;
    wire memwe2;
    wire [31:0] memdout2;
    
    
    //register file
    wire [1:0] rf_sel;
    wire [31:0] w_data;
    wire rf_we;
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    //immediate generator
    wire [31:0] u_type;
    assign u_type = {ir[31:12],12'b0};
    wire [31:0] i_type;
    assign i_type = {{21{ir[31]}},ir[30:20]};
    wire [31:0] s_type;
    assign s_type = {{21{ir[31]}},ir[30:25],ir[11:7]};
    wire [31:0] j_type;
    assign j_type = {{12{ir[31]}},ir[19:12],ir[20],ir[30:21],1'b0};
    wire [31:0] b_type;
    assign b_type = {{20{ir[31]}},ir[7],ir[30:25],ir[11:8],1'b0};
    
    //branch addr generator
    wire [31:0] jal;
    assign jal = pc + j_type;
    wire [31:0] branch;
    assign branch = pc + b_type;
    wire [31:0] jalr;
    assign jalr = rs1 + i_type;
    
    //branch cond generator
    wire br_eq;
    assign br_eq = (rs1 == rs2);
    wire br_lt;
    assign br_lt = ($signed(rs1) < $signed(rs2));
    wire br_ltu;
    assign br_ltu = (rs1 < rs2);
    
    //ALU
    wire [3:0] alu_fun;
    wire [1:0] alu_a_sel;
    wire [2:0] alu_b_sel;
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] complement_rs1;
    assign complement_rs1 = ~rs1;
    wire [31:0] alu_out;
    
    //CSR
    wire CSR_WE;
    wire int_taken;
    wire mret_exec;
    wire [31:0] mtvec;
    wire [31:0] mepc;
    wire [31:0] csr_RD;
    wire mie;
    
    //iobus
    assign iobus_out = rs2;
    assign iobus_addr = alu_out;
    
    //interrupt
    wire intr_in;
    assign intr_in = mie & intr;
    
    CU_Decoder mcuDecoder (
        .OPCODE     (ir[6:0]),
        .FUNC3      (ir[14:12]),
        .FUNC7      (ir[30]),
        .int_taken  (int_taken),
        .br_eq      (br_eq),
        .br_lt      (br_lt),
        .br_ltu     (br_ltu),
        .ALU_FUN    (alu_fun),
        .ALU_A_Sel  (alu_a_sel),
        .ALU_B_Sel  (alu_b_sel),
        .PC_SEL     (pc_sel),
        .RF_SEL     (rf_sel) );
        
    CU_FSM mcuFSM (
        .intr      (intr_in),
        .clk       (clk),
        .RST       (RST),
        .opcode    (ir[6:0]),
        .func3     (ir[14:12]),
        .PC_WE     (pc_we),
        .RF_WE     (rf_we),
        .memWE2    (memwe2),
        .memRDEN1  (memrden1),
        .memRDEN2  (memrden2),
        .reset     (pc_reset),
        .CSR_WE    (CSR_WE),
        .int_taken (int_taken),
        .mret_exec (mret_exec));
    
    reg_nb #(.n(32)) PC (
          .data_in  (pc_mux_out),
          .ld       (pc_we), 
          .clk      (clk), 
          .clr      (pc_reset), 
          .data_out (pc) );
          
    mux_8t1_nb  #(.n(32)) PC_MUX  (
       .SEL   (pc_sel), 
       .D0    (plus_4), 
       .D1    (jalr), 
       .D2    (branch), 
       .D3    (jal),
       .D4    (mtvec),
       .D5    (mepc),
       .D6    ('0),
       .D7    ('0),
       .D_OUT (pc_mux_out) );
    
    Memory OTTER_MEMORY (
    .MEM_CLK   (clk),
    .MEM_RDEN1 (memrden1), 
    .MEM_RDEN2 (memrden2), 
    .MEM_WE2   (memwe2),
    .MEM_ADDR1 (pc[15:2]),
    .MEM_ADDR2 (alu_out),
    .MEM_DIN2  (rs2),  
    .MEM_SIZE  (ir[13:12]),
    .MEM_SIGN  (ir[14]),
    .IO_IN     (iobus_in),
    .IO_WR     (iobus_wr),
    .MEM_DOUT1 (ir),
    .MEM_DOUT2 (memdout2)  );
    
    mux_4t1_nb  #(.n(32)) REG_MUX  (
       .SEL   (rf_sel), 
       .D0    (plus_4), 
       .D1    ('0), 
       .D2    (memdout2), 
       .D3    (alu_out),
       .D_OUT (w_data) );
    
    RegFile my_regfile (
    .w_data (w_data),
    .clk    (clk), 
    .en     (rf_we),
    .adr1   (ir[19:15]),
    .adr2   (ir[24:20]),
    .w_adr  (ir[11:7]),
    .rs1    (rs1), 
    .rs2    (rs2)  );
    
    mux_4t1_nb  #(.n(32)) ALU_MUX_A  (
       .SEL   (alu_a_sel), 
       .D0    (rs1),
       .D1    (u_type),
       .D2    (complement_rs1), 
       .D3    ('0),
       .D_OUT (alu_a) );
       
   mux_8t1_nb  #(.n(32)) ALU_MUX_B  (
       .SEL   (alu_b_sel), 
       .D0    (rs2), 
       .D1    (i_type), 
       .D2    (s_type), 
       .D3    (pc),
       .D4    (csr_RD),
       .D5    ('0),
       .D6    ('0),
       .D7    ('0),
       .D_OUT (alu_b) );
    
    OTTER_ALU ALU (
        .op1    (alu_a),
        .op2    (alu_b),
        .func   (alu_fun),
        .result (alu_out)  );
        
    CSR  my_csr (
    .CLK        (clk),
    .RST        (pc_reset),
    .MRET_EXEC  (mret_exec),
    .INT_TAKEN  (int_taken),
    .ADDR       (ir[31:20]),
    .PC         (pc),
    .WD         (alu_out),
    .WR_EN      (CSR_WE),
    .RD         (csr_RD),
    .CSR_MEPC   (mepc),
    .CSR_MTVEC  (mtvec),
    .CSR_MSTATUS_MIE (mie)    );
    
endmodule
