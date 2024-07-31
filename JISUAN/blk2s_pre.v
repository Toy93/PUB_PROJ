/*************************************************************************
    # File Name: blk2s_pre.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:28:43 AM EDT
    # Last Modified:2022-04-16 08:45
    # Update Count:75
*************************************************************************/
module BLK2S_PRE#(
	parameter PASSWD_LEN	= 80,
	parameter KDF_BUF_SIZE	= 256,
	parameter INPUT_SIZE	= 64,
	parameter KEY_SIZE		= 32,
	parameter OUTPUT_SIZE	= 32
)(
	input											clk			,
	input											rst_n		,

	//interface with previous module
	input											in_vld0		,
	output reg										in_rdy0		,
	input		[(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]	a_in		,
	input 		[(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	b_in		,
	input 		[7:0]								buf_ptr_in0 ,
	input		[PASSWD_LEN*8 - 1:0]				password    ,

	//interface with BLK2S
	output reg										out_vld0	,
	input											out_rdy0	,
	output		[INPUT_SIZE*8 - 1:0]				prf_input	,
	output		[KEY_SIZE*8 - 1:0]					prf_key		,
	input		[OUTPUT_SIZE*8 -1:0]				prf_output	,

	//interface with BLK2S_POST
	input											in_vld1		,
	output reg										in_rdy1		,
	input		[7:0]								buf_ptr_in1 ,

	//interface with next module
	output reg										out_vld1	,
	input											out_rdy1	,
	output		[(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]	a_out		,
	output 		[(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	b_out		,
	output reg  [PASSWD_LEN*8 - 1:0]				password_o  
);
//signal define
//------------------------------------------------------
wire [5:0]min;
reg [7:0]index;
reg in_vld1_1d;
reg [(KDF_BUF_SIZE + INPUT_SIZE)*8 - 1:0]a_mem;
reg [(KDF_BUF_SIZE + KEY_SIZE)*8 - 1:0]b_mem;
assign a_out = a_mem;
assign b_out = b_mem;
//main code
//------------------------------------------------------
always @(posedge clk)begin
	if(in_vld0 & in_rdy0)begin
		a_mem <= a_in;
	end
end


always @(posedge clk)begin
	if(in_vld0 & in_rdy0)begin
		password_o <= password;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_vld1_1d <= 1'b0;
	end
	else if(in_vld1 & in_rdy1)begin
		in_vld1_1d <= 1'b1;
	end
	else begin
		in_vld1_1d <= 1'b0;
	end
end

always @(posedge clk)begin
	if(in_vld0 & in_rdy0)begin
		b_mem <= b_in;
	end
	else if(in_vld1 & in_rdy1)begin
		b_mem[buf_ptr_in1*8 +: OUTPUT_SIZE*8] <= b_mem[buf_ptr_in1*8 +: OUTPUT_SIZE*8]^prf_output;
	end
	else if(in_vld1_1d)begin
		case(index)
			//0 <= index <= 31
			8'd0:b_mem[(KDF_BUF_SIZE+0)*8 +: 32*8] <= b_mem[0*8 +:32*8];
			8'd1:b_mem[(KDF_BUF_SIZE+1)*8 +: 31*8] <= b_mem[1*8 +:31*8];
			8'd2:b_mem[(KDF_BUF_SIZE+2)*8 +: 30*8] <= b_mem[2*8 +:30*8];
			8'd3:b_mem[(KDF_BUF_SIZE+3)*8 +: 29*8] <= b_mem[3*8 +:29*8];
			8'd4:b_mem[(KDF_BUF_SIZE+4)*8 +: 28*8] <= b_mem[4*8 +:28*8];
			8'd5:b_mem[(KDF_BUF_SIZE+5)*8 +: 27*8] <= b_mem[5*8 +:27*8];
			8'd6:b_mem[(KDF_BUF_SIZE+6)*8 +: 26*8] <= b_mem[6*8 +:26*8];
			8'd7:b_mem[(KDF_BUF_SIZE+7)*8 +: 25*8] <= b_mem[7*8 +:25*8];
			8'd8:b_mem[(KDF_BUF_SIZE+8)*8 +: 24*8] <= b_mem[8*8 +:24*8];
			8'd9:b_mem[(KDF_BUF_SIZE+9)*8 +: 23*8] <= b_mem[9*8 +:23*8];
			8'd10:b_mem[(KDF_BUF_SIZE+10)*8 +: 22*8] <= b_mem[10*8 +:22*8];
			8'd11:b_mem[(KDF_BUF_SIZE+11)*8 +: 21*8] <= b_mem[11*8 +:21*8];
			8'd12:b_mem[(KDF_BUF_SIZE+12)*8 +: 20*8] <= b_mem[12*8 +:20*8];
			8'd13:b_mem[(KDF_BUF_SIZE+13)*8 +: 19*8] <= b_mem[13*8 +:19*8];
			8'd14:b_mem[(KDF_BUF_SIZE+14)*8 +: 18*8] <= b_mem[14*8 +:18*8];
			8'd15:b_mem[(KDF_BUF_SIZE+15)*8 +: 17*8] <= b_mem[15*8 +:17*8];
			8'd16:b_mem[(KDF_BUF_SIZE+16)*8 +: 16*8] <= b_mem[16*8 +:16*8];
			8'd17:b_mem[(KDF_BUF_SIZE+17)*8 +: 15*8] <= b_mem[17*8 +:15*8];
			8'd18:b_mem[(KDF_BUF_SIZE+18)*8 +: 14*8] <= b_mem[18*8 +:14*8];
			8'd19:b_mem[(KDF_BUF_SIZE+19)*8 +: 13*8] <= b_mem[19*8 +:13*8];
			8'd20:b_mem[(KDF_BUF_SIZE+20)*8 +: 12*8] <= b_mem[20*8 +:12*8];
			8'd21:b_mem[(KDF_BUF_SIZE+21)*8 +: 11*8] <= b_mem[21*8 +:11*8];
			8'd22:b_mem[(KDF_BUF_SIZE+22)*8 +: 10*8] <= b_mem[22*8 +:10*8];
			8'd23:b_mem[(KDF_BUF_SIZE+23)*8 +:  9*8] <= b_mem[23*8 +: 9*8];
			8'd24:b_mem[(KDF_BUF_SIZE+24)*8 +:  8*8] <= b_mem[24*8 +: 8*8];
			8'd25:b_mem[(KDF_BUF_SIZE+25)*8 +:  7*8] <= b_mem[25*8 +: 7*8];
			8'd26:b_mem[(KDF_BUF_SIZE+26)*8 +:  6*8] <= b_mem[26*8 +: 6*8];
			8'd27:b_mem[(KDF_BUF_SIZE+27)*8 +:  5*8] <= b_mem[27*8 +: 5*8];
			8'd28:b_mem[(KDF_BUF_SIZE+28)*8 +:  4*8] <= b_mem[28*8 +: 4*8];
			8'd29:b_mem[(KDF_BUF_SIZE+29)*8 +:  3*8] <= b_mem[29*8 +: 3*8];
			8'd30:b_mem[(KDF_BUF_SIZE+30)*8 +:  2*8] <= b_mem[30*8 +: 2*8];
			8'd31:b_mem[(KDF_BUF_SIZE+31)*8 +:  1*8] <= b_mem[31*8 +: 1*8];

			//225 <= index <= 255
			8'd225:b_mem[0 +:1*8]  <= b_mem[KDF_BUF_SIZE*8 +: 1*8];
			8'd226:b_mem[0 +:2*8]  <= b_mem[KDF_BUF_SIZE*8 +: 2*8];
			8'd227:b_mem[0 +:3*8]  <= b_mem[KDF_BUF_SIZE*8 +: 3*8];
			8'd228:b_mem[0 +:4*8]  <= b_mem[KDF_BUF_SIZE*8 +: 4*8];
			8'd229:b_mem[0 +:5*8]  <= b_mem[KDF_BUF_SIZE*8 +: 5*8];
			8'd230:b_mem[0 +:6*8]  <= b_mem[KDF_BUF_SIZE*8 +: 6*8];
			8'd231:b_mem[0 +:7*8]  <= b_mem[KDF_BUF_SIZE*8 +: 7*8];
			8'd232:b_mem[0 +:8*8]  <= b_mem[KDF_BUF_SIZE*8 +: 8*8];
			8'd233:b_mem[0 +:9*8]  <= b_mem[KDF_BUF_SIZE*8 +: 9*8];
			8'd234:b_mem[0 +:10*8] <= b_mem[KDF_BUF_SIZE*8 +: 10*8];
			8'd235:b_mem[0 +:11*8] <= b_mem[KDF_BUF_SIZE*8 +: 11*8];
			8'd236:b_mem[0 +:12*8] <= b_mem[KDF_BUF_SIZE*8 +: 12*8];
			8'd237:b_mem[0 +:13*8] <= b_mem[KDF_BUF_SIZE*8 +: 13*8];
			8'd238:b_mem[0 +:14*8] <= b_mem[KDF_BUF_SIZE*8 +: 14*8];
			8'd239:b_mem[0 +:15*8] <= b_mem[KDF_BUF_SIZE*8 +: 15*8];
			8'd240:b_mem[0 +:16*8] <= b_mem[KDF_BUF_SIZE*8 +: 16*8];
			8'd241:b_mem[0 +:17*8] <= b_mem[KDF_BUF_SIZE*8 +: 17*8];
			8'd242:b_mem[0 +:18*8] <= b_mem[KDF_BUF_SIZE*8 +: 18*8];
			8'd243:b_mem[0 +:19*8] <= b_mem[KDF_BUF_SIZE*8 +: 19*8];
			8'd244:b_mem[0 +:20*8] <= b_mem[KDF_BUF_SIZE*8 +: 20*8];
			8'd245:b_mem[0 +:21*8] <= b_mem[KDF_BUF_SIZE*8 +: 21*8];
			8'd246:b_mem[0 +:22*8] <= b_mem[KDF_BUF_SIZE*8 +: 22*8];
			8'd247:b_mem[0 +:23*8] <= b_mem[KDF_BUF_SIZE*8 +: 23*8];
			8'd248:b_mem[0 +:24*8] <= b_mem[KDF_BUF_SIZE*8 +: 24*8];
			8'd249:b_mem[0 +:25*8] <= b_mem[KDF_BUF_SIZE*8 +: 25*8];
			8'd250:b_mem[0 +:26*8] <= b_mem[KDF_BUF_SIZE*8 +: 26*8];
			8'd251:b_mem[0 +:27*8] <= b_mem[KDF_BUF_SIZE*8 +: 27*8];
			8'd252:b_mem[0 +:28*8] <= b_mem[KDF_BUF_SIZE*8 +: 28*8];
			8'd253:b_mem[0 +:29*8] <= b_mem[KDF_BUF_SIZE*8 +: 29*8];
			8'd254:b_mem[0 +:30*8] <= b_mem[KDF_BUF_SIZE*8 +: 30*8];
			8'd255:b_mem[0 +:31*8] <= b_mem[KDF_BUF_SIZE*8 +: 31*8];
			default:begin
				b_mem <= b_mem;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		index <= 8'd0;
	end
	else if(in_vld0 & in_rdy0)begin
		index <= buf_ptr_in0;
	end
	else if(in_vld1 & in_rdy1)begin
		index <= buf_ptr_in1;
	end
end

assign prf_input = a_mem[index*8 +:INPUT_SIZE*8];
assign prf_key   = b_mem[index*8 +:KEY_SIZE*8];

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld0 <= 1'b0;
	end
	else if(in_vld0&in_rdy0)begin
		out_vld0 <= 1'b1;
	end
	else if(out_vld0 & out_rdy0)begin
		out_vld0 <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_rdy0 <= 1'b1;
	end
	else if(in_vld0 & in_rdy0)begin
		in_rdy0 <= 1'b0;
	end
	else if(out_vld1 & out_rdy1)begin
		in_rdy0 <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		in_rdy1 <= 1'b1;
	end
	else if(in_vld1 & in_rdy1)begin
		in_rdy1 <= 1'b0;
	end
	else if(out_vld1 & out_rdy1)begin
		in_rdy1 <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld1 <= 1'b0;
	end
	else if(out_vld1)begin
		if(out_rdy1 & (~in_vld1_1d))begin
			out_vld1 <= 1'b0;
		end
	end
	else begin
		out_vld1 <= in_vld1_1d;
	end
end
endmodule
