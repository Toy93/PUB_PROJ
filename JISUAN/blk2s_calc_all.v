/*************************************************************************
    # File Name: blk2s_calc_all.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:27:19 AM EDT
    # Last Modified:2022-04-16 12:11
    # Update Count:36
*************************************************************************/
module BLK2S_CALC_ALL#(
	parameter PASSWD_LEN	= 80,
	parameter KDF_BUF_SIZE	= 256,
	parameter INPUT_SIZE	= 64,
	parameter KEY_SIZE		= 32,
	parameter N				= 32
)(
	input									 clk		,
	input									 rst_n		,

	//interface with AB_CPY
	input									 in_vld		,
	output									 in_rdy		,
	input [(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]a_in		,
	input [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	 b_in		,
	input [7:0]								 buf_ptr_in ,
	input [PASSWD_LEN*8 - 1:0]				 password  ,

	//interface with OUT_CALC
	output									 out_vld	,
	input									 out_rdy	,
	output [(KDF_BUF_SIZE+INPUT_SIZE)*8 -1:0]a_out		,
	output [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0] b_out		,
	output [7:0]							 buf_ptr_out,
	output [PASSWD_LEN*8 - 1:0]				 password_o
);
wire in_vld_all[N:0];
wire in_rdy_all[N:0];
wire [(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]a_in_all[N:0];
wire [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]b_in_all[N:0];
wire [7:0]buf_ptr_in_all[N:0];
wire [PASSWD_LEN*8 - 1:0]password_all[N:0];
genvar I;

assign in_vld_all[0] = in_vld;
assign in_rdy = in_rdy_all[0];
assign a_in_all[0] = a_in;
assign b_in_all[0] = b_in;
assign buf_ptr_in_all[0]=buf_ptr_in;
assign password_all[0] =password;
assign out_vld = in_vld_all[N];
assign in_rdy_all[N] = out_rdy;
assign a_out = a_in_all[N];
assign b_out = b_in_all[N];
assign buf_ptr_out = buf_ptr_in_all[N];
assign password_o = password_all[N];
generate 
	for(I = 0; I < N ; I = I + 1)begin:BLK2S_CALC
		BLK2S_CALC #(
			.PASSWD_LEN	 (PASSWD_LEN),
			.KDF_BUF_SIZE(KDF_BUF_SIZE),
			.INPUT_SIZE	 (INPUT_SIZE),
			.KEY_SIZE	 (KEY_SIZE)
		)U_BLK2S_CALC(
			.clk			(clk  ),
			.rst_n			(rst_n),

			//interface with previous module
			.in_vld			(in_vld_all[I]	    ),
			.in_rdy			(in_rdy_all[I]	    ),
			.a_in			(a_in_all[I]	    ),
			.b_in			(b_in_all[I]	    ),
			.buf_ptr_in		(buf_ptr_in_all[I]  ),
			.password		(password_all[I]    ),

			//interface with next module
			.out_vld		(in_vld_all[I+1]    ),
			.out_rdy		(in_rdy_all[I+1]    ),
			.a_out			(a_in_all[I+1]	    ),
			.b_out			(b_in_all[I+1]	    ),
			.buf_ptr_out	(buf_ptr_in_all[I+1]),
			.password_o		(password_all[I+1]  )
		);
	end
endgenerate
endmodule
