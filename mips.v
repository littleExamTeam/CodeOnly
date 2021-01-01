`timescale 1ns / 1ps
module mips(
    input wire clk, rst,

    output wire [31:0] PCF,
    input  wire [31:0] InstF,

    output wire MemWriteM,
    output wire [31:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input  wire [31:0] ReadDataM
);


wire RegWriteD;
wire MemtoRegD;
wire MemWriteD;
wire [7:0] ALUControlD;
wire ALUSrcAD;
wire [1:0] ALUSrcBD;
wire RegDstD;
wire JumpD;
wire BranchD;

wire [5:0] Op;
wire [5:0] Funct;

controller c(
    Op, Funct,
    JumpD, RegWriteD, RegDstD, ALUSrcAD, ALUSrcBD, BranchD, MemWriteD, MemtoRegD,
    ALUControlD
);

datapath dp(
    clk, rst,

    PCF, InstF,
    
    Op, Funct,
    RegWriteD,
    MemtoRegD,
    MemWriteD,
    ALUControlD,
    ALUSrcAD,
    ALUSrcBD,
    RegDstD,
    JumpD,
    BranchD,
    
    MemWriteM,
    ALUOutM,
    WriteDataM,
    ReadDataM
);

endmodule