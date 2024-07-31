/*************************************************************************
    # File Name: quarter_cha.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Tue 12 Apr 2022 08:14:08 PM EDT
    # Last Modified:2022-04-14 11:57
    # Update Count:15
*************************************************************************/
module QUARTER_CHA(
	input [31:0]a_in,
	input [31:0]b_in,
	input [31:0]c_in,
	input [31:0]d_in,

	output [31:0]a_out,
	output [31:0]b_out,
	output [31:0]c_out,
	output [31:0]d_out
);

wire [31:0]a_in0;
wire [31:0]b_in0;
wire [31:0]c_in0;
wire [31:0]d_in0;
wire [31:0]t0;
wire [31:0]t1;
wire [31:0]t2;
wire [31:0]t3;
assign a_in0 = a_in + b_in;
assign t0 = a_in0^d_in;
assign d_in0 = {t0[15:0],t0[31:16]};
assign c_in0 = d_in0+c_in;
assign t1 = b_in^c_in0;
assign b_in0 = {t1[19:0],t1[31:20]};
assign a_out = a_in0+b_in0;
assign t2 = a_out^d_in0;
assign d_out = {t2[23:0],t2[31:24]};
assign c_out = d_out+c_in0;
assign t3 = b_in0^c_out;
assign b_out = {t3[24:0],t3[31:25]};
endmodule
