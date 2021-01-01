`timescale 1ns / 1ps
module hazard(
    //fetch stage
    output wire StallF,

    //decode stage
    input wire [4:0] RsD, RtD,
    input wire BranchD,
    //=====b j=====
    input wire JrD,
    //=============

    output wire StallD,
    output wire ForwardAD, ForwardBD,
    output reg [1:0] ForwardALD,

    //excute stage
    input wire [4:0] RsE, RtE,
    input wire [4:0] WriteRegE,
    input wire [1:0] DatatoRegE,
    input wire RegWriteE,
    //=====b j=====
    input wire JalE, BalE,
    //=============
    input wire StartDivE,
    input wire DivReadyE,

    output wire FlushE, StallE,
    output reg [1:0] ForwardAE, ForwardBE,
    //add movedata inst oprand
    output reg [1:0] ForwardHIE, ForwardLOE,
    //------------------------

    //mem stage
    input wire [4:0] WriteRegM,
    input wire [1:0] DatatoRegM,
    input wire RegWriteM,
    input wire HIWriteM, LOWriteM,
    //=====b j=====
    input wire JalM, BalM,
    //=============
    //------------------------

    //writeback stage
    input wire [4:0] WriteRegW,
    input wire RegWriteW,
    //add movedata inst oprand
    input wire HIWriteW, LOWriteW
    //------------------------
);

wire LwStallD, BranchStallD, JumpStallD, DivStall;

//decode stage forwarding
assign ForwardAD = (RsD != 0 & RsD == WriteRegM & RegWriteM);
assign ForwardBD = (RtD != 0 & RtD == WriteRegM & RegWriteM);

//excute stage forwarding
always @(*) begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    ForwardHIE = 2'b00; 
    ForwardLOE = 2'b00;
    //=====b j=====
    ForwardALD = 2'b00;
    if(RsE != 0) begin
        if(RsE == WriteRegM & RegWriteM)begin
            ForwardAE = 2'b10;
        end
        else if(RsE == WriteRegW & RegWriteW)begin
            ForwardAE = 2'b01;
        end
    end
    if(RtE != 0) begin
        if(RtE == WriteRegM & RegWriteM)begin
            ForwardBE = 2'b10;
        end
        else if(RtE == WriteRegW & RegWriteW)begin
            ForwardBE = 2'b01;
        end
    end
    //add datamove inst oprand
    //forwarding HI
    if(DatatoRegE == 2'b10 & HIWriteM == 1'b1)begin
        ForwardHIE = 2'b01;
    end
    else if(DatatoRegE == 2'b10 & HIWriteW == 1'b1)begin
        ForwardHIE = 2'b10;
    end
    //forwarding LO
    if(DatatoRegE == 2'b01 & LOWriteM == 1'b1)begin
        ForwardLOE = 2'b01;
    end
    else if(DatatoRegE == 2'b01 & LOWriteW == 1'b1)begin
        ForwardLOE = 2'b10;
    end
    //------------------------
    //forwarding AL
    if(JrD == 1'b1 & JalE | BalE == 1'b1) begin
        ForwardALD = 2'b01;
    end
    else if(JrD == 1'b1 & JalM | BalM == 1'b1) begin
        ForwardALD = 2'b10;
    end
end

//stalls
assign LwStallD = DatatoRegE[1:1] & DatatoRegE[0:0] & (RtE == RsD | RtE == RtD);
assign BranchStallD = BranchD & 
        (RegWriteE & (WriteRegE == RsD | WriteRegE == RtD) |
         DatatoRegM[1:1] & DatatoRegM[0:0] & (WriteRegE == RsD | WriteRegE == RtD));
assign DivStall = StartDivE & ~DivReadyE;

assign StallD = LwStallD | BranchStallD | DivStall;
assign StallF = StallD;
assign StallE = DivStall;

assign FlushE = LwStallD | BranchStallD;

endmodule