// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:18
// Last Modified : 2024/04/20 12:49
// File Name     : regs.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module REGS(
	input clk,
	input rst_n,
	input write,
	input [4:0]wd,
	input [4:0]rd,
	input [4:0]rs,
	input [7:0]wdata,
	
	output [7:0]rd_data,
	output [7:0]rs_data,

	output [7:0]led
);
	
	integer i;
	parameter REG1_X1 = 5'd1;
	parameter REG2_Y1 = 5'd2;
	parameter REG3    = 5'd3;
	parameter REG4    = 5'd4;
	parameter REG5_A11= 5'd5;
	parameter REG6_A12= 5'd6;
	parameter REG7_A21= 5'd7;
	parameter REG8_A22= 5'd8;
	parameter REG9_B1 = 5'd9;
	parameter REG10_B2= 5'd10;
	
	reg [7:0]register[31:0];
	/*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here
    //End of automatic wire
    //End of automatic define
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			for(i = 0; i < 32; i = i + 1)begin
				register[i] <= 8'd0;
			end
		end
		else if(write)begin
			register[wd] <= wdata;
		end
	end

	assign rs_data = register[rs];
	assign rd_data = register[rd];
	assign led = register[3];
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
