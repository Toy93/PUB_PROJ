/*************************************************************************
    # File Name: h_calc.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:29:12 AM EDT
    # Last Modified:2022-04-06 11:42
    # Update Count:53
*************************************************************************/
module H_CALC(
	input						clk			,
	input						rst_n		,
	
	//interface with BLK2S_CTRL
	input						in_vld		,
	input		[32*2 -1:0]		t			,
	input		[32*2 -1:0]		f			,
	input		[32*16 -1:0]	m			,
	input		[32*8 -1:0]		hi			,
	output reg					out_vld		,
	output		[32*8 -1:0]		ho			
);
wire [32*16 -1:0]	hcalc_v_i		;
wire [32*8 -1:0]	hcalc_m_h		;
wire [32*16 -1:0]	v_o				;
wire [31:0]         blake2s_iv[7:0]	;

reg					mode_sel ;
reg					calc_vld ;
reg  [32*16 -1:0]	m_buf	 ;
reg  [32*16 -1:0]	v_buf	 ;
reg  [32*8 - 1:0]	m_pick	 ;
reg  [3:0]			round_cnt;

always @(posedge clk)begin
	if(in_vld)begin
		m_buf <= m;
	end
end

assign blake2s_iv[0] = 32'h6A09E667;
assign blake2s_iv[1] = 32'hBB67AE85;
assign blake2s_iv[2] = 32'h3C6EF372;
assign blake2s_iv[3] = 32'hA54FF53A;
assign blake2s_iv[4] = 32'h510E527F;
assign blake2s_iv[5] = 32'h9B05688C;
assign blake2s_iv[6] = 32'h1F83D9AB;
assign blake2s_iv[7] = 32'h5BE0CD19;

always @(posedge clk)begin
	if(in_vld)begin
		v_buf[0 +:8*32]   <= hi;
		v_buf[32*8 +:32]  <= blake2s_iv[0];
		v_buf[32*9 +:32]  <= blake2s_iv[1];
		v_buf[32*10 +:32] <= blake2s_iv[2];
		v_buf[32*11 +:32] <= blake2s_iv[3];
		v_buf[32*12 +:32] <= blake2s_iv[4]^t[31:0];
		v_buf[32*13 +:32] <= blake2s_iv[5]^t[63:32];
		v_buf[32*14 +:32] <= blake2s_iv[6]^f[31:0];
		v_buf[32*15 +:32] <= blake2s_iv[7]^f[63:32];
	end
	else if(calc_vld)begin
		v_buf <= v_o;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		calc_vld <= 1'b0;
	end
	else if(in_vld)begin
		calc_vld <= 1'b1;
	end
	else if(round_cnt == 4'd9 && mode_sel)begin
		calc_vld <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		round_cnt <= 4'd0;
	end
	else if(calc_vld)begin
		if(round_cnt == 4'd9 && mode_sel)begin
			round_cnt <= 4'd0;
		end
		else if(mode_sel)begin
			round_cnt <= round_cnt + 1'b1;
		end
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		mode_sel <= 4'd0;
	end
	else if(calc_vld)begin
		mode_sel <= ~mode_sel;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld <= 1'b0;
	end
	else if(round_cnt == 4'd9 && mode_sel)begin
		out_vld <= 1'b1;
	end
	else begin
		out_vld <= 1'b0;
	end
end

assign ho[32*0 +:32] = v_buf[32*0 +:32]^v_buf[32*8  +:32]; 
assign ho[32*1 +:32] = v_buf[32*1 +:32]^v_buf[32*9  +:32]; 
assign ho[32*2 +:32] = v_buf[32*2 +:32]^v_buf[32*10 +:32]; 
assign ho[32*3 +:32] = v_buf[32*3 +:32]^v_buf[32*11 +:32]; 
assign ho[32*4 +:32] = v_buf[32*4 +:32]^v_buf[32*12 +:32]; 
assign ho[32*5 +:32] = v_buf[32*5 +:32]^v_buf[32*13 +:32]; 
assign ho[32*6 +:32] = v_buf[32*6 +:32]^v_buf[32*14 +:32]; 
assign ho[32*7 +:32] = v_buf[32*7 +:32]^v_buf[32*15 +:32]; 

always @(*)begin
	if(~mode_sel)begin
		case(round_cnt)
			0:begin
				m_pick = {m_buf[32*7+:32],m_buf[32*6+:32],m_buf[32*5+:32],m_buf[32*4+:32],
						  m_buf[32*3+:32],m_buf[32*2+:32],m_buf[32*1+:32],m_buf[32*0+:32]};
			end
			1:begin
				m_pick = {m_buf[32*6+:32],m_buf[32*13+:32],m_buf[32*15+:32],m_buf[32*9+:32],
						  m_buf[32*8+:32],m_buf[32*4+:32],m_buf[32*10+:32],m_buf[32*14+:32]};
			end
			2:begin
				m_pick = {m_buf[32*13+:32],m_buf[32*15+:32],m_buf[32*2+:32],m_buf[32*5+:32],
						  m_buf[32*0+:32],m_buf[32*12+:32],m_buf[32*8+:32],m_buf[32*11+:32]};
			end
			3:begin
				m_pick = {m_buf[32*14+:32],m_buf[32*11+:32],m_buf[32*12+:32],m_buf[32*13+:32],
						  m_buf[32*1+:32],m_buf[32*3+:32],m_buf[32*9+:32],m_buf[32*7+:32]};
			end
			4:begin
				m_pick = {m_buf[32*15+:32],m_buf[32*10+:32],m_buf[32*4+:32],m_buf[32*2+:32],
						  m_buf[32*7+:32],m_buf[32*5+:32],m_buf[32*0+:32],m_buf[32*9+:32]};
			end
			5:begin
				m_pick = {m_buf[32*3+:32],m_buf[32*8+:32],m_buf[32*11+:32],m_buf[32*0+:32],
						  m_buf[32*10+:32],m_buf[32*6+:32],m_buf[32*12+:32],m_buf[32*2+:32]};
			end
			6:begin
				m_pick = {m_buf[32*10+:32],m_buf[32*4+:32],m_buf[32*13+:32],m_buf[32*14+:32],
						  m_buf[32*15+:32],m_buf[32*1+:32],m_buf[32*5+:32],m_buf[32*12+:32]};
			end
			7:begin
				m_pick = {m_buf[32*9+:32],m_buf[32*3+:32],m_buf[32*1+:32],m_buf[32*12+:32],
						  m_buf[32*14+:32],m_buf[32*7+:32],m_buf[32*11+:32],m_buf[32*13+:32]};
			end
			8:begin
				m_pick = {m_buf[32*8+:32],m_buf[32*0+:32],m_buf[32*3+:32],m_buf[32*11+:32],
						  m_buf[32*9+:32],m_buf[32*14+:32],m_buf[32*15+:32],m_buf[32*6+:32]};
			end
			9:begin
				m_pick = {m_buf[32*5+:32],m_buf[32*1+:32],m_buf[32*6+:32],m_buf[32*7+:32],
						  m_buf[32*4+:32],m_buf[32*8+:32],m_buf[32*2+:32],m_buf[32*10+:32]};
			end
			default:begin
				m_pick = 256'd0;
			end
		endcase
	end
	else begin
		case(round_cnt)
			0:begin
				m_pick = {m_buf[32*15+:32],m_buf[32*14+:32],m_buf[32*13+:32],m_buf[32*12+:32],
						  m_buf[32*11+:32],m_buf[32*10+:32],m_buf[32*9+:32],m_buf[32*8+:32]};
			end
			1:begin
				m_pick = {m_buf[32*3+:32],m_buf[32*5+:32],m_buf[32*7+:32],m_buf[32*11+:32],
						  m_buf[32*2+:32],m_buf[32*0+:32],m_buf[32*12+:32],m_buf[32*1+:32]};
			end
			2:begin
				m_pick = {m_buf[32*4+:32],m_buf[32*9+:32],m_buf[32*1+:32],m_buf[32*7+:32],
						  m_buf[32*6+:32],m_buf[32*3+:32],m_buf[32*14+:32],m_buf[32*10+:32]};
			end
			3:begin
				m_pick = {m_buf[32*8+:32],m_buf[32*15+:32],m_buf[32*0+:32],m_buf[32*4+:32],
						  m_buf[32*10+:32],m_buf[32*5+:32],m_buf[32*6+:32],m_buf[32*2+:32]};
			end
			4:begin
				m_pick = {m_buf[32*13+:32],m_buf[32*3+:32],m_buf[32*8+:32],m_buf[32*6+:32],
						  m_buf[32*12+:32],m_buf[32*11+:32],m_buf[32*1+:32],m_buf[32*14+:32]};
			end
			5:begin
				m_pick = {m_buf[32*9+:32],m_buf[32*1+:32],m_buf[32*14+:32],m_buf[32*15+:32],
						  m_buf[32*5+:32],m_buf[32*7+:32],m_buf[32*13+:32],m_buf[32*4+:32]};
			end
			6:begin
				m_pick = {m_buf[32*11+:32],m_buf[32*8+:32],m_buf[32*2+:32],m_buf[32*9+:32],
						  m_buf[32*3+:32],m_buf[32*6+:32],m_buf[32*7+:32],m_buf[32*0+:32]};
			end
			7:begin
				m_pick = {m_buf[32*10+:32],m_buf[32*2+:32],m_buf[32*6+:32],m_buf[32*8+:32],
						  m_buf[32*4+:32],m_buf[32*15+:32],m_buf[32*0+:32],m_buf[32*5+:32]};
			end
			8:begin
				m_pick = {m_buf[32*5+:32],m_buf[32*10+:32],m_buf[32*4+:32],m_buf[32*1+:32],
						  m_buf[32*7+:32],m_buf[32*13+:32],m_buf[32*2+:32],m_buf[32*12+:32]};
			end
			9:begin
				m_pick = {m_buf[32*0+:32],m_buf[32*13+:32],m_buf[32*12+:32],m_buf[32*3+:32],
						  m_buf[32*14+:32],m_buf[32*9+:32],m_buf[32*11+:32],m_buf[32*15+:32]};
			end
			default:begin
				m_pick = 256'd0;
			end//combination logic can be optimized to sequentical logic
		endcase
	end
end

ROUND U_ROUND(
	.mode_sel(mode_sel),
    .v_i     (v_buf   ),//input data v15~v0
	.m	     (m_pick),
                      
    .v_o     (v_o     )//output data v15~v0
);

endmodule
