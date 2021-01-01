`timescale 1ns / 1ps
`include "defines.vh"

module main_dec(
    input wire [5:0] op,funct,
    output wire jump, regwrite, regdst, 
    output wire alusrcA,
    output wire [1:0] alusrcB, //这里修改成两位是为了选择操作数，0位扩�??
    output wire branch, memwrite, memtoreg

);

reg [8:0] signals;

//assign {jump, regwrite, regdst, alusrcB[1:0], branch, memwrite, memtoreg} = signals;
assign {regwrite, memtoreg, memwrite, alusrcA ,{alusrcB[1:1]}, {alusrcB[0:0]}, regdst, jump, branch} = signals;
//100  00
// `define EXE_NOP			6'b000000
// `define EXE_AND 		6'b100100
// `define EXE_OR 			6'b100101
// `define EXE_XOR 		6'b100110
// `define EXE_NOR			6'b100111
// `define EXE_ANDI		6'b001100
// `define EXE_ORI			6'b001101
// `define EXE_XORI		6'b001110
// `define EXE_LUI			6'b001111
always @(op) begin
    case(op)
    //     `EXE_NOP: begin    //R-type
    //     signals <= 8'b011 000;
    //     aluop_reg <= 2'b10;
    // end
        6'b000000: begin    //lw
        case(funct)
            `EXE_SLL:signals <= 9'b1_0_0_1_00_1_0_0;
            `EXE_SRA:signals <= 9'b1_0_0_1_00_1_0_0;
            `EXE_SRL:signals <= 9'b1_0_0_1_00_1_0_0;
            default: signals <= 9'b1_0_0_0_00_1_0_0;
            
        endcase
    
    end
        `EXE_ANDI:signals <= 9'b100010000;
        `EXE_XORI:signals <= 9'b100010000;
        `EXE_ORI:signals <= 9'b100010000;
        `EXE_LUI:signals <= 9'b100010000;
        default:signals <= 9'b000000000;
    endcase
end

endmodule

module controller(
    input wire [5:0] Op, Funct,
    output wire Jump, RegWrite, RegDst,
    output wire ALUSrcA, 
    output wire [1:0] ALUSrcB, 
    output wire Branch, MemWrite, MemtoReg,
    output wire [8:0] ALUContr 
);


main_dec main_dec(
    .op(Op),
    .funct(Funct),
    .jump(Jump),
    .regwrite(RegWrite),
    .regdst(RegDst),
    .alusrcA(ALUSrcA),
    .alusrcB(ALUSrcB),
    .branch(Branch),
    .memwrite(MemWrite),
    .memtoreg(MemtoReg)
);

aludec aludec(
    .Funct(Funct),
    .Op(Op),
    .ALUControl(ALUContr)
);

endmodule
