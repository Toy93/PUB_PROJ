/*************************************************************************
    # File Name: quarter_sha.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Tue 12 Apr 2022 08:14:08 PM EDT
    # Last Modified:2022-04-14 12:06
    # Update Count:13
*************************************************************************/
module QUARTER_SHA(
	input [31:0]a_in,
	input [31:0]b_in,
	input [31:0]c_in,
	input [31:0]d_in,

	output [31:0]a_out,
	output [31:0]b_out,
	output [31:0]c_out,
	output [31:0]d_out
);
wire [31:0]t0;
wire [31:0]t1;
wire [31:0]t2;
wire [31:0]t3;
wire [31:0]t4;
wire [31:0]t5;
wire [31:0]t6;
wire [31:0]t7;
assign t0 = a_in + d_in;
assign t1 = {t0[24:0],t0[31:25]};
assign b_out = t1^b_in;

assign t2 = a_in+b_out;
assign t3 = {t2[22:0],t2[31:23]};
assign c_out = t3^c_in;

assign t4 = c_out + b_out;
assign t5 = {t4[18:0],t4[31:19]};
assign d_out = t5^d_in;

assign t6 = c_out + d_out;
assign t7 = {t6[13:0],t6[31:14]};
assign a_out = t7^a_in;
endmodule
