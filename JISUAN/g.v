/*************************************************************************
    # File Name: g.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:30:10 AM EDT
    # Last Modified:2022-04-06 11:37
    # Update Count:15
*************************************************************************/
module G(
	input [31:0]a_i,
	input [31:0]b_i,
	input [31:0]c_i,
	input [31:0]d_i,
	input [31:0]para0,
	input [31:0]para1,

	output [31:0]a_o,
	output [31:0]b_o,
	output [31:0]c_o,
	output [31:0]d_o
);

wire [31:0]a_temp;
wire [31:0]b_temp;
wire [31:0]c_temp;
wire [31:0]d_temp;
wire [31:0]ad_xor_temp0;
wire [31:0]bc_xor_temp0;
wire [31:0]ad_xor_temp1;
wire [31:0]bc_xor_temp1;

assign a_temp = a_i + b_i + para0;
assign ad_xor_temp0 = d_i^a_temp;
assign d_temp = {ad_xor_temp0[15:0],ad_xor_temp0[31:16]};
assign c_temp = c_i + d_temp;
assign bc_xor_temp0 = b_i^c_temp;
assign b_temp = {bc_xor_temp0[11:0],bc_xor_temp0[31:12]};

assign a_o = a_temp + b_temp + para1;
assign ad_xor_temp1 = d_temp^a_o;
assign d_o = {ad_xor_temp1[7:0],ad_xor_temp1[31:8]};
assign c_o = c_temp + d_o;
assign bc_xor_temp1 = b_temp^c_o;
assign b_o = {bc_xor_temp1[6:0],bc_xor_temp1[31:7]};
endmodule
