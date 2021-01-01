//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  div
// File:    div.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ����ģ��
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.vh"

module div(

	input	wire	clk,
	input wire		rst,
	
	input wire   signed_div_i,// 这个是判断是不是符号操作�?
	input wire[31:0] opdata1_i, //操作�?1
	input wire[31:0] opdata2_i, //操作�?2
	input wire start_i, //这个是状态信�?
	input wire annul_i, //
	
	output reg[63:0] result_o, //结果输出信号
	output reg	ready_o //这个也是状�?�信号，当除法结束时，就返回DivResultReady
);

	wire[32:0] div_temp;
	reg[5:0] cnt; //这里是循环的计数器，用于记录除法已经进行了多少个周期
	reg[64:0] dividend;
	reg[1:0] state;
	reg[31:0] divisor;	 
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	
	always @ (posedge clk) begin

		if (rst == 1'b1) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin

		  	case (state)

				2'b00:begin               //DivFree״̬
					if(start_i == 1'b1 && annul_i == 1'b0) begin
						if(opdata2_i == `ZeroWord) begin
							state <= `DivByZero; //这里应该是除0状�??
						end else begin
							state <= `DivOn;
							cnt <= 6'b000000;
							if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
								temp_op1 = ~opdata1_i + 1;
							end else begin
								temp_op1 = opdata1_i;
							end
							if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
								temp_op2 = ~opdata2_i + 1;
							end else begin
								temp_op2 = opdata2_i;
							end
							dividend <= {`ZeroWord,`ZeroWord};
							dividend[32:1] <= temp_op1;
							divisor <= temp_op2;
						end

					end else begin
							ready_o <= `DivResultNotReady;
							result_o <= {`ZeroWord,`ZeroWord};
					end          	
					
				end

				2'b11:	begin               //DivByZero״̬
         			dividend <= {`ZeroWord,`ZeroWord};
         			state <= `DivEnd;		 		
		  		end

				2'b01:begin               //DivOn״̬
		  			if(annul_i == 1'b0) begin
		  				if(cnt != 6'b100000) begin
               				if(div_temp[32] == 1'b1) begin
                 				 dividend <= {dividend[63:0] , 1'b0};
               				end else begin
                  				dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
               				end
               				cnt <= cnt + 1;
             			end else begin
               				if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                  				dividend[31:0] <= (~dividend[31:0] + 1);
               				end
               				if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin              
                  				dividend[64:33] <= (~dividend[64:33] + 1);
              				end
               				state <= `DivEnd;
               				cnt <= 6'b000000;            	
             			end
		  			end else begin
		  				state <= `DivFree;
		  			end	
		  		end

				2'b10:begin               //DivEnd״̬
        			result_o <= {dividend[64:33], dividend[31:0]};  
          			ready_o <= `DivResultReady;
					if(start_i == 1'b0) begin //如果是stop的话就会重置
						state <= `DivFree;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};       	
					end		  
		  		end

			endcase
		end
	end

endmodule