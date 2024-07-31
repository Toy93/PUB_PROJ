/*************************************************************************
    # File Name: ab_cpy.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:26:48 AM EDT
    # Last Modified:2022-04-16 05:06
    # Update Count:47
*************************************************************************/
module AB_CPY #(
	parameter PASSWD_LEN = 80,
	parameter SALT_LEN = 80,
	parameter KDF_BUF_SIZE = 256,
	parameter INPUT_SIZE = 64,
	parameter KEY_SIZE = 32
)(
	input							clk,
	input							rst_n,

	//interface with TB
	input							in_vld,
	output							in_rdy,
	input [PASSWD_LEN*8 - 1:0]		password,
	input [SALT_LEN*8 - 1:0]		salt,
	
	//interface with BLK2S_CALC_ALL
	output reg						out_vld,
	input							out_rdy,
	output reg[(KDF_BUF_SIZE+INPUT_SIZE)*8 - 1:0]a,
	output reg[(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]b,
	output reg[PASSWD_LEN*8 - 1:0]	password_o
);
localparam A_QUOTIENT = KDF_BUF_SIZE / PASSWD_LEN;
localparam A_REMAINDER= KDF_BUF_SIZE - A_QUOTIENT*PASSWD_LEN;
localparam B_QUOTIENT = KDF_BUF_SIZE / SALT_LEN	;
localparam B_REMAINDER= KDF_BUF_SIZE - B_QUOTIENT*SALT_LEN;
genvar I;

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld <= 1'b0;
	end
	else if(in_rdy)begin
		out_vld <= in_vld;
	end
end
assign in_rdy = (~out_vld)|out_rdy;

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		password_o <= password;
	end
end
generate
	if(PASSWD_LEN > 256)begin
		always @(posedge clk)begin
			if(in_vld & in_rdy)begin
				a <= {password[KDF_BUF_SIZE*8 - 1:0]};
			end
		end
	end
	else begin
		for(I = 0; I < A_QUOTIENT; I = I+1)begin:A_LOOP_CPY
			always @(posedge clk)begin
				if(in_vld & in_rdy)begin
					a[PASSWD_LEN*8*I +:PASSWD_LEN*8] <= password;
				end
			end
		end
		if(A_REMAINDER != 0)begin
			always @(posedge clk)begin
				if(in_vld & in_rdy)begin
					a[PASSWD_LEN*A_QUOTIENT*8 +:A_REMAINDER*8] <= password[A_REMAINDER*8 - 1:0];
				end
			end
		end
	end

	if(SALT_LEN > 256)begin
		always @(posedge clk)begin
			if(in_vld & in_rdy)begin
				b <= salt[KDF_BUF_SIZE*8 - 1:0];
			end
		end
	end
	else begin
		for(I = 0; I < B_QUOTIENT; I = I+1)begin:B_LOOP_CPY
			always @(posedge clk)begin
				if(in_vld & in_rdy)begin
					b[SALT_LEN*8*I +:SALT_LEN*8] <= salt;
				end
			end
		end
		if(B_REMAINDER != 0)begin
			always @(posedge clk)begin
				if(in_vld & in_rdy)begin
					b[SALT_LEN*B_QUOTIENT*8 +:B_REMAINDER*8] <= salt[B_REMAINDER*8 - 1:0];
				end
			end
		end
	end
endgenerate

always @(posedge clk)begin
	if(in_vld & in_rdy)begin
		a[KDF_BUF_SIZE*8 +:INPUT_SIZE*8] <= password[0+:INPUT_SIZE*8];
		b[KDF_BUF_SIZE*8 +:KEY_SIZE*8] <= salt[0+:KEY_SIZE*8];
	end
end
endmodule
