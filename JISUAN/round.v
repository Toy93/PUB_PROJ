/*************************************************************************
    # File Name: round.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:30:03 AM EDT
    # Last Modified:2022-04-06 11:45
    # Update Count:50
*************************************************************************/
module ROUND(
	input						mode_sel,
    input		[32*16 -1:0]	v_i ,//输入数据v0
	input		[32*8 -1:0]		m	 ,

    output reg	[32*16 -1:0]	v_o//输入数据v0
);

wire [32*16 -1:0]b;
reg [32*16 -1:0]a;

always @(*)begin
	if(~mode_sel)begin
		a[32*0+:32]  = v_i[32*0 +:32];
		a[32*1+:32]  = v_i[32*4 +:32];
		a[32*2+:32]  = v_i[32*8 +:32];
		a[32*3+:32]  = v_i[32*12 +:32];
		a[32*4+:32]  = v_i[32*1 +:32];
		a[32*5+:32]  = v_i[32*5 +:32];
		a[32*6+:32]  = v_i[32*9 +:32];
		a[32*7+:32]  = v_i[32*13 +:32];
		a[32*8+:32]  = v_i[32*2 +:32];
		a[32*9+:32]  = v_i[32*6 +:32];
		a[32*10+:32] = v_i[32*10 +:32];
		a[32*11+:32] = v_i[32*14 +:32];
		a[32*12+:32] = v_i[32*3 +:32];
		a[32*13+:32] = v_i[32*7 +:32];
		a[32*14+:32] = v_i[32*11 +:32];
		a[32*15+:32] = v_i[32*15 +:32];
	end
	else begin
		a[32*0+:32]  = v_i[32*0 +:32];
		a[32*1+:32]  = v_i[32*5 +:32];
		a[32*2+:32]  = v_i[32*10 +:32];
		a[32*3+:32]  = v_i[32*15 +:32];
		a[32*4+:32]  = v_i[32*1 +:32];
		a[32*5+:32]  = v_i[32*6 +:32];
		a[32*6+:32]  = v_i[32*11 +:32];
		a[32*7+:32]  = v_i[32*12 +:32];
		a[32*8+:32]  = v_i[32*2 +:32];
		a[32*9+:32]  = v_i[32*7 +:32];
		a[32*10+:32] = v_i[32*8 +:32];
		a[32*11+:32] = v_i[32*13 +:32];
		a[32*12+:32] = v_i[32*3 +:32];
		a[32*13+:32] = v_i[32*4 +:32];
		a[32*14+:32] = v_i[32*9 +:32];
		a[32*15+:32] = v_i[32*14 +:32];
	end
end

always @(*)begin
	if(~mode_sel)begin
		v_o[32*0 +:32]  = b[32*0+:32]; 
		v_o[32*4 +:32]  = b[32*1+:32]; 
		v_o[32*8 +:32]  = b[32*2+:32]; 
		v_o[32*12 +:32] = b[32*3+:32]; 
		v_o[32*1 +:32]  = b[32*4+:32]; 
		v_o[32*5 +:32]  = b[32*5+:32]; 
		v_o[32*9 +:32]  = b[32*6+:32]; 
		v_o[32*13 +:32] = b[32*7+:32]; 
		v_o[32*2 +:32]  = b[32*8+:32]; 
		v_o[32*6 +:32]  = b[32*9+:32]; 
		v_o[32*10 +:32] = b[32*10+:32];
		v_o[32*14 +:32] = b[32*11+:32];
		v_o[32*3 +:32]  = b[32*12+:32];
		v_o[32*7 +:32]  = b[32*13+:32];
		v_o[32*11 +:32] = b[32*14+:32];
		v_o[32*15 +:32] = b[32*15+:32];
	end
	else begin
		v_o[32*0 +:32]  = b[32*0+:32]; 
		v_o[32*5 +:32]  = b[32*1+:32]; 
		v_o[32*10 +:32] = b[32*2+:32]; 
		v_o[32*15 +:32] = b[32*3+:32]; 
		v_o[32*1 +:32]  = b[32*4+:32]; 
		v_o[32*6 +:32]  = b[32*5+:32]; 
		v_o[32*11 +:32] = b[32*6+:32]; 
		v_o[32*12 +:32] = b[32*7+:32]; 
		v_o[32*2 +:32]  = b[32*8+:32]; 
		v_o[32*7 +:32]  = b[32*9+:32]; 
		v_o[32*8 +:32]  = b[32*10+:32];
		v_o[32*13 +:32] = b[32*11+:32];
		v_o[32*3 +:32]  = b[32*12+:32];
		v_o[32*4 +:32]  = b[32*13+:32];
		v_o[32*9 +:32]  = b[32*14+:32];
		v_o[32*14 +:32] = b[32*15+:32];
	end
end

G U0_G(
	.a_i(a[32*0+:32]),
	.b_i(a[32*1+:32]),
	.c_i(a[32*2+:32]),
	.d_i(a[32*3+:32]),
	.para0(m[32*0+:32]),
	.para1(m[32*1+:32]),

	.a_o(b[32*0+:32]),
	.b_o(b[32*1+:32]),
	.c_o(b[32*2+:32]),
	.d_o(b[32*3+:32])
);

G U1_G(
	.a_i(a[32*4+:32]),
	.b_i(a[32*5+:32]),
	.c_i(a[32*6+:32]),
	.d_i(a[32*7+:32]),
	.para0(m[32*2+:32]),
	.para1(m[32*3+:32]),

	.a_o(b[32*4+:32]),
	.b_o(b[32*5+:32]),
	.c_o(b[32*6+:32]),
	.d_o(b[32*7+:32])
);

G U2_G(
	.a_i(a[32*8+:32]),
	.b_i(a[32*9+:32]),
	.c_i(a[32*10+:32]),
	.d_i(a[32*11+:32]),
	.para0(m[32*4+:32]),
	.para1(m[32*5+:32]),

	.a_o(b[32*8+:32]),
	.b_o(b[32*9+:32]),
	.c_o(b[32*10+:32]),
	.d_o(b[32*11+:32])
);

G U3_G(
	.a_i(a[32*12+:32]),
	.b_i(a[32*13+:32]),
	.c_i(a[32*14+:32]),
	.d_i(a[32*15+:32]),
	.para0(m[32*6+:32]),
	.para1(m[32*7+:32]),

	.a_o(b[32*12+:32]),
	.b_o(b[32*13+:32]),
	.c_o(b[32*14+:32]),
	.d_o(b[32*15+:32])
);
endmodule
