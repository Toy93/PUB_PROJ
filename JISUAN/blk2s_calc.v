/*************************************************************************
    # File Name: blk2s_calc.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:28:26 AM EDT
    # Last Modified:2022-04-16 08:44
    # Update Count:38
*************************************************************************/
module BLK2S_CALC#(
	parameter PASSWD_LEN	= 80,
	parameter KDF_BUF_SIZE	= 256,
	parameter INPUT_SIZE	= 64,
	parameter KEY_SIZE		= 32
)(
	input							clk			,
	input							rst_n		,

	//interface with AB_CPY
	input							in_vld		,
	output							in_rdy		,
	input [(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]	a_in		,
	input [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	b_in		,
	input [7:0]						buf_ptr_in	,
	input [PASSWD_LEN*8 - 1:0]		password  ,

	//interface with OUT_CALC
	output							out_vld		,
	input							out_rdy		,
	output [(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]	a_out		,
	output [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	b_out		,
	output [7:0]					buf_ptr_out,
	output [PASSWD_LEN*8 - 1:0]		password_o
);
//parameter define
localparam OUTPUT_SIZE	= 32;

//signal define
wire									out_vld0	;
wire									out_rdy0	;
wire[INPUT_SIZE*8 - 1:0]				prf_input	;
wire[KEY_SIZE*8 - 1:0]					prf_key		;
wire[OUTPUT_SIZE*8 -1:0]				prf_output	;

wire in_vld1;
wire in_rdy1;
wire post_in_vld	;
wire post_in_rdy	;
wire[OUTPUT_SIZE*8-1:0]post_prf_output;
wire [7:0]buf_ptr;
//instant module
BLK2S_PRE#(
	.PASSWD_LEN		(PASSWD_LEN),
	.KDF_BUF_SIZE	(KDF_BUF_SIZE),
	.INPUT_SIZE		(INPUT_SIZE	 ),
	.KEY_SIZE		(KEY_SIZE	 ),
	.OUTPUT_SIZE	(OUTPUT_SIZE )
)U_BLK2S_PRE(
	.clk			(clk  ),
	.rst_n			(rst_n),

	//interface with previous module
	.in_vld0		(in_vld	  ),
	.in_rdy0		(in_rdy	  ),
	.a_in			(a_in	  ),
	.b_in			(b_in	  ),
	.buf_ptr_in0	(buf_ptr_in),
	.password		(password  ),

	//interface with BLK2S
	.out_vld0		(out_vld0  ),
	.out_rdy0		(out_rdy0  ),
	.prf_input		(prf_input ),
	.prf_key		(prf_key   ),
	.prf_output		(prf_output),

	//interface with BLK2S_POST
	.in_vld1		(in_vld1),
	.in_rdy1		(in_rdy1),
	.buf_ptr_in1	(buf_ptr),

	//interface with next module
	.out_vld1		(out_vld),
	.out_rdy1		(out_rdy),
	.a_out			(a_out	),
	.b_out			(b_out	),
	.password_o		(password_o)
);

BLK2S#(
	.INPUT_SIZE  (INPUT_SIZE ),
	.KEY_SIZE	 (KEY_SIZE	 ),
	.OUTPUT_SIZE (OUTPUT_SIZE)
)U_BLK2S(
	.clk			(clk  ),
	.rst_n			(rst_n),

	//interface with BLK2S_PRE
	.in_vld		(out_vld0	),
	.in_rdy		(out_rdy0	),
	.prf_input	(prf_input	),
	.prf_key	(prf_key    ),
	.prf_output0(prf_output	),

	//interface with BLK2S_POST
	.out_vld		(post_in_vld),
	.out_rdy		(post_in_rdy),
	.prf_output1	(post_prf_output)
);

BLK2S_POST#(
	.OUTPUT_SIZE(OUTPUT_SIZE)
)U_BLK2S_POST(
	.clk	(clk  ),
	.rst_n	(rst_n),

	//interface with BLK2S
	.in_vld		(post_in_vld),
	.in_rdy		(post_in_rdy),
	.prf_output	(post_prf_output),

	//nterface with BLK2S_PRE
	.out_vld	(in_vld1),
	.out_rdy	(in_rdy1),
	.buf_ptr	(buf_ptr)
);

assign buf_ptr_out = buf_ptr;
endmodule
