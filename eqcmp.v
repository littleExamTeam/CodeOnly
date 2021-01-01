`timescale 1ns / 1ps
`include "defines.vh"
module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output wire y //1'b1 转移
    );

	reg isTran;
	
	assign y = isTran;

	always @(*)
	begin
		case(op)
			`EXE_BEQ: begin 
				if(a == b)begin
					isTran <= 1'b1;
				end else begin
					isTran <= 1'b0;
				end
			end

			`EXE_BNE:begin
				if(a == b)begin
					isTran <= 1'b0;
				end else begin
					isTran <= 1'b1;
				end
			end

			`EXE_BGEZ:begin
				if(a > 0 || a == 0)begin
					isTran <= 1'b1;
				end else begin
					isTran <= 1'b0;
				end
			end

			`EXE_BGTZ:begin
				if(a > 0)begin
					isTran <= 1'b1;
				end else begin
					isTran <= 1'b0;
				end
			end

			`EXE_BLEZ:begin
				if(a < 0 || a == 0)begin
					isTran <= 1'b1;
				end else begin
					isTran <= 1'b0;
				end
			end

			`EXE_BLTZ:begin
				if(a < 0)begin
					isTran <= 1'b1;
				end else begin
					isTran <= 1'b0;
				end
			end

			`EXE_BGEZAL:begin
				if(rt == 5'b10001)begin

					if(a > 0 || a == 0)begin
						isTran <= 1'b1;
					end else begin
						isTran <= 1'b0;
					end

				end else if(rt == 5'b10000) begin

					if(a < 0)begin
						isTran <= 1'b1;
					end else begin
						isTran <= 1'b0;
					end
					
				end
			end

		endcase
	end


endmodule