/*************************************************************************
    # File Name: blk2s.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:28:53 AM EDT
    # Last Modified:2022-04-06 11:31
    # Update Count:18
*************************************************************************/
module BLK2S#(
	parameter INPUT_SIZE = 64,
	parameter KEY_SIZE = 32,
	parameter OUTPUT_SIZE = 32
)(
	input						clk			,
	input						rst_n		,

	//interface with BLK2S_PRE
	input						in_vld		,
	output						in_rdy		,
	input  [INPUT_SIZE*8 - 1:0]	prf_input	,
	input  [KEY_SIZE*8 - 1:0]	prf_key		,
	output [OUTPUT_SIZE*8 - 1:0]prf_output0	,

	//interface with BLK2S_POST
	output						out_vld		,
	input						out_rdy		,
	output [OUTPUT_SIZE*8 - 1:0]prf_output1
);

wire  			hcalc_in_vld;
wire[32*2 -1:0]	hcalc_t		;
wire[32*2 -1:0]	hcalc_f		;
wire[32*16 -1:0]hcalc_m		;
wire[32*8 -1:0]	hcalc_hi	;
wire			hcalc_out_vld;
wire[32*8 -1:0]	hcalc_ho	;	

BLK2S_CTRL#(
	.INPUT_SIZE  (INPUT_SIZE ),
	.KEY_SIZE    (KEY_SIZE   ),
	.OUTPUT_SIZE (OUTPUT_SIZE)
)U_BLK2S_CTRL(
	.clk		(clk  ),
	.rst_n		(rst_n),

	//interface with BLK2S_PRE
	.in_vld0	(in_vld   ),
	.in_rdy0	(in_rdy   ),
	.prf_input	(prf_input),
	.prf_key	(prf_key  ),

	//interface with HCALC
	.out_vld0	(hcalc_in_vld),
	.t			(hcalc_t	),
	.f			(hcalc_f	),
	.m			(hcalc_m	),
	.h0_o		(hcalc_hi	),
	.in_vld1    (hcalc_out_vld),
	.hi			(hcalc_ho	),

	//interface with BLK2S_POST
	.out_vld1	(out_vld    ),
	.out_rdy1	(out_rdy    ),
	.h1_o		(prf_output1)
);

assign prf_output0 = prf_output1;

H_CALC U_H_ALC(
	.clk		(clk  ),
	.rst_n		(rst_n),
	
	//interface with BLK2S_CTRL
	.in_vld		(hcalc_in_vld ),
	.t			(hcalc_t	  ),
	.f			(hcalc_f	  ),
	.m			(hcalc_m	  ),
	.hi			(hcalc_hi	  ),
	.out_vld	(hcalc_out_vld),
	.ho			(hcalc_ho	  )
);

endmodule
