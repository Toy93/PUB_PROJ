/*************************************************************************
    # File Name: blk2s_ctrl.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:30:41 AM EDT
    # Last Modified:2022-04-03 08:35
    # Update Count:63
*************************************************************************/
module BLK2S_CTRL#(
	parameter INPUT_SIZE = 64,
	parameter KEY_SIZE = 32,
	parameter OUTPUT_SIZE = 32
)(
	input						clk			,
	input						rst_n		,

	//interface with BLK2S_PRE
	input						in_vld0		,
	output reg					in_rdy0		,
	input [INPUT_SIZE*8 - 1:0]	prf_input	,
	input [KEY_SIZE*8 - 1:0]	prf_key		,

	//interface with HCALC
	output reg					out_vld0	,
	output reg[32*2 -1:0]		t			,
	output reg[32*2 -1:0]		f			,
	output [32*16 -1:0]			m			,
	output [32*8 -1:0]			h0_o		,
	input						in_vld1		,
	input  [32*8 -1:0]			hi			,

	//interface with BLK2S_POST
	output reg					out_vld1	,
	input						out_rdy1	,
	output [32*8 -1:0]			h1_o
);
reg blk2s_cnt;
//parameter define
localparam BLAKE2S_BLOCK_SIZE = 64;

//signal define
reg [BLAKE2S_BLOCK_SIZE*2*8 -1:0]s_buf;
reg [32*8 -1:0]h_buf;
wire [32*8 -1:0]p;
wire [32*8 -1:0]blake2s_iv;
//main code
always @(posedge clk)begin
	if(in_vld0&in_rdy0)begin
		s_buf[0 +:BLAKE2S_BLOCK_SIZE*8] <= {{(BLAKE2S_BLOCK_SIZE-KEY_SIZE){8'b0}},prf_key};
		s_buf[BLAKE2S_BLOCK_SIZE*8 +:BLAKE2S_BLOCK_SIZE*8] <= prf_input;
	end
end

assign p[0+:8] = OUTPUT_SIZE;
assign p[8+:8] = KEY_SIZE;
assign p[16+:8]= 8'd1;
assign p[24+:8]= 8'd1;
assign p[32*8 -1:32]=224'd0;
assign blake2s_iv = {32'h5BE0CD19,32'h1F83D9AB,32'h9B05688C,32'h510E527F,
					 32'hA54FF53A,32'h3C6EF372,32'hBB67AE85,32'h6A09E667};

always @(posedge clk)begin
	if(in_vld0&in_rdy0)begin
		h_buf <= p^blake2s_iv;
	end
	else if(in_vld1)begin//????????
		h_buf <= h_buf^hi;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_rdy0 <= 1'b1;
	end
	else if(in_rdy0&in_vld0)begin
		in_rdy0 <= 1'b0;
	end
	else if(out_vld1&out_rdy1)begin
		in_rdy0 <= 1'b1;
	end
end

always @(posedge clk)begin
	if(in_vld0&in_rdy0)begin
		t <= {32'd0,32'd64};
	end
	else if(in_vld1 && blk2s_cnt == 1'b0)begin
		t <= {32'd0,{t[31:0]+BLAKE2S_BLOCK_SIZE}};
	end
end

always @(posedge clk)begin
	if(in_vld0&in_rdy0)begin
		f <= 64'd0;
	end
	else if(in_vld1 && blk2s_cnt == 1'b0)begin
		f <= {32'd0,32'hffff_ffff};
	end 
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		blk2s_cnt <= 1'b0;
	end
	else if(in_vld1)begin
		if(blk2s_cnt == 1'b1)begin
			blk2s_cnt <= 1'b0;
		end
		else begin
			blk2s_cnt <= blk2s_cnt + 1'b1;
		end
	end
end

assign h0_o = h_buf;
assign m = (blk2s_cnt == 1'b0) ? s_buf[0+:BLAKE2S_BLOCK_SIZE*8]: s_buf[BLAKE2S_BLOCK_SIZE*8+:BLAKE2S_BLOCK_SIZE*8];
assign h1_o = h_buf;  
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld0 <= 1'b0;
	end
	else if(blk2s_cnt == 1'b0)begin
		if(out_vld0)begin
			out_vld0 <= 1'b0;
		end
		else if((in_vld0&in_rdy0)|(in_vld1))begin
			out_vld0 <= 1'b1;
		end
	end
	else begin
		out_vld0 <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld1 <= 1'b0;
	end
	else if(blk2s_cnt == 1'b1 && in_vld1)begin
		out_vld1 <= 1'b1;
	end
	else if(out_vld1 && out_rdy1)begin
		out_vld1 <= 1'b0;
	end
end
endmodule
