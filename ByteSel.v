`timescale 1ns / 1ps
`include "defines.vh"

module ByteSel(
    input wire [31:0] addra,
    input wire [31:0] data,
    input wire [7:0] ALUControl,
    output wire [3:0] sel,
    output wire [31:0] dataOut
);

reg [3:0] select;
reg [3:0] dataout;
assign sel = select;
assign dataOut = dataout;

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
                2'b00: begin 
                    select <= 4'b1000;
                    dataout <= data << 2'd24;
                end
                2'b01: begin 
                    select <= 4'b0100;
                    dataout <= data << 2'd16;
                end
                2'b10: begin 
                    select <= 4'b0010;
                    dataout <= data << 1'd8;
                end
                2'b11: begin 
                    select <= 4'b0001;
                end
            endcase
        end

        `EXE_SH_OP: begin
            case(addra[1:0])
                2'b00: begin 
                    select <= 4'b1100;
                    dataout <= data << 2'd16;
                end
                2'b10: select <= 4'b0011;
            endcase
        end
        `EXE_SW_OP: select <= 4'b1111;

        default: select <= 4'b0000;
    endcase
end

endmodule