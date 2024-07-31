/*************************************************************************
    # File Name: jisuan.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:07:30 AM EDT
    # Last Modified:2022-04-16 09:55
    # Update Count:16
*************************************************************************/
module JISUAN #(
	parameter PASSWD_LEN = 80,
	parameter OUTPUT_LEN = 32
)(
	input							clk		,
	input							rst_n	,

	//interface with TB
	input							in_vld	,
	output reg 						in_rdy	,
	input							in_sel  ,//0:password[39*8 -1:0] 1:[80*8-1:40*8]
	input [(PASSWD_LEN/2)*8 - 1:0]	password,
	
	output							out_vld	,
	input							out_rdy	,
	output [OUTPUT_LEN*8 - 1:0]		password_o
);
//parameter define
localparam PASSWD_LEN0	= PASSWD_LEN;
localparam SALT_LEN0	= 80;
localparam OUTPUT_LEN0	= 256;

localparam BLOCK_SIZE	= 256;

localparam PASSWD_LEN1	= PASSWD_LEN;
localparam SALT_LEN1	= 256;
localparam OUTPUT_LEN1	= OUTPUT_LEN;
//signal define 
wire						out_vld_kdf0;
wire						out_rdy_kdf0;
wire  [OUTPUT_LEN0*8 - 1:0]	data_out_kdf0;
wire  [PASSWD_LEN0*8 - 1:0] password_o_kdf0;
wire [BLOCK_SIZE*8 - 1:0]	x_out_mix	;
wire [BLOCK_SIZE*8 - 1:0]	z_out_mix	;
wire 					 	out_vld_mix;
wire 					 	out_rdy_mix;	
wire [BLOCK_SIZE*8 - 1:0]	x_out_xor;
wire [PASSWD_LEN*8 - 1:0]	password_o_mix;
reg [PASSWD_LEN*8 -1:0]password_mem;
reg password_vld;
wire password_rdy;

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		if(~in_sel)begin
			password_mem[40*8-1:0] <= password;
		end
		else begin
			password_mem[80*8-1:40*8] <= password;
		end
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_rdy <= 1'b1;
	end
	else if(in_vld&in_sel&in_rdy)begin
		in_rdy <= 1'b0;
	end
	else if(password_vld&password_rdy)begin
		in_rdy <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		password_vld <= 1'b0;
	end
	else if(in_vld&in_rdy&in_sel)begin
		password_vld <= 1'b1;
	end
	else if(password_vld&password_rdy)begin
		password_vld <= 1'b0;
	end
end
//instant JS_FST_KDF0
JS_FST_KDF#(
	.PASSWD_LEN		(PASSWD_LEN0),
	.SALT_LEN		(SALT_LEN0),
	.N				(32),
	.OUTPUT_LEN		(OUTPUT_LEN0)
)U_JS_FST_KDF0(
	.clk		(clk  ),
	.rst_n		(rst_n),

	//interface with TB
	.in_vld		(password_vld),
	.in_rdy		(password_rdy),
	.password	(password_mem),
	.salt		(password_mem),
	
	//interface with DBL_MIX0 and DBL_MIX
	.out_vld	(out_vld_kdf0),
	.out_rdy	(out_rdy_kdf0),
	.data_out	(data_out_kdf0),
	.password_o	(password_o_kdf0)
);

//instant DBL_MIX
DBLMIX#(
	.PASSWD_LEN(PASSWD_LEN),
	.BLOCK_SIZE(BLOCK_SIZE)	
)U_DBLMIX(
	.clk	(clk  ),
	.rst_n	(rst_n),	

//interface with JS_FST_KDF0
	.in_vld	(out_vld_kdf0),
	.in_rdy	(out_rdy_kdf0),
	.x_in	(data_out_kdf0),
	.password(password_o_kdf0),
	
//interface withJS_XOR
	.x_out	(x_out_mix  ),
	.z_out	(z_out_mix  ),
	.out_vld(out_vld_mix),
	.out_rdy(out_rdy_mix),
	.password_o(password_o_mix)
);

//instant JS_XOR
JS_XOR #(
	.BLOCK_SIZE(BLOCK_SIZE)
)U_JS_XOR (
	.x_in (x_out_mix),
	.z_in (z_out_mix),
	.x_out(x_out_xor)
);

//instant JS_FST_KDF1
JS_FST_KDF#(
	.PASSWD_LEN	(PASSWD_LEN1),
	.SALT_LEN	(SALT_LEN1  ),
	.N			(32         ),
	.OUTPUT_LEN	(OUTPUT_LEN1)
)U_JS_FST_KDF1(
	.clk	 (clk  ),
	.rst_n	 (rst_n),

	//interface with TB
	.in_vld  (out_vld_mix  ),
	.in_rdy  (out_rdy_mix  ),
	.password(password_o_mix),
	.salt    (x_out_xor    ),
	
	//interface with DBL_MIX0 and DBL_MIX1
	.out_vld (out_vld	),
	.out_rdy (out_rdy	),
	.data_out(password_o),
	.password_o()
);
endmodule
