/*************************************************************************
    # File Name: dblmix_calc.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Sat 09 Apr 2022 11:08:38 AM EDT
    # Last Modified:2022-04-16 22:43
    # Update Count:38
*************************************************************************/
module DBLMIX_CALC#(
	parameter BLOCK_SIZE = 256
)(
	input							clk,
	input							rst_n,
	//interface with BLK2S_CTRL
	input							in_vld	,	
	output							in_rdy	,	
	input	[BLOCK_SIZE*8 - 1:0]	x_in	,//sha	
	input	[BLOCK_SIZE*8 - 1:0]	z_in	,//cha	
	output reg						out_vld	,	
	input							out_rdy	,	
	output reg[BLOCK_SIZE*8 - 1:0]	x_out	,	
	output reg[BLOCK_SIZE*8 - 1:0]	z_out		
);
//parameter define
localparam SCRYPT_BLOCK_SIZE = 64;

//signal define
reg [BLOCK_SIZE*8 -1:0]x_in_buf0;
reg [BLOCK_SIZE*8 -1:0]z_in_buf0;
reg [BLOCK_SIZE*8 -1:0]x_in_buf1;
reg [BLOCK_SIZE*8 -1:0]z_in_buf1;
reg [BLOCK_SIZE*8 -1:0]x_in_buf2;
reg [BLOCK_SIZE*8 -1:0]z_in_buf2;
reg [BLOCK_SIZE*8 -1:0]x_in_buf3;
reg [BLOCK_SIZE*8 -1:0]z_in_buf3;

wire			 out_vld0  ;
wire			 out_rdy0  ;
wire [32*16 -1:0]x_out_cha0;
wire [32*16 -1:0]x_out_sha0;

wire			 out_vld1  ;
wire			 out_rdy1  ;
wire [32*16 -1:0]x_out_cha1;
wire [32*16 -1:0]x_out_sha1;

wire			  out_vld2  ;
wire			  out_rdy2  ;
wire [32*16 -1:0] x_out_cha2;
wire [32*16 -1:0] x_out_sha2;

wire			  out_vld3  ;
reg				  out_rdy3  ;
wire [32*16 -1:0] x_out_cha3;
wire [32*16 -1:0] x_out_sha3;
wire [32*16 -1:0] xor_cha_0_48 ;
wire [32*16 -1:0] xor_cha_16_0 ;
wire [32*16 -1:0] xor_cha_32_16;
wire [32*16 -1:0] xor_cha_48_32;
wire [32*16 -1:0] xor_sha_0_48 ;
wire [32*16 -1:0] xor_sha_16_0 ;
wire [32*16 -1:0] xor_sha_32_16;
wire [32*16 -1:0] xor_sha_48_32;

wire [32*16 -1:0] add_cha0 ;
wire [32*16 -1:0] add_cha16;
wire [32*16 -1:0] add_cha32;
wire [32*16 -1:0] add_cha48;
wire [32*16 -1:0] add_sha0 ;
wire [32*16 -1:0] add_sha16;
wire [32*16 -1:0] add_sha32;
wire [32*16 -1:0] add_sha48;

genvar I;
//main code
assign xor_cha_0_48 = z_in[32*0+:SCRYPT_BLOCK_SIZE*8]^z_in[32*48+:SCRYPT_BLOCK_SIZE*8];
assign xor_cha_16_0 = z_in_buf0[32*16+:SCRYPT_BLOCK_SIZE*8]^add_cha0;
assign xor_cha_32_16 = z_in_buf1[32*32+:SCRYPT_BLOCK_SIZE*8]^add_cha16;
assign xor_cha_48_32 = z_in_buf2[32*48+:SCRYPT_BLOCK_SIZE*8]^add_cha32;
assign xor_sha_0_48 = x_in[32*0+:SCRYPT_BLOCK_SIZE*8]^x_in[32*48+:SCRYPT_BLOCK_SIZE*8];
assign xor_sha_16_0 = x_in_buf0[32*16+:SCRYPT_BLOCK_SIZE*8]^add_sha0;
assign xor_sha_32_16 = x_in_buf1[32*32+:SCRYPT_BLOCK_SIZE*8]^add_sha16;
assign xor_sha_48_32 = x_in_buf2[32*48+:SCRYPT_BLOCK_SIZE*8]^add_sha32;
generate 
	for(I=0;I<16;I=I+1)begin:ADD
		assign add_cha0[32*I +:32] = x_out_cha0[32*I+:32]+z_in_buf0[32*0 +32*I+:32];
		assign add_cha16[32*I +:32] = x_out_cha1[32*I+:32]+z_in_buf1[32*16+32*I+:32];
		assign add_cha32[32*I +:32] = x_out_cha2[32*I+:32]+z_in_buf2[32*32+32*I+:32];
		assign add_cha48[32*I +:32] = x_out_cha3[32*I+:32]+z_in_buf3[32*48+32*I+:32];
		assign add_sha0[32*I +:32] = x_out_sha0[32*I+:32]+x_in_buf0[32*0 +32*I+:32];
		assign add_sha16[32*I +:32] = x_out_sha1[32*I+:32]+x_in_buf1[32*16+32*I+:32];
		assign add_sha32[32*I +:32] = x_out_sha2[32*I+:32]+x_in_buf2[32*32+32*I+:32];
		assign add_sha48[32*I +:32] = x_out_sha3[32*I+:32]+x_in_buf3[32*48+32*I+:32];
	end
endgenerate

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		z_in_buf0 <= {z_in[32*16+:32*48],xor_cha_0_48};
		x_in_buf0 <= {x_in[32*16+:32*48],xor_sha_0_48};
	end
end

always @(posedge clk)begin
	if(out_vld0&out_rdy0)begin
		z_in_buf1 <= {z_in_buf0[32*32+:32*32],xor_cha_16_0,add_cha0};
		x_in_buf1 <= {x_in_buf0[32*32+:32*32],xor_sha_16_0,add_sha0};
	end
end

always @(posedge clk)begin
	if(out_vld1&out_rdy1)begin
		z_in_buf2 <= {z_in_buf1[32*48+:32*16],xor_cha_32_16,add_cha16,z_in_buf1[32*0+:16*32]};
		x_in_buf2 <= {x_in_buf1[32*48+:32*16],xor_sha_32_16,add_sha16,x_in_buf1[32*0+:16*32]};
	end
end

always @(posedge clk)begin
	if(out_vld2&out_rdy2)begin
		z_in_buf3 <= {xor_cha_48_32,add_cha32,z_in_buf2[32*0+:32*32]};
		x_in_buf3 <= {xor_sha_48_32,add_sha32,x_in_buf2[32*0+:32*32]};
	end
end

always @(posedge clk)begin
	if(out_vld3&out_rdy3)begin
		z_out <= {add_cha48,z_in_buf3[32*16+:32*16],z_in_buf3[32*32+:32*16],z_in_buf3[32*0+:32*16]};
		x_out <= {add_sha48,x_in_buf3[32*16+:32*16],x_in_buf3[32*32+:32*16],x_in_buf3[32*0+:32*16]};
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_rdy3 <= 1'b1;
	end
	else if(out_rdy3&out_vld3)begin
		out_rdy3 <= 1'b0;
	end
	else if(out_vld&out_rdy)begin
		out_rdy3 <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld <= 1'b0;
	end
	else if(out_vld3&out_rdy3)begin
		out_vld <= 1'b1;
	end
	else if(out_vld&out_rdy)begin
		out_vld <= 1'b0;
	end
end
//instant modules
JISUAN_CHASHA U0_JISUAN_CHASHA(
	.clk				(clk  ),
	.rst_n				(rst_n),
	.in_vld				(in_vld   ),
	.in_rdy				(in_rdy   ),
	.x_in_cha			(xor_cha_0_48),
	.x_in_sha			(xor_sha_0_48),
	.out_vld			(out_vld0  ),
	.out_rdy			(out_rdy0  ),
	.x_out_cha			(x_out_cha0),
	.x_out_sha			(x_out_sha0)
);

JISUAN_CHASHA U1_JISUAN_CHASHA(
	.clk				(clk  ),
	.rst_n				(rst_n),
	.in_vld				(out_vld0),
	.in_rdy				(out_rdy0),
	.x_in_cha			(xor_cha_16_0),
	.x_in_sha			(xor_sha_16_0),
	.out_vld			(out_vld1  ),
	.out_rdy			(out_rdy1  ),
	.x_out_cha			(x_out_cha1),
	.x_out_sha			(x_out_sha1)
);

JISUAN_CHASHA U2_JISUAN_CHASHA(
	.clk				(clk  ),
	.rst_n				(rst_n),
	.in_vld				(out_vld1),
	.in_rdy				(out_rdy1),
	.x_in_cha			(xor_cha_32_16),
	.x_in_sha			(xor_sha_32_16),
	.out_vld			(out_vld2  ),
	.out_rdy			(out_rdy2  ),
	.x_out_cha			(x_out_cha2),
	.x_out_sha			(x_out_sha2)
);

JISUAN_CHASHA U3_JISUAN_CHASHA(
	.clk				(clk  ),
	.rst_n				(rst_n),
	.in_vld				(out_vld2  ),
	.in_rdy				(out_rdy2  ),
	.x_in_cha			(xor_cha_48_32),
	.x_in_sha			(xor_sha_48_32),
	.out_vld			(out_vld3  ),
	.out_rdy			(out_rdy3  ),
	.x_out_cha			(x_out_cha3),
	.x_out_sha			(x_out_sha3)
);
endmodule
