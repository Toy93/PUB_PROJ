// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:16
// Last Modified : 2024/04/17 22:30
// File Name     : pc.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module PC(
	input clk,
	input rst_n,

	input [7:0]addr_n,

	output reg [7:0]addr_c
);
	/*parameter*/
	/*autodef*/
	
	always @(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			addr_c <= 8'd0;
		end
		else begin
			addr_c <= addr_n;
		end
	end
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
