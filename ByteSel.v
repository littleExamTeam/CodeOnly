`timescale 1ns / 1ps
`include "defines.vh"

module ByteSel(
    input wire [31:0] addra,
    input wire [7:0] ALUControl,
    output wire [3:0] sel
);

reg [3:0] select;
assign sel = select;

always @(*)
begin
    case(ALUControl)
        `EXE_LB_OP: select <= 4'b0000;
        `EXE_LBU_OP: select <= 4'b0000;
        `EXE_LH_OP: select <= 4'b0000;
        `EXE_LHU_OP: select <= 4'b0000;
        `EXE_LW_OP: select <= 4'b0000;
        `EXE_SB_OP: begin
            case(addra[1:0])
                2'b00: select <= 4'b1000;
                2'b01: select <= 4'b0100;
                2'b10: select <= 4'b0010;
                2'b11: select <= 4'b0001;
            endcase
        end

        `EXE_SH_OP: begin
            case(addra[1:0])
                2'b00: select <= 4'b1100;
                2'b10: select <= 4'b0011;
            endcase
        end
        `EXE_SW_OP: select <= 4'b1111;

        default: select <= 4'b0000;
    endcase
end

endmodule