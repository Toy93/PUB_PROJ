// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/04/11 22:37
// Last Modified : 2024/04/14 11:14
// File Name     : division_float16.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/11   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module DIVISION_FLOAT16#(
	parameter DATA_WIDTH = 16
)(
	input clk                      , 
	input rst_n                    , 
	input in_vld                   , 
	input [DATA_WIDTH-1:0]dividend , 
	input [DATA_WIDTH-1:0]divider  , 
	output reg out_vld             , 
	output reg [DATA_WIDTH-1:0]result
);
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
	
	wire       signa                           ;
    wire       signb                           ;
    wire       signc                           ;
    wire  [4:0]expa                            ;
    wire  [4:0]expb                            ;
    wire  [10:0]fraca                          ;
    wire  [10:0]fracb                          ;
    wire  [10:0]fracc                          ;
    wire signed[5:0]quotient                   ;
	wire [5:0]quotient_add15;
	wire [5:0]quotient_sub1;
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			out_vld <= 1'b0;
		end
		else begin
			out_vld <= in_vld;
		end
	end
	
	assign {signa,expa,fraca[9:0]} = dividend;
	assign {signb,expb,fracb[9:0]} = divider;

	assign fraca[10]=1;
	assign fracb[10]=1;
	assign signc = signa^signb;
	assign quotient = {1'b0,expa}-{1'b0,expb};
	assign quotient_add15 = quotient+6'h0f;
	assign quotient_sub1 = quotient_add15 - 6'h01;
	assign fracc = fraca/fracb;

	always@(posedge clk)begin
		if(in_vld)begin
			if(dividend == 0 || divider == 0)begin
				if(dividend == 0)begin
					result <= dividend;
				end
				else begin
					result <= 16'hffff;
				end
			end
			else begin
				if(fracc[10])begin
					result <= {signc,quotient_add15[4:0],fracc[9:0]};
				end
				else begin
					result <= {signc,quotient_sub1[4:0],fracc[9:0]};
				end
			end
		end
	end

endmodule
//Local Variables:
//verilog-library-directories:(".")
//verilog-library-directories-recursive:1
//End:
