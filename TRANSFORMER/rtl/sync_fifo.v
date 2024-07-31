// +FHDR----------------------------------------------------------------------------
// Project Name  : TRANSFORMER
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/03/31 17:07
// Last Modified : 2024/03/31 18:36
// File Name     : sync_fifo.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/03/31   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module SYNC_FIFO#(
	parameter DATA_WIDTH = 8
)(
	input                       clk  , 
	input                       rst_n, 
	input                       wr_en, 
	input   [DATA_WIDTH-1:0]    din  , 
	output                      full , 
	input                       rd_en, 
	output  reg[DATA_WIDTH-1:0] dout , 
	output                      empty
);
	reg  [4:0] wr_cnt;
	reg  [4:0] rd_cnt;
	wire [3:0] wr_p,rd_p;
	assign wr_p = wr_cnt[3:0];
	assign rd_p = rd_cnt[3:0];
	reg [DATA_WIDTH-1:0] mem [15:0];
	assign full = (wr_cnt[4]!= rd_cnt[4]&&wr_p==rd_p)? 1:0;
	assign empty = (wr_cnt== rd_cnt)? 1:0;
	always@(posedge clk or negedge rst_n)begin
	    if(!rst_n)begin
	        rd_cnt <=0;
	    end
	    else if(!empty&&rd_en)begin
	        rd_cnt <= rd_cnt + 1;
	    end
	end

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
	        wr_cnt <=0;
		end
	    else if(!full&&wr_en)begin
	        wr_cnt <= wr_cnt +1;
	    end
	end
	
	always@(posedge clk) begin
	    if(!full&&wr_en)begin
	        mem[wr_p] <= din;
	    end
	end

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			dout <= {DATA_WIDTH{1'b0}};
		end
		else if(rd_en&~empty)begin
			dout <= mem[rd_p];
		end
	end

endmodule
