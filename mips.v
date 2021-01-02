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

wire       JalD;
wire       JrD;
wire       BalD;

wire        HIWrite;
wire        LOWrite;
wire [1:0]  DatatoHID;
wire [1:0]  DatatoLOD;
wire        SignD;
wire        StartDivD;
wire        AnnulD;

wire [5:0] Op;
wire [5:0] Funct;
wire [4:0] Rt;
controller c(
    .Op(Op), 
    .Funct(Funct),
    .rt(Rt),
    .Jump(JumpD), 
    .RegWrite(RegWriteD), 
    .RegDst(RegDstD), 
    .ALUSrcA(ALUSrcAD), 
    .ALUSrcB(ALUSrcBD), 
    .Branch(BranchD), 
    .MemWrite(MemWriteD), 
    .DatatoReg(DatatoRegD), 
    .HIwrite(HIWrite), 
    .LOwrite(LOWrite),
    .DataToHI(DatatoHID), 
    .DataToLO(DatatoLOD), 
    .Sign(SignD), 
    .startDiv(StartDivD), 
    .annul(AnnulD),
    .ALUContr(ALUControlD),
    .jal(JalD), 
    .jr(JrD), 
    .bal(BalD)
);

datapath dp(
    .clk(clk), .rst(rst),

    .PCF(PCF), .InstF(InstF),
    
    .Op(Op), .Funct(Funct),
    .Rt(Rt),
    .RegWriteD(RegWriteD),
    .DatatoRegD(DatatoRegD),
    .MemWriteD(MemWriteD),
    .ALUControlD(ALUControlD),
    .ALUSrcAD(ALUSrcAD),
    .ALUSrcBD(ALUSrcBD),
    .RegDstD(RegDstD),
    .JumpD(JumpD),
    .BranchD(BranchD),

    .JalD(JalD),
    .JrD(JrD),
    .BalD(BalD),

    .HIWriteD(HIWrite),
    .LOWriteD(LOWrite),
    .DatatoHID(DatatoHID),
    .DatatoLOD(DatatoLOD),
    .SignD(SignD),
    .StartDivD(StartDivD),
    .AnnulD(AnnulD),
    
    .MemWriteM(MemWriteM),
    .ALUOutM(ALUOutM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM)
);

endmodule