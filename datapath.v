`timescale 1ns / 1ps
module datapath(
    input wire clk, rst,

    //-----fetch stage-------------------------------
    output wire[31:0] PCF,
    input  wire[31:0] InstF,
    //-----------------------------------------------

    //-----decode stage------------------------------
    output wire [5:0] Op,
    output wire [5:0] Funct,
    output wire [4:0] Rt,
    //--signals--
    input  wire       RegWriteD,
    input  wire [1:0] DatatoRegD,
    input  wire       MemWriteD,
    input  wire [7:0] ALUControlD,
    input  wire       ALUSrcAD,
    input  wire [1:0] ALUSrcBD,
    input  wire       RegDstD,
    input  wire       JumpD,
    input  wire       BranchD,
    //=====add branch and jump=====
    input  wire       JalD,
    input  wire       JrD,
    input  wire       BalD,
    //=============================

    input  wire       HIWriteD,
    input  wire       LOWriteD,
    input  wire [1:0] DatatoHID,
    input  wire [1:0] DatatoLOD,
    input  wire       SignD,
    input  wire       StartDivD,
    input  wire       AnnulD,
    //-----------------------------------------------



    //-----mem stage---------------------------------
    //--add memsel--
    output wire [3:0]  Sel,
    output wire [31:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input  wire [31:0] ReadDataM
    //-----------------------------------------------
);
wire [31:0] PC;

//-----fetch stage-----------------------------------
wire [31:0] PCPlus4F;
wire StallF;
//---------------------------------------------------


//-----decode stage----------------------------------
wire [31:0] InstD;
//--signal--
wire [1:0]  PCSrcD;
//=====add b j=====
wire        JumpSignal;
wire        BranchSignal;
//=================
//--addr--
wire [31:0] PCPlus4D, PCBranchD, PCJumpD;
//=====add b j=====
wire [31:0] PCPlus8D;
wire [31:0] ForwardJumpAddr;
//=================
wire [27:0] ExJumpAddr;
//--imm--
wire [31:0] SignImmD, ExSignImmD, ZeroImmD, SaD;
//--data--
wire [31:0] HIIn,HIDataD;
wire [31:0] LOIn,LODataD;
wire [31:0] DataAD, DataBD;
//--regs info--
wire [4:0]  RsD, RtD, RdD;
//--hazard handle--
wire [31:0] CmpA, CmpB;
wire        EqualD;
wire        ForwardAD, ForwardBD;
//=====b j=====
wire [1:0]  ForwardALD;
//=============
wire        StallD, FlushD;
//-------------------------------------------------------


//-----excute stage--------------------------------------
//--signals--
wire       RegWriteE;
wire [1:0] DatatoRegE;
wire       MemWriteE;
wire [7:0] ALUControlE;
wire       ALUSrcAE;
wire [1:0] ALUSrcBE;
wire       RegDstE;
//=====add b j=====
wire       JalE;
wire       JrE;
wire       BalE;
//=================
wire       HIWriteE;
wire       LOWriteE;
wire [1:0] DatatoHIE;
wire [1:0] DatatoLOE;
wire       SignE;
wire       StartDivE;
wire       AnnulE;
//--imm--
wire [31:0] SignImmE, ZeroImmE, SaE;
//--data--
wire [31:0] DataAE, DataBE;
wire [31:0] HIDataE, NewHIDataE;
wire [31:0] LODataE, NewLODataE;
//--regs info--
wire  [4:0] RsE, RtE, RdE;
wire  [4:0] WriteRegE;
//=====add b j=====
wire  [4:0] WriteRegTemp;
//=================
//--alu src--
wire [31:0] SrcAE, SrcBE, ALUOutE;
wire [31:0] RegValue;
wire [31:0] WriteDataE;
//=====add b j=====
wire [31:0] ALUOutTemp;
wire [31:0] PCPlus8E;
//=================
//--mult div--
wire [31:0] MultHIE, MultLOE;
wire [31:0] DivHIE, DivLOE;
wire DivReadyE;
//--hazard handle--
wire [1:0] ForwardAE, ForwardBE;
wire [1:0] ForwardHIE, ForwardLOE;
wire FlushE, StallE;
//----------------------------------------------------------


//-----mem stage--------------------------------------------
//--signals--
wire       RegWriteM;
wire [1:0] DatatoRegM;
wire [7:0] ALUControlM;
wire       JalM;
wire       BalM;
wire       HIWriteM;
wire       LOWriteM;
wire [1:0] DatatoHIM;
wire [1:0] DatatoLOM;
//--data--
wire [31:0] HIDataM;
wire [31:0] LODataM;
//--mult div--
wire [31:0] MultHIM, MultLOM;
wire [31:0] DivHIM, DivLOM;
//--regs info--
wire [4:0]  WriteRegM; 
//--mem--
//wire [3:0]  Sel;
wire [31:0] FinalDataM;
//----------------------------------------------------------


//-----writeback stage--------------------------------------
//--signals
wire       RegWriteW;
wire [1:0] DatatoRegW;
wire       HIWriteW;
wire       LOWriteW;
wire [1:0] DatatoHIW;
wire [1:0] DatatoLOW;
//--data--
wire [31:0] ReadDataW;
wire [31:0] HIDataW;
wire [31:0] LODataW;
wire [31:0] ALUOutW;
wire [31:0] ResultW;
//--mult div--
wire [31:0] MultHIW, MultLOW;
wire [31:0] DivHIW, DivLOW;
//--regs info--
wire  [4:0] WriteRegW;
//----------------------------------------------------------


//-----next pc----------------------------------------------
mux3 #(32) PCMux(PCPlus4F, PCBranchD, PCJumpD, PCSrcD, PC);
//----------------------------------------------------------


//-----fetch stage------------------------------------------
pc #(32) PCReg(clk, rst, ~StallF, PC, PCF);
adder PCAdder(PCF, 32'b100, PCPlus4F);
//----------------------------------------------------------


//-----decode stage-----------------------------------------
flopenrc #(32)D1(clk, rst, ~StallD, FlushD, InstF, InstD);
flopenrc #(32)D2(clk, rst, ~StallD, FlushD, PCPlus4F, PCPlus4D);

assign Op    = InstD[31:26];
assign RsD   = InstD[25:21];
assign RtD   = InstD[20:16];
assign RdD   = InstD[15:11];
assign Funct = InstD[5:0];
assign Rt    = RtD;

assign SaD = {27'b0, InstD[10:6]};

assign JumpSignal   = JumpD | JalD | JrD;
assign BranchSignal = BranchD | BalD;

assign PCSrcD[0:0] = BranchSignal & EqualD;
assign PCSrcD[1:1] = JumpSignal;

//--regs--
regfile Regs(clk, RegWriteW, RsD, RtD, WriteRegW, ResultW, DataAD, DataBD);
hiloreg HILO(clk, rst, HIWriteW, LOWriteW, HIIn, LOIn, HIDataD, LODataD);
//--barnch hazrad handle--
mux2 #(32)DAMux(DataAD, ALUOutM, ForwardAD, CmpA);
mux2 #(32)DBMux(DataBD, ALUOutM, ForwardBD, CmpB);
//===to be changed===
eqcmp Cmp(CmpA, CmpB, Op, RtD, EqualD);

//assign FlushD = PCSrcD[0:0] | PCSrcD[1:1];
assign FlushD = 1'b0;
//--ext imm--
signext Se(InstD[15:0], SignImmD);
zeroext Ze(InstD[15:0], ZeroImmD);
//--sl--
sl2 #(32) Sl2Imm(SignImmD, ExSignImmD);
//sl2 #(26) Sl2JumpAddr(InstD[25:0], ExJumpAddr);
//=== j ===
assign ExJumpAddr = {InstD[25:0], 2'b00};
//=========
//--branch addr--
adder BranchAdder(PCPlus4D, ExSignImmD, PCBranchD);
adder PCPlus8(PCPlus4D, 32'b100, PCPlus8D);
//--jump addr--
mux3 #(32)ForwardAL(DataAD, PCPlus8E, ALUOutM, ForwardALD, ForwardJumpAddr);
mux2 #(32)JumpMux({PCPlus4D[31:28], ExJumpAddr}, ForwardJumpAddr, JrD, PCJumpD);
//-------------------------------------------------------------


//-----excute stage---------------------------------------------
//TODO:change the bits of signal
flopenrc   #(28)E1(clk, rst, ~StallE, FlushE,
    {RegWriteD,DatatoRegD,MemWriteD,ALUControlD,ALUSrcAD,ALUSrcBD,RegDstD,
    JalD,JrD,BalD,HIWriteD,LOWriteD,DatatoHID,DatatoLOD,SignD,StartDivD,AnnulD},
    {RegWriteE,DatatoRegE,MemWriteE,ALUControlE,ALUSrcAE,ALUSrcBE,RegDstE,
    JalE,JrE,BalE,HIWriteE,LOWriteE,DatatoHIE,DatatoLOE,SignE,StartDivE,AnnulE});
flopenrc  #(32)E2(clk, rst, ~StallE, FlushE, DataAD, DataAE);
flopenrc  #(32)E3(clk, rst, ~StallE, FlushE, DataBD, DataBE);
flopenrc   #(5)E4(clk, rst, ~StallE, FlushE, RsD, RsE);
flopenrc   #(5)E5(clk, rst, ~StallE, FlushE, RtD, RtE);
flopenrc   #(5)E6(clk, rst, ~StallE, FlushE, RdD, RdE);
flopenrc  #(32)E7(clk, rst, ~StallE, FlushE, SignImmD, SignImmE);
flopenrc  #(32)E8(clk, rst, ~StallE, FlushE, ZeroImmD, ZeroImmE);
flopenrc  #(32)E9(clk, rst, ~StallE, FlushE, SaD, SaE);
flopenrc #(32)E10(clk, rst, ~StallE, FlushE, HIDataD, HIDataE);
flopenrc #(32)E11(clk, rst, ~StallE, FlushE, LODataD, LODataE);
flopenrc #(32)E12(clk, rst, ~StallE, FlushE, PCPlus8D, PCPlus8E);
//--alu forwarding--
mux2  #(5) RegMux1(RtE, RdE, RegDstE, WriteRegTemp);
mux3 #(32) ForwardAMux(DataAE, ResultW, ALUOutM, ForwardAE, RegValue);
mux3 #(32) ForwardBMux(DataBE, ResultW, ALUOutM, ForwardBE, WriteDataE);
//--alu src--
mux2 #(32) AluSrcAMux(RegValue, SaE, ALUSrcAE, SrcAE);
mux3 #(32) AluSrcBMux(WriteDataE, SignImmE, ZeroImmE, ALUSrcBE, SrcBE);
//--hilo forwarding--
mux3 #(32) ForwardHIMux(HIDataE, ALUOutM, ResultW, ForwardHIE, NewHIDataE);
mux3 #(32) ForwardLOMux(LODataE, ALUOutM, ResultW, ForwardLOE, NewLODataE);
//=====add b j=====
mux2 #(5) RegMux2(WriteRegTemp, 5'b11111, JalE | BalE, WriteRegE);
mux2 #(32) ALUMux(ALUOutTemp, PCPlus8E, JalE | JrE | BalE, ALUOutE);
//=================
alu Alu(ALUControlE, SrcAE, SrcBE, ALUOutTemp);
my_mul Mult(SrcAE, SrcBE, SignE, {MultHIE, MultLOE});
wire DivStart = StartDivE & ~ DivReadyE;
div Div(clk, rst, SignE, SrcAE, SrcBE, DivStart, AnnulE, {DivHIE, DivLOE}, DivReadyE);
//-----------------------------------------------------------


//-----mem stage---------------------------------------------
//TODO:change the bits of signal
flopr  #(20)M1(clk, rst,
    {RegWriteE,DatatoRegE,MemWriteE,ALUControlE,JalE,BalE,HIWriteE,LOWriteE,DatatoHIE,DatatoLOE},
    {RegWriteM,DatatoRegM,MemWriteM,ALUControlM,JalM,BalM,HIWriteM,LOWriteM,DatatoHIM,DatatoLOM});
flopr #(32)M2(clk, rst, ALUOutE, ALUOutM);
flopr #(32)M3(clk, rst, WriteDataE, WriteDataM);
flopr  #(5)M4(clk, rst, WriteRegE, WriteRegM);
flopr #(32)M5(clk, rst, NewHIDataE, HIDataM);
flopr #(32)M6(clk, rst, NewLODataE, LODataM);
flopr #(32)M7(clk, rst, MultHIE, MultHIM);
flopr #(32)M8(clk, rst, MultLOE, MultLOM);
flopr #(32)M9(clk, rst, DivHIE, DivHIM);
flopr#(32)M10(clk, rst, DivLOE, DivLOM);
ByteSel BS(ALUOutM[1:0], ALUControlM, Sel);
GetReadData GRD(ALUOutM[1:0], ReadDataM, ALUControlM, FinalDataM);
//------------------------------------------------------------


//-----writeback stage----------------------------------------
//TODO:change the bits of signal
flopr  #(9)W1(clk, rst,
    {RegWriteM,DatatoRegM,HIWriteM,LOWriteM,DatatoHIM,DatatoLOM},
    {RegWriteW,DatatoRegW,HIWriteW,LOWriteW,DatatoHIW,DatatoLOW});
flopr #(32)W2(clk, rst, FinalDataM, ReadDataW);
flopr #(32)W3(clk, rst, ALUOutM, ALUOutW);
flopr  #(5)W4(clk, rst, WriteRegM, WriteRegW);
flopr #(32)W5(clk, rst, HIDataM, HIDataW);
flopr #(32)W6(clk, rst, LODataM, LODataW);
flopr #(32)W7(clk, rst, MultHIM, MultHIW);
flopr #(32)W8(clk, rst, MultLOM, MultLOW);
flopr #(32)W9(clk, rst, DivHIM, DivHIW);
flopr #(32)W10(clk, rst, DivLOM, DivLOW);

mux4 #(32) DatatoRegMux (ALUOutW, LODataW, HIDataW, ReadDataW, DatatoRegW, ResultW);
mux3 #(32) DatatoHIMux  (ALUOutW, MultHIW, DivHIW, DatatoHIW, HIIn);
mux3 #(32) DatatoLOMux  (ALUOutW, MultLOW, DivLOW, DatatoLOW, LOIn);
//------------------------------------------------------------


//hazard
hazard h(
    //fetch stage
    StallF,
    //decode stage
    RsD, RtD,
    BranchD,
    JrD,

    StallD,
    ForwardAD, ForwardBD,
    ForwardALD,
    //excute stage
    RsE, RtE,
    WriteRegE,
    DatatoRegE,
    RegWriteE,
    JalE, BalE,

    StartDivE,
    DivReadyE,

    FlushE, StallE,
    ForwardAE, ForwardBE,
    ForwardHIE, ForwardLOE,
    //mem stage
    WriteRegM,
    DatatoRegM,
    RegWriteM,
    HIWriteM, LOWriteM,
    JalM, BalM,
    //writeback stage
    WriteRegW,
    RegWriteW,
    HIWriteW,
    LOWriteW
);

endmodule