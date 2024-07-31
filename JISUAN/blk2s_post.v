/*************************************************************************
    # File Name: blk2s_post.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:31:02 AM EDT
    # Last Modified:2022-04-09 01:04
    # Update Count:49
*************************************************************************/
module BLK2S_POST#(
	parameter OUTPUT_SIZE = 32
)(
	input					clk		,
	input					rst_n	,

	//interface with BLK2S
	input					in_vld	,
	output					in_rdy	,
	input [OUTPUT_SIZE*8-1:0]prf_output,

	//nterface with BLK2S_PRE
	output					out_vld,
	input					out_rdy,
	output [7:0]			buf_ptr
);
reg [10:0]prf_output_hier0[3:0];
reg [12:0]prf_output_hier1;
reg [1:0]in_vld_delay;
wire bubble0;
wire bubble1;
wire data_take;
genvar I;

assign in_rdy = bubble0 | data_take;
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_vld_delay[0] <= 1'd0;
	end
	else if(in_rdy)begin
		in_vld_delay[0] <= in_vld; 
	end
end
assign bubble0 = (~in_vld_delay[0])|bubble1;

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_vld_delay[1] <= 1'b0;
	end
	else if(bubble0|data_take)begin
		in_vld_delay[1] <= in_vld_delay[0];
	end
end

assign out_vld = in_vld_delay[1];
assign data_take = out_vld&out_rdy;
assign bubble1 = (~in_vld_delay[1]);

generate 
	for(I=0;I<4;I=I+1)begin:HIER0
		always @(posedge clk)begin
			if(in_vld&in_rdy)begin
				prf_output_hier0[I] <= prf_output[64*I+0*8+:8]+prf_output[64*I+1*8+:8]+prf_output[64*I+2*8+:8]+prf_output[64*I+3*8+:8]+
			                           prf_output[64*I+4*8+:8]+prf_output[64*I+5*8+:8]+prf_output[64*I+6*8+:8]+prf_output[64*I+7*8+:8];
			end
		end
	end
endgenerate

always @(posedge clk)begin
	if(in_vld_delay[0]&(bubble1 | data_take))begin
		prf_output_hier1 <= prf_output_hier0[0]+prf_output_hier0[1]+prf_output_hier0[2]+prf_output_hier0[3];
	end
end
assign buf_ptr = prf_output_hier1[7:0];
endmodule
