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
    input  wire RegWriteD,
    input  wire MemtoRegD,
    input  wire MemWriteD,
    input  wire [7:0] ALUControlD,
    //add shift inst oprand
    input  wire ALUSrcAD,
    //--------------------- 
    //add logic inst oprand
    input  wire [1:0] ALUSrcBD,
    //---------------------
    input  wire RegDstD,
    input  wire JumpD,
    input  wire BranchD,
    //-----------------------------------------------

    //-----mem stage---------------------------------
    output wire MemWriteM,
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
wire [31:0] PCPlus4D;
wire [31:0] PCBranchD;
wire [31:0] PCJumpD;
wire [31:0] SignImmD;
//add logic inst oprand
wire [31:0] ZeroImmD;
//---------------------
wire [31:0] ExSignImmD;
//add shift inst oprand
wire [31:0] SaD;
//---------------------
wire [27:0] ExJumpAddr;
wire [31:0] DataAD, DataBD;
wire [31:0] CmpA, CmpB;
wire [31:0] EqualD;
wire  [4:0] RsD, RtD, RdD;
wire [1:0] ForwardAD, ForwardBD;
wire StallD, FlushD;
//-------------------------------------------------------


//-----excute stage--------------------------------------
wire RegWriteE;
wire MemtoRegE;
wire MemWriteE;
wire [7:0] ALUControlE;
//add shift inst oprand
wire ALUSrcAE;
//---------------------
//add logic inst oprand
wire [1:0] ALUSrcBE;
//---------------------
wire RegDstE;
wire [1:0] PCSrcD;
wire [31:0] SignImmE;
//add logic inst oprand
wire [31:0] ZeroImmE;
//---------------------
wire [31:0] ExSignImmE;
wire [31:0] DataAE, DataBE;
wire [31:0] SrcAE, SrcBE, ALUOutE;
wire [31:0] WriteDataE;
//add shift inst oprand
wire [31:0] RegValue;
wire [31:0] SaE;
//---------------------
wire  [4:0] RsE, RtE, RdE;
wire  [4:0] WriteRegE;

wire [1:0] ForwardAE, ForwardBE;
wire FlushE;
//----------------------------------------------------------


//-----mem stage--------------------------------------------
wire RegWriteM;
wire MemtoRegM;

wire [4:0] WriteRegM; 
//----------------------------------------------------------


//-----writeback stage--------------------------------------
wire RegWriteW;
wire MemtoRegW;

wire [31:0] ReadDataW;
wire [31:0] ALUOutW;
wire [31:0] ResultW;
wire  [4:0] WriteRegW;
//----------------------------------------------------------


//-----next pc----------------------------------------------
mux3 #(32) pcmux(PCPlus4F, PCBranchD, PCJumpD, PCSrcD, PC);
//----------------------------------------------------------


//-----fetch stage------------------------------------------
pc #(32) pcreg(clk, rst, ~StallF, PC, PCF);
adder pcadder(PCF, 32'b100, PCPlus4F);
//----------------------------------------------------------


//-----decode stage-----------------------------------------
assign Op    = InstD[31:26];
assign RsD   = InstD[25:21];
assign RtD   = InstD[20:16];
assign RdD   = InstD[15:11];
assign Funct = InstD[5:0];
//add shift inst oprand
assign SaD = {27'b0, InstD[10:6]};
//---------------------

assign PCSrcD[0:0] = BranchD & EqualD;
assign PCSrcD[1:1] = JumpD;

assign FlushD = PCSrcD[0:0] | PCSrcD[1:1];

flopenrc #(32)D1(clk, rst, ~StallD, FlushD, InstF, InstD);
flopenrc #(32)D2(clk, rst, ~StallD, FlushD, PCPlus4F, PCPlus4D);

regfile rf(clk, RegWriteW, RsD, RtD, WriteRegW, ResultW, DataAD, DataBD);

mux2 #(32)DAmux(DataAD, ALUOutM, ForwardAD, CmpA);
mux2 #(32)DBmux(DataBD, ALUOutM, ForwardBD, CmpB);
eqcmp cmp(CmpA, CmpB, EqualD);

signext se(InstD[15:0], SignImmD);
zeroext ze(InstD[15:0], ZeroImmD);

sl2 #(32)sl21(SignImmD, ExSignImmD);
adder branchadder(PCPlus4D, ExSignImmD, PCBranchD);

sl2 #(26)sl22(InstD[25:0], ExJumpAddr);
assign PCJumpD = {InstD[31:28], ExJumpAddr};
//-------------------------------------------------------------


//-----excute stage---------------------------------------------
//add shift logic oprand
floprc  #(15)E1(clk, rst, FlushE,
    {RegWriteD,MemtoRegD,MemWriteD,ALUControlD,ALUSrcAD,ALUSrcBD,RegDstD},
    {RegWriteE,MemtoRegE,MemWriteE,ALUControlE,ALUSrcAE,ALUSrcBE,RegDstE});
//---------------------
floprc #(32)E2(clk, rst, FlushE, DataAD, DataAE);
floprc #(32)E3(clk, rst, FlushE, DataBD, DataBE);
floprc  #(5)E4(clk, rst, FlushE, RsD, RsE);
floprc  #(5)E5(clk, rst, FlushE, RtD, RtE);
floprc  #(5)E6(clk, rst, FlushE, RdD, RdE);
floprc #(32)E7(clk, rst, FlushE, SignImmD, SignImmE);
//add logic inst oprand
floprc #(32)E8(clk, rst, FlushE, ZeroImmD, ZeroImmE);
//---------------------
//add shift inst oprand
floprc #(32)E9(clk, rst, FlushE, SaD, SaE);
//---------------------

mux2  #(5) regmux(RtE, RdE, RegDstE, WriteRegE);
mux3 #(32) forwardamux(DataAE, ResultW, ALUOutM, ForwardAE, SrcAE);
mux3 #(32) forwardbmux(DataBE, ResultW, ALUOutM, ForwardBE, WriteDataE);
//add shift inst oprand
mux2 #(32) alusrcamux(RegValue, SaE, ALUSrcAE,SrcAE);
//---------------------
//add logic inst oprand
mux3 #(32) alusrcbmux(WriteDataE, SignImmE, ZeroImmE, ALUSrcBE, SrcBE);
//---------------------

alu alu(ALUControlE, SrcAE, SrcBE, ALUOutE);
//-----------------------------------------------------------


//-----mem stage---------------------------------------------
flopr  #(3)M1(clk, rst,
    {RegWriteE,MemtoRegE,MemWriteE},
    {RegWriteM,MemtoRegM,MemWriteM});
flopr #(32)M2(clk, rst, ALUOutE, ALUOutM);
flopr #(32)M3(clk, rst, WriteDataE, WriteDataM);
flopr  #(5)M4(clk, rst, WriteRegE, WriteRegM);
//------------------------------------------------------------


//-----writeback stage----------------------------------------
flopr  #(2)W1(clk, rst,
    {RegWriteM,MemtoRegM},{RegWriteW,MemtoRegW});
flopr #(32)W2(clk, rst, ReadDataM, ReadDataW);
flopr #(32)W3(clk, rst, ALUOutM, ALUOutW);
flopr  #(5)W4(clk, rst, WriteRegM, WriteRegW);

mux2 #(32)resultmux(ALUOutW, ReadDataW, MemtoRegW, ResultW);
//------------------------------------------------------------


//hazard
hazard h(
    //fetch stage
    StallF,
    //decode stage
    RsD, RtD,
    BranchD,

    StallD,
    ForwardAD, ForwardBD,
    //excute stage
    RsE, RtE,
    WriteRegE,
    MemtoRegE,
    RegWriteE,

    FlushE,
    ForwardAE, ForwardBE,
    //mem stage
    WriteRegM,
    MemtoRegM,
    RegWriteM,
    //writeback stage
    WriteRegW,
    RegWriteW
);

endmodule