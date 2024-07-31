/*************************************************************************
    # File Name: button_jump.v
    # Author: MuChen
    # Mail: yqs_ahut@163.com
    # QQ: 3221153405
    # Created Time: 2024年03月13日 星期三 22时29分58秒
*************************************************************************/
module BUTTON_JUMP(
	input clk  ,
	input rst_n,
	input sw8_in,

	output reg sw8_out
);
	
	reg sw8_in_1d;
	reg [31:0]count;
	wire sw8_edge_dec;

	always @(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			sw8_in_1d <= 1'b0;
		end
		else begin
			sw8_in_1d <= sw8_in;
		end
	end

	assign sw8_edge_dec = sw8_in^sw8_in_1d;

	always @(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			count <= 32'd0;
		end
		else if(sw8_edge_dec)begin
			count <= 32'd0;
		end
		else if(count == 1000)begin
			count <= 32'd0;
		end
		else begin
			count <= count+1;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			sw8_out <= 1'b0;
		end
		else if(count == 1000)begin
			sw8_out <= sw8_in;
		end
	end

endmodule
