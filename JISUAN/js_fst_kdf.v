/*************************************************************************
    # File Name: js_fst_kdf.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:16:36 AM EDT
    # Last Modified:2022-04-16 09:59
    # Update Count:27
*************************************************************************/
module JS_FST_KDF#(
	parameter PASSWD_LEN	= 80,
	parameter SALT_LEN		= 80,
	parameter N				= 32,
	parameter OUTPUT_LEN	= 32
)(
	input						clk       ,
	input						rst_n     ,

	//interface with TB
	input						in_vld    ,
	output						in_rdy    ,
	input [PASSWD_LEN*8 - 1:0]	password  ,
	input [SALT_LEN*8 - 1:0]	salt      ,
	
	//interface with DBL_MIX0 and DBL_MIX1
	output						out_vld   ,
	input						out_rdy   ,
	output [OUTPUT_LEN*8 - 1:0]	data_out  ,
	output [PASSWD_LEN*8 - 1:0]	password_o
);
//parameter define
localparam KDF_BUF_SIZE = 256;
localparam INPUT_SIZE   = 64;
localparam KEY_SIZE     = 32;

//signal define
wire									 calc_all_in_vld		;
wire									 calc_all_in_rdy		;
wire[(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]	 calc_all_a_in			;
wire[(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	 calc_all_b_in			;
wire[7:0]								 calc_all_buf_ptr_in	;

wire									 calc_all_out_vld	 ;
wire									 calc_all_out_rdy	 ;
wire [(KDF_BUF_SIZE+INPUT_SIZE)*8 -1:0]	 calc_all_a_out		 ;
wire [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	 calc_all_b_out		 ;
wire [7:0]								 calc_all_buf_ptr_out;

wire[PASSWD_LEN*8 - 1:0]				 password_o_ab_cpy	 ;
wire[PASSWD_LEN*8 - 1:0]				 password_o_calc_all ;
//instant modules 
AB_CPY #(
	.PASSWD_LEN		(PASSWD_LEN  ),
	.SALT_LEN		(SALT_LEN    ),
	.KDF_BUF_SIZE	(KDF_BUF_SIZE),
	.INPUT_SIZE		(INPUT_SIZE	 ),
	.KEY_SIZE		(KEY_SIZE	 )
)U_AB_CPY (
	.clk		(clk  ),
	.rst_n		(rst_n),

	//interface with TB
	.in_vld		(in_vld  ),
	.in_rdy		(in_rdy  ),
	.password	(password),
	.salt		(salt    ),
	
	//interface with BLK2S_CALC_ALL
	.out_vld	(calc_all_in_vld),
	.out_rdy	(calc_all_in_rdy),
	.a			(calc_all_a_in	),
	.b			(calc_all_b_in	),
	.password_o (password_o_ab_cpy)
);

BLK2S_CALC_ALL#(
	.PASSWD_LEN		(PASSWD_LEN  ),
	.KDF_BUF_SIZE(KDF_BUF_SIZE),
	.INPUT_SIZE	 (INPUT_SIZE),
	.KEY_SIZE	 (KEY_SIZE),
	.N			 (N)
)U_BLK2S_CALC_ALL(
	.clk		(clk  ),
	.rst_n		(rst_n),

	//interface with AB_CPY
	.in_vld		(calc_all_in_vld),
	.in_rdy		(calc_all_in_rdy),
	.a_in		(calc_all_a_in	),
	.b_in		(calc_all_b_in	),
	.buf_ptr_in (8'd0),
	.password   (password_o_ab_cpy),

	//interface with OUT_CALC
	.out_vld	(calc_all_out_vld	 ),
	.out_rdy	(calc_all_out_rdy	 ),
	.a_out		(calc_all_a_out		 ),
	.b_out		(calc_all_b_out		 ),
	.buf_ptr_out(calc_all_buf_ptr_out),
	.password_o (password_o_calc_all )
);

OUT_CALC#(
	.PASSWD_LEN		(PASSWD_LEN  ),
	.KDF_BUF_SIZE	(KDF_BUF_SIZE	),
	.INPUT_SIZE		(INPUT_SIZE		),
	.KEY_SIZE		(KEY_SIZE		),
	.OUTPUT_LEN		(OUTPUT_LEN)
)U_OUT_CALC(
	.clk		(clk  ),
	.rst_n		(rst_n),

	//interface with BLK2S_CALC_ALL
	.in_vld			(calc_all_out_vld	 ),
	.in_rdy			(calc_all_out_rdy	 ),
	.a_in			(calc_all_a_out		 ),
	.b_in			(calc_all_b_out		 ),
	.buf_ptr_in		(calc_all_buf_ptr_out),
	.password		(password_o_calc_all ),

	//interface with DBL_MIX0 and DBL_MIX1
	.out_vld		(out_vld ),
	.out_rdy		(out_rdy ),
	.xo				(data_out),
	.password_o		(password_o)
);
endmodule
