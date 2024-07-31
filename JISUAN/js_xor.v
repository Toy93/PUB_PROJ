/*************************************************************************
    # File Name: js_xor.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:33:29 AM EDT
    # Last Modified:2022-04-16 10:14
    # Update Count:5
*************************************************************************/
module JS_XOR #(
	parameter BLOCK_SIZE = 256
)(
	input	[BLOCK_SIZE*8 - 1:0]x_in,
	input	[BLOCK_SIZE*8 - 1:0]z_in,
	output	[BLOCK_SIZE*8 - 1:0]x_out
);
assign x_out = x_in^z_in;
endmodule
