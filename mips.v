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


wire        RegWriteD;
wire [1:0]  DatatoRegD;
wire        MemWriteD;
wire [7:0]  ALUControlD;
wire        ALUSrcAD;
wire [1:0]  ALUSrcBD;
wire        RegDstD;
wire        JumpD;
wire        BranchD;
wire        HIWrite;
wire        LOWrite;
wire [1:0]  DatatoHID;
wire [1:0]  DatatoLOD;
wire        SignD;
wire        StartDivD;
wire        AnnulD;

wire [5:0] Op;
wire [5:0] Funct;

controller c(
    Op, Funct,
    JumpD, RegWriteD, RegDstD, ALUSrcAD, ALUSrcBD, BranchD, MemWriteD, 
    DatatoRegD, HIWrite, LOWrite,DatatoHID, DatatoLOD, SignD, StartDivD, AnnulD,
    ALUControlD
);

datapath dp(
    clk, rst,

    PCF, InstF,
    
    Op, Funct,
    RegWriteD,
    DatatoRegD,
    MemWriteD,
    ALUControlD,
    ALUSrcAD,
    ALUSrcBD,
    RegDstD,
    JumpD,
    BranchD,

    HIWrite,
    LOWrite,
    DatatoHID,
    DatatoLOD,
    SignD,
    StartDivD,
    AnnulD,
    
    MemWriteM,
    ALUOutM,
    WriteDataM,
    ReadDataM
);

endmodule