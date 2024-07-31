/*************************************************************************
    # File Name: jisuan_chasha.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 13 Apr 2022 11:46:38 AM EDT
    # Last Modified:2022-04-14 12:05
    # Update Count:34
*************************************************************************/
module JISUAN_CHASHA(
	input clk,
	input rst_n,
	input in_vld,
	output in_rdy,
	input [32*16 -1:0]x_in_cha,
	input [32*16 -1:0]x_in_sha,

	output out_vld,
	input out_rdy,
	output[32*16 - 1:0]x_out_cha,
	output[32*16 - 1:0]x_out_sha
);
reg [3:0]round;
reg oe_flag;
reg round_en;
reg[32*16 -1:0]cha_buf;
reg[32*16 -1:0]sha_buf;
reg [1:0]buf_vld;
reg buf_rdy;

//cha in
reg [31:0]a_in_cha_0_0  ;
reg [31:0]b_in_cha_4_5  ;
reg [31:0]c_in_cha_8_10 ;
reg [31:0]d_in_cha_12_15;
reg [31:0]a_in_cha_1_1  ;
reg [31:0]b_in_cha_5_6  ;
reg [31:0]c_in_cha_9_11 ;
reg [31:0]d_in_cha_13_12;
reg [31:0]a_in_cha_2_2  ;
reg [31:0]b_in_cha_6_7  ;
reg [31:0]c_in_cha_10_8 ;
reg [31:0]d_in_cha_14_13;
reg [31:0]a_in_cha_3_3  ;
reg [31:0]b_in_cha_7_4  ;
reg [31:0]c_in_cha_11_9 ;
reg [31:0]d_in_cha_15_14;
//cha out
wire [31:0]a_out_cha_0_0  ;
wire [31:0]b_out_cha_4_5  ;
wire [31:0]c_out_cha_8_10 ;
wire [31:0]d_out_cha_12_15;
wire [31:0]a_out_cha_1_1  ;
wire [31:0]b_out_cha_5_6  ;
wire [31:0]c_out_cha_9_11 ;
wire [31:0]d_out_cha_13_12;
wire [31:0]a_out_cha_2_2  ;
wire [31:0]b_out_cha_6_7  ;
wire [31:0]c_out_cha_10_8 ;
wire [31:0]d_out_cha_14_13;
wire [31:0]a_out_cha_3_3  ;
wire [31:0]b_out_cha_7_4  ; 
wire [31:0]c_out_cha_11_9 ;
wire [31:0]d_out_cha_15_14;

reg in_rdy_lock;
//sha in
reg [31:0]a_in_sha_0_0  ;
reg [31:0]b_in_sha_4_1  ;
reg [31:0]c_in_sha_8_2  ; 
reg [31:0]d_in_sha_12_3 ;
reg [31:0]a_in_sha_5_5  ;
reg [31:0]b_in_sha_9_6  ;
reg [31:0]c_in_sha_13_7 ;
reg [31:0]d_in_sha_1_4  ;
reg [31:0]a_in_sha_10_10;
reg [31:0]b_in_sha_14_11;
reg [31:0]c_in_sha_2_8  ;
reg [31:0]d_in_sha_6_9  ;
reg [31:0]a_in_sha_15_15;
reg [31:0]b_in_sha_3_12 ;
reg [31:0]c_in_sha_7_13 ;
reg [31:0]d_in_sha_11_14;
//sha out
wire [31:0]a_out_sha_0_0  ;
wire [31:0]b_out_sha_4_1  ;
wire [31:0]c_out_sha_8_2  ;
wire [31:0]d_out_sha_12_3 ;
wire [31:0]a_out_sha_5_5  ;
wire [31:0]b_out_sha_9_6  ;
wire [31:0]c_out_sha_13_7 ;
wire [31:0]d_out_sha_1_4  ;
wire [31:0]a_out_sha_10_10;
wire [31:0]b_out_sha_14_11;
wire [31:0]c_out_sha_2_8  ;
wire [31:0]d_out_sha_6_9  ;
wire [31:0]a_out_sha_15_15;
wire [31:0]b_out_sha_3_12 ;
wire [31:0]c_out_sha_7_13 ;
wire [31:0]d_out_sha_11_14;

reg [32*16 -1:0]cha_chaos2order;
reg [32*16 -1:0]sha_chaos2order;
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		round_en <= 1'b0;
	end
	else if(in_vld&in_rdy)begin
		round_en <= 1'b1;
	end
	else if((round == 4'd9) && (oe_flag == 1'b1) && (buf_vld == 2'd1) && buf_rdy)begin
		round_en <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		round <= 4'd0;
	end
	else if(round_en & oe_flag & (buf_vld == 2'd1) & buf_rdy)begin
		if(round == 4'd9)begin
			round <= 4'd0;
		end
		else begin
			round <= round + 1'b1;
		end
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		oe_flag <= 1'b0;
	end
	else if(in_vld&in_rdy)begin
		oe_flag <= ~oe_flag;
	end
	else if((buf_vld == 2'd1) & buf_rdy)begin
		oe_flag <= ~oe_flag;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		buf_vld <= 2'd0;
	end
	else if(in_vld&in_rdy)begin
		buf_vld <= 2'd1;
	end
	else if((buf_vld == 2'd1) & buf_rdy)begin
		if((round == 4'd9) & oe_flag & (buf_vld == 2'b1) & buf_rdy)begin
			buf_vld <= 2'd2;
		end
	end
	else if(out_vld & out_rdy)begin
		buf_vld <= 2'd0;
	end
end

assign out_vld = (buf_vld == 2'd2) ? 1'b1 : 1'b0;
assign x_out_cha = cha_buf;
assign x_out_sha = sha_buf;
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		buf_rdy <= 1'b0;
	end
	else if(in_vld&in_rdy)begin
		buf_rdy <= 1'b1;
	end
	else if(oe_flag & (buf_vld == 2'd1) & buf_rdy & (round == 4'd9))begin
		buf_rdy <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_rdy_lock <= 1'b1;
	end
	else if(in_vld&in_rdy)begin
		in_rdy_lock <= 1'b0;
	end
	else if(out_vld & out_rdy)begin
		in_rdy_lock <= 1'b1;
	end
end

assign in_rdy = in_rdy_lock|(out_vld&out_rdy);

always @(posedge clk)begin
	if((in_vld&in_rdy) | ((buf_vld == 2'b1) & buf_rdy))begin
		cha_buf <= cha_chaos2order;
		sha_buf <= sha_chaos2order;
	end
end

always @(*)begin
	if(in_vld&in_rdy)begin
		a_in_cha_0_0   = x_in_cha[32*0+:32];
		b_in_cha_4_5   = x_in_cha[32*4+:32];
		c_in_cha_8_10  = x_in_cha[32*8+:32];
		d_in_cha_12_15 = x_in_cha[32*12+:32];
		a_in_cha_1_1   = x_in_cha[32*1+:32];
		b_in_cha_5_6   = x_in_cha[32*5+:32];
		c_in_cha_9_11  = x_in_cha[32*9+:32];
		d_in_cha_13_12 = x_in_cha[32*13+:32];
		a_in_cha_2_2   = x_in_cha[32*2+:32];
		b_in_cha_6_7   = x_in_cha[32*6+:32];
		c_in_cha_10_8  = x_in_cha[32*10+:32];
		d_in_cha_14_13 = x_in_cha[32*14+:32];
		a_in_cha_3_3   = x_in_cha[32*3+:32];
		b_in_cha_7_4   = x_in_cha[32*7+:32];
		c_in_cha_11_9  = x_in_cha[32*11+:32];
		d_in_cha_15_14 = x_in_cha[32*15+:32];

		a_in_sha_0_0   = x_in_sha[32*0+:32];
		b_in_sha_4_1   = x_in_sha[32*4+:32];
		c_in_sha_8_2   = x_in_sha[32*8+:32]; 
		d_in_sha_12_3  = x_in_sha[32*12+:32];
		a_in_sha_5_5   = x_in_sha[32*5+:32];
		b_in_sha_9_6   = x_in_sha[32*9+:32];
		c_in_sha_13_7  = x_in_sha[32*13+:32];
		d_in_sha_1_4   = x_in_sha[32*1+:32];
		a_in_sha_10_10 = x_in_sha[32*10+:32];
		b_in_sha_14_11 = x_in_sha[32*14+:32];
		c_in_sha_2_8   = x_in_sha[32*2+:32];
		d_in_sha_6_9   = x_in_sha[32*6+:32];
		a_in_sha_15_15 = x_in_sha[32*15+:32];
		b_in_sha_3_12  = x_in_sha[32*3+:32];
		c_in_sha_7_13  = x_in_sha[32*7+:32];
		d_in_sha_11_14 = x_in_sha[32*11+:32];

	end
	else if(~oe_flag)begin
		a_in_cha_0_0   = cha_buf[32*0+:32];
		b_in_cha_4_5   = cha_buf[32*4+:32];
		c_in_cha_8_10  = cha_buf[32*8+:32];
		d_in_cha_12_15 = cha_buf[32*12+:32];
		a_in_cha_1_1   = cha_buf[32*1+:32];
		b_in_cha_5_6   = cha_buf[32*5+:32];
		c_in_cha_9_11  = cha_buf[32*9+:32];
		d_in_cha_13_12 = cha_buf[32*13+:32];
		a_in_cha_2_2   = cha_buf[32*2+:32];
		b_in_cha_6_7   = cha_buf[32*6+:32];
		c_in_cha_10_8  = cha_buf[32*10+:32];
		d_in_cha_14_13 = cha_buf[32*14+:32];
		a_in_cha_3_3   = cha_buf[32*3+:32];
		b_in_cha_7_4   = cha_buf[32*7+:32];
		c_in_cha_11_9  = cha_buf[32*11+:32];
		d_in_cha_15_14 = cha_buf[32*15+:32];

		a_in_sha_0_0   = sha_buf[32*0+:32];
		b_in_sha_4_1   = sha_buf[32*4+:32];
		c_in_sha_8_2   = sha_buf[32*8+:32]; 
		d_in_sha_12_3  = sha_buf[32*12+:32];
		a_in_sha_5_5   = sha_buf[32*5+:32];
		b_in_sha_9_6   = sha_buf[32*9+:32];
		c_in_sha_13_7  = sha_buf[32*13+:32];
		d_in_sha_1_4   = sha_buf[32*1+:32];
		a_in_sha_10_10 = sha_buf[32*10+:32];
		b_in_sha_14_11 = sha_buf[32*14+:32];
		c_in_sha_2_8   = sha_buf[32*2+:32];
		d_in_sha_6_9   = sha_buf[32*6+:32];
		a_in_sha_15_15 = sha_buf[32*15+:32];
		b_in_sha_3_12  = sha_buf[32*3+:32];
		c_in_sha_7_13  = sha_buf[32*7+:32];
		d_in_sha_11_14 = sha_buf[32*11+:32];
	end
	else begin
		a_in_cha_0_0   = cha_buf[32*0+:32];
		b_in_cha_4_5   = cha_buf[32*5+:32];
		c_in_cha_8_10  = cha_buf[32*10+:32];
		d_in_cha_12_15 = cha_buf[32*15+:32];
		a_in_cha_1_1   = cha_buf[32*1+:32];
		b_in_cha_5_6   = cha_buf[32*6+:32];
		c_in_cha_9_11  = cha_buf[32*11+:32];
		d_in_cha_13_12 = cha_buf[32*12+:32];
		a_in_cha_2_2   = cha_buf[32*2+:32];
		b_in_cha_6_7   = cha_buf[32*7+:32];
		c_in_cha_10_8  = cha_buf[32*8+:32];
		d_in_cha_14_13 = cha_buf[32*13+:32];
		a_in_cha_3_3   = cha_buf[32*3+:32];
		b_in_cha_7_4   = cha_buf[32*4+:32];
		c_in_cha_11_9  = cha_buf[32*9+:32];
		d_in_cha_15_14 = cha_buf[32*14+:32];

		a_in_sha_0_0   = sha_buf[32*0+:32];
		b_in_sha_4_1   = sha_buf[32*1+:32];
		c_in_sha_8_2   = sha_buf[32*2+:32]; 
		d_in_sha_12_3  = sha_buf[32*3+:32];
		a_in_sha_5_5   = sha_buf[32*5+:32];
		b_in_sha_9_6   = sha_buf[32*6+:32];
		c_in_sha_13_7  = sha_buf[32*7+:32];
		d_in_sha_1_4   = sha_buf[32*4+:32];
		a_in_sha_10_10 = sha_buf[32*10+:32];
		b_in_sha_14_11 = sha_buf[32*11+:32];
		c_in_sha_2_8   = sha_buf[32*8+:32];
		d_in_sha_6_9   = sha_buf[32*9+:32];
		a_in_sha_15_15 = sha_buf[32*15+:32];
		b_in_sha_3_12  = sha_buf[32*12+:32];
		c_in_sha_7_13  = sha_buf[32*13+:32];
		d_in_sha_11_14 = sha_buf[32*14+:32];
	end
end

always @(*)begin
	if((~oe_flag) | (in_vld&in_rdy))begin
		cha_chaos2order = {d_out_cha_15_14 ,d_out_cha_14_13 ,d_out_cha_13_12 ,d_out_cha_12_15,
			               c_out_cha_11_9  ,c_out_cha_10_8  ,c_out_cha_9_11  ,c_out_cha_8_10 ,
						   b_out_cha_7_4   ,b_out_cha_6_7   ,b_out_cha_5_6   ,b_out_cha_4_5  ,
						   a_out_cha_3_3   ,a_out_cha_2_2   ,a_out_cha_1_1   ,a_out_cha_0_0 };	

		sha_chaos2order = {a_out_sha_15_15 ,b_out_sha_14_11 ,c_out_sha_13_7  ,d_out_sha_12_3,
			               d_out_sha_11_14 ,a_out_sha_10_10 ,b_out_sha_9_6   ,c_out_sha_8_2 ,
						   c_out_sha_7_13  ,d_out_sha_6_9   ,a_out_sha_5_5   ,b_out_sha_4_1 ,
						   b_out_sha_3_12  ,c_out_sha_2_8   ,d_out_sha_1_4   ,a_out_sha_0_0 };
	end
	else begin
		cha_chaos2order = {d_out_cha_12_15 ,d_out_cha_15_14 ,d_out_cha_14_13 ,d_out_cha_13_12,
						   c_out_cha_9_11  ,c_out_cha_8_10  ,c_out_cha_11_9  ,c_out_cha_10_8 ,
						   b_out_cha_6_7   ,b_out_cha_5_6   ,b_out_cha_4_5   ,b_out_cha_7_4  ,  
						   a_out_cha_3_3   ,a_out_cha_2_2   ,a_out_cha_1_1   ,a_out_cha_0_0 };

		sha_chaos2order = {a_out_sha_15_15 ,d_out_sha_11_14 ,c_out_sha_7_13 ,b_out_sha_3_12,
						   b_out_sha_14_11 ,a_out_sha_10_10 ,d_out_sha_6_9  ,c_out_sha_2_8 ,
						   c_out_sha_13_7  ,b_out_sha_9_6   ,a_out_sha_5_5  ,d_out_sha_1_4 ,
						   d_out_sha_12_3  ,c_out_sha_8_2   ,b_out_sha_4_1  ,a_out_sha_0_0};		
	end
end

QUARTER_CHA U0_QUARTER_CHA(
	.a_in(a_in_cha_0_0  ),
	.b_in(b_in_cha_4_5  ),
	.c_in(c_in_cha_8_10 ),
	.d_in(d_in_cha_12_15),

	.a_out(a_out_cha_0_0  ),
	.b_out(b_out_cha_4_5  ),
	.c_out(c_out_cha_8_10 ),
	.d_out(d_out_cha_12_15)
);

QUARTER_CHA U1_QUARTER_CHA(
	.a_in(a_in_cha_1_1  ),
	.b_in(b_in_cha_5_6  ),
	.c_in(c_in_cha_9_11 ),
	.d_in(d_in_cha_13_12),

	.a_out(a_out_cha_1_1  ),
	.b_out(b_out_cha_5_6  ),
	.c_out(c_out_cha_9_11 ),
	.d_out(d_out_cha_13_12)
);

QUARTER_CHA U2_QUARTER_CHA(
	.a_in(a_in_cha_2_2  ),
	.b_in(b_in_cha_6_7  ),
	.c_in(c_in_cha_10_8 ),
	.d_in(d_in_cha_14_13),

	.a_out(a_out_cha_2_2  ),
	.b_out(b_out_cha_6_7  ),
	.c_out(c_out_cha_10_8 ),
	.d_out(d_out_cha_14_13)
);

QUARTER_CHA U3_QUARTER_CHA(
	.a_in(a_in_cha_3_3  ),
	.b_in(b_in_cha_7_4  ),
	.c_in(c_in_cha_11_9 ),
	.d_in(d_in_cha_15_14),

	.a_out(a_out_cha_3_3  ),
	.b_out(b_out_cha_7_4  ),
	.c_out(c_out_cha_11_9 ),
	.d_out(d_out_cha_15_14)
);

QUARTER_SHA U0_QUARTER_SHA(
	.a_in(a_in_sha_0_0 ),
	.b_in(b_in_sha_4_1 ),
	.c_in(c_in_sha_8_2 ),
	.d_in(d_in_sha_12_3),

	.a_out(a_out_sha_0_0 ),
	.b_out(b_out_sha_4_1 ),
	.c_out(c_out_sha_8_2 ),
	.d_out(d_out_sha_12_3)
);

QUARTER_SHA U1_QUARTER_SHA(
	.a_in(a_in_sha_5_5 ),
	.b_in(b_in_sha_9_6 ),
	.c_in(c_in_sha_13_7),
	.d_in(d_in_sha_1_4 ),

	.a_out(a_out_sha_5_5  ),
	.b_out(b_out_sha_9_6  ),
	.c_out(c_out_sha_13_7 ),
	.d_out(d_out_sha_1_4  ) 
);

QUARTER_SHA U2_QUARTER_SHA(
	.a_in(a_in_sha_10_10),
	.b_in(b_in_sha_14_11),
	.c_in(c_in_sha_2_8  ),
	.d_in(d_in_sha_6_9  ),

	.a_out(a_out_sha_10_10),
	.b_out(b_out_sha_14_11),
	.c_out(c_out_sha_2_8  ),
	.d_out(d_out_sha_6_9  )
);
QUARTER_SHA U3_QUARTER_SHA(
	.a_in(a_in_sha_15_15),
	.b_in(b_in_sha_3_12 ),
	.c_in(c_in_sha_7_13 ),
	.d_in(d_in_sha_11_14),

	.a_out(a_out_sha_15_15),
	.b_out(b_out_sha_3_12 ),
	.c_out(c_out_sha_7_13 ),
	.d_out(d_out_sha_11_14)
);
endmodule
