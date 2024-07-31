// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:29
// Last Modified : 2024/05/16 22:03
// File Name     : alu.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module ALU#(
	parameter ADD = 4'd0,
	parameter SUB = 4'd1,
	parameter MUL = 4'd2,
	parameter DIV = 4'd3,
	parameter LDI = 4'd4,
	parameter BNE = 4'd5,
	parameter BEQ = 4'd6,
	parameter MOV = 4'd7,
	parameter NA  = 4'd15
)(
	input [3:0]func,
	input signed [7:0]a,
	input signed [7:0]b,

	output reg [3:0]alu_flags,
	output reg [7:0]result
);
	/*autodef*/

	always @(*)begin
		case(func)
			ADD:result = a+b;
			SUB:result = a-b;
			MUL:result = a*b;
			DIV:begin
				if(b==0)begin
					result = 8'd0;
				end
				else begin
					result = a/b;
				end
			end
			LDI:result = b;
			MOV:result = b;
			default:result = 8'd0;
		endcase
	end

	always @(*)begin
		case(func)
			BNE:begin
				if(a != b)begin
					alu_flags = 4'd0;
				end
				else begin
					alu_flags = 4'd1;
				end
			end
			BEQ:begin
				if(a == b)begin
					alu_flags = 4'd0;
				end
				else begin
					alu_flags = 4'd1;
				end
			end
			default:alu_flags = 4'd0;
		endcase
	end
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
