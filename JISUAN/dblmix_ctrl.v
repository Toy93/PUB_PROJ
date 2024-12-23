/*************************************************************************
    # File Name: dblmix_ctrl.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Sat 09 Apr 2022 11:08:49 AM EDT
    # Last Modified:2022-04-16 22:48
    # Update Count:146
*************************************************************************/
module DBLMIX_CTRL#(
	parameter PASSWD_LEN = 80 ,
	parameter BLOCK_SIZE = 256,
	parameter AWIDTH	 = 7  ,
	parameter NBPIPE     = 3  ,
	parameter DWIDTH     = BLOCK_SIZE*8
)(
	input						clk				,		
	input						rst_n			,	

//interface with JS_FST_KDF	
	input						in_vld			,
	output						in_rdy			,
	input	[BLOCK_SIZE*8 -1:0]	x_in			,			
	input	[BLOCK_SIZE*8 -1:0]	z_in			,			
	input   [PASSWD_LEN*8 - 1:0]password		,
                        
//interface with DBLMIX_WRITE	
	output reg					write_out_vld	,	
	input			    		write_out_rdy	,	
	output	[BLOCK_SIZE*8 -1:0]	write_x_out		,		
	output	[BLOCK_SIZE*8 -1:0]	write_z_out		,		
	input						write_in_vld	,	
	output reg		        	write_in_rdy	,	
	input	[BLOCK_SIZE*8 -1:0]	write_x_in		,		
	input	[BLOCK_SIZE*8 -1:0]	write_z_in		,		
                        
//interface with DBLMIX_READ 
	output reg					read_out_vld	,	
	input			    		read_out_rdy	,	
	output	[BLOCK_SIZE*8 -1:0]	read_x_out		,		
	output  [BLOCK_SIZE*8 -1:0]	read_z_out		,		
	input						read_in_vld		,		
	output reg					read_in_rdy		,		
	input	[BLOCK_SIZE*8 -1:0]	read_x_in		,		
	input	[BLOCK_SIZE*8 -1:0]	read_z_in		,		
                        
//interface with SRAM_V0_PING
	output	reg					v0_pi_wea		,	
	output	reg            		v0_pi_regceb	,	
	output  	            	v0_pi_mem_en	,	
	output	reg	[DWIDTH -1:0]	v0_pi_dina		,	
	output		[AWIDTH -1:0]	v0_pi_addra		,	
	output	reg	[AWIDTH -1:0]	v0_pi_addrb		,	
	input		[DWIDTH -1:0]	v0_pi_doutb		,	
                        
//interface with SRAM_V1_PING
	output  reg					v1_pi_wea		,	
	output	reg            		v1_pi_regceb	,	
	output              		v1_pi_mem_en	,	
	output	reg	[DWIDTH -1:0]	v1_pi_dina		,	
	output		[AWIDTH -1:0]	v1_pi_addra		,	
	output	reg	[AWIDTH -1:0]	v1_pi_addrb		,	
	input		[DWIDTH -1:0]	v1_pi_doutb		,	
	                    		
//interface with SRAM_V0_PANG 
	output	reg					v0_pa_wea		,	
	output	reg          		v0_pa_regceb	,	
	output	             		v0_pa_mem_en	,	
	output	reg	[DWIDTH -1:0]	v0_pa_dina		,	
	output		[AWIDTH -1:0]	v0_pa_addra		,	
	output	reg	[AWIDTH -1:0]	v0_pa_addrb		,	
	input		[DWIDTH -1:0]	v0_pa_doutb		,	
	                    		
//interface with SRAM_V1_PANG 
	output	reg					v1_pa_wea		,	
	output	reg       		    v1_pa_regceb	,	
	output          		    v1_pa_mem_en	,	
	output	reg	[DWIDTH -1:0]	v1_pa_dina		,	
	output		[AWIDTH -1:0]	v1_pa_addra		,	
	output	reg	[AWIDTH -1:0]	v1_pa_addrb		,	
	input		[DWIDTH -1:0]	v1_pa_doutb		,	
	                    			
//interface with JS_XOR
	output	[BLOCK_SIZE*8 -1:0] x_out			,	
	output	[BLOCK_SIZE*8 -1:0] z_out			,	
	output						out_vld			,
	input						out_rdy			,
	output reg[PASSWD_LEN*8 - 1:0]password_o
);
//parameter declaration

//signal declaration
reg pp_flag;
reg x0_buffer_rdy;
reg x1_buffer_rdy;
reg x0_finial_vld;
reg x1_finial_vld;
reg write_out_vld_en;
reg read_out_vld_en;
reg [BLOCK_SIZE*8 -1:0]x0_buffer;
reg [BLOCK_SIZE*8 -1:0]x1_buffer;
reg [BLOCK_SIZE*8 -1:0]z0_buffer;
reg [BLOCK_SIZE*8 -1:0]z1_buffer;
reg [BLOCK_SIZE*8 -1:0]v_xbuffer;
reg [BLOCK_SIZE*8 -1:0]v_zbuffer;
reg [PASSWD_LEN*8 - 1:0]password_buf;
reg [1:0]x0_buffer_vld;//0:invalid 1:valid 2:finial valid
reg [1:0]x1_buffer_vld;//0:invalid 1:valid 2:finial valid
reg [7:0]write_cnt;
reg [7:0]read_cnt;

wire pp_switch_flag;
wire [6:0]x_trunc;
wire [6:0]z_trunc;
//main_code

assign in_rdy = x0_buffer_rdy;

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		x0_buffer_rdy <= 1'b1;
	end
	else if(in_vld & in_rdy)begin
		x0_buffer_rdy <= 1'b0;
	end
	else if(x0_buffer_vld == 2'd2 && x1_buffer_rdy)begin
		x0_buffer_rdy <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		x1_buffer_rdy <= 1'b1;
	end
	else if(x0_buffer_vld == 2'd2 && x1_buffer_rdy)begin
		x1_buffer_rdy <= 1'b0;
	end
	else if(x1_buffer_vld == 2'd2 && out_rdy)begin
		x1_buffer_rdy <= 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		x0_buffer_vld <= 2'd0;
	end
	else if(in_vld&in_rdy)begin
		x0_buffer_vld <= 2'd1;
	end
	else if(write_in_vld & write_in_rdy)begin
		if(x0_finial_vld)begin
			x0_buffer_vld <= 2'd2;
		end
		else begin
			x0_buffer_vld <= 2'd1;
		end
	end
	else if(write_out_vld & write_out_rdy)begin
		x0_buffer_vld <= 2'd0;
	end
	else if(x0_buffer_vld == 2'd2 && x1_buffer_rdy)begin
		x0_buffer_vld <= 2'd0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		x1_buffer_vld <= 2'd0;
	end
	else if(x0_buffer_vld == 2'd2 & x1_buffer_rdy)begin
		x1_buffer_vld <= 2'd1;
	end
	else if(read_in_vld&read_in_rdy)begin
		if(x1_finial_vld)begin
			x1_buffer_vld <= 2'd2;
		end
		else begin
			x1_buffer_vld <= 2'd1;
		end
	end
	else if(read_out_vld & read_out_rdy)begin
		x1_buffer_vld <= 2'd0;
	end
	else if(x1_buffer_vld == 2'd2 && out_rdy)begin
		x1_buffer_vld <= 2'd0;
	end
end

assign out_vld = (x1_buffer_vld == 2'd2)? 1 : 0;

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		x0_buffer <= x_in;
	end
	else if(write_in_vld&write_in_rdy)begin
		x0_buffer <= write_x_in;
	end
end

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		password_buf <= password;
	end
end

always @(posedge clk)begin
	if(x0_buffer_vld == 2'd2 & x1_buffer_rdy)begin
		x1_buffer <= x0_buffer;
	end
	else if(read_in_vld&read_in_rdy)begin
		x1_buffer <= read_x_in;
	end
end

always @(posedge clk)begin
	if(x0_buffer_vld == 2'd2 & x1_buffer_rdy)begin
		password_o <= password_buf;
	end
end
always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		z0_buffer <= z_in;
	end
	else if(write_in_vld&write_in_rdy)begin
		z0_buffer <= write_z_in;
	end
end

always @(posedge clk)begin
	if(x0_buffer_vld == 2'd2 & x1_buffer_rdy)begin
		z1_buffer <= z0_buffer;
	end
	else if(read_in_vld&read_in_rdy)begin
		z1_buffer <= read_z_in;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		write_cnt <= 8'd0;
	end
	else if(in_vld&in_rdy)begin
		write_cnt <= write_cnt + 1'b1;
	end
	else if(x0_finial_vld)begin
		write_cnt <= 8'd0;
	end
	else if(write_in_vld & write_in_rdy)begin
		write_cnt <= write_cnt + 1'b1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		read_cnt <= 8'd0;
	end
	else if(x0_buffer_vld == 2'd2 && x1_buffer_rdy)begin
		read_cnt <= read_cnt + 1'b1;
	end
	else if(x1_finial_vld)begin
		read_cnt <= 8'd0;
	end
	else if(read_in_vld&read_in_rdy)begin
		read_cnt <= read_cnt + 1'b1;
	end
end

assign pp_switch_flag = (x0_buffer_vld == 2'd2) & x1_buffer_rdy;
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		pp_flag <= 1'b0;
	end
	else if(pp_switch_flag) begin
		pp_flag <= ~pp_flag;
	end//0:ping ,1:pang
end

always @(*)begin
	if(write_cnt == 8'd128 & (write_in_vld & write_in_rdy))begin
		x0_finial_vld = 1'b1;
	end
	else begin
		x0_finial_vld = 1'b0;
	end
end

always @(*)begin
	if(read_cnt == 8'd128 && (read_in_vld & read_in_rdy))begin
		x1_finial_vld = 1'b1;
	end
	else begin
		x1_finial_vld = 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		write_out_vld_en <= 1'b0;
	end
	else if(in_vld&in_rdy)begin
		write_out_vld_en <= 1'b1;
	end
	else if(write_cnt == 8'd127 & (write_in_vld & write_in_rdy))begin
		write_out_vld_en <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		write_out_vld <= 1'b0;
	end
	else if(in_vld & in_rdy)begin
		write_out_vld <= 1'b1;
	end
	else if(write_out_vld_en)begin
		if(write_in_vld & write_in_rdy)begin
			write_out_vld <= 1'b1;
		end
		else if(write_out_vld & write_out_rdy)begin
			write_out_vld <= 1'b0;
		end
	end
	else if(write_out_vld & write_out_rdy)begin
		write_out_vld <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		read_out_vld_en <= 1'b0;
	end
	else if((x0_buffer_vld == 2'd2) & x1_buffer_rdy)begin
		read_out_vld_en <= 1'b1;
	end
	else if(read_cnt == 8'd127 & (read_in_vld & read_in_rdy))begin
		read_out_vld_en <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		read_out_vld <= 1'b0;
	end
	else if(x0_buffer_vld == 2'd2 & x1_buffer_rdy)begin
		read_out_vld <= 1'b1;
	end
	else if(read_out_vld_en)begin
		if(read_in_vld & read_in_rdy)begin
			read_out_vld <= 1'b1;
		end
		else if(read_out_vld&read_out_rdy)begin
			read_out_vld <= 1'b0;
		end
	end
	else if(read_out_vld&read_out_rdy)begin
		read_out_vld <= 1'b0;
	end
end

always @(*)begin
	if(x0_buffer_vld == 2'd0)begin
		write_in_rdy = 1'b1;
	end
	else if((x0_buffer_vld == 2'd1) & write_out_rdy)begin
		write_in_rdy = 1'b1;
	end
	else if((x0_buffer_vld == 2'd2) & x1_buffer_rdy)begin
		write_in_rdy = 1'b1;
	end
	else begin
		write_in_rdy = 1'b0;
	end
end

always @(*)begin
	if(x1_buffer_vld == 2'd0)begin
		read_in_rdy = 1'b1;
	end
	else if((x1_buffer_vld == 2'd1) & read_out_rdy)begin
		read_in_rdy = 1'b1;
	end
	else if((x1_buffer_vld == 2'd2) & out_rdy)begin
		read_in_rdy = 1'b1;
	end
	else begin
		read_in_rdy = 1'b0;
	end
end

assign v0_pi_mem_en = v0_pi_wea | v0_pi_regceb;
assign v1_pi_mem_en = v1_pi_wea | v1_pi_regceb;
assign v0_pa_mem_en = v0_pa_wea | v0_pa_regceb;
assign v1_pa_mem_en = v1_pa_wea | v1_pa_regceb;

always @(*)begin
	if(~pp_flag)begin
		if(x0_finial_vld)begin
			v0_pi_wea = 1'b0;//x
			v1_pi_wea = 1'b0;//z
			v0_pi_dina  = {DWIDTH{1'b0}};
			v1_pi_dina  = {DWIDTH{1'b0}};
		end
		else if(in_vld&in_rdy)begin
			v0_pi_wea = 1'b1;
			v1_pi_wea = 1'b1;
			v0_pi_dina  = x_in;
			v1_pi_dina  = z_in;
		end
		else if(write_in_vld&write_in_rdy)begin
			v0_pi_wea = 1'b1;
			v1_pi_wea = 1'b1;
			v0_pi_dina  = write_x_in;
			v1_pi_dina  = write_z_in;
		end
		else begin
			v0_pi_wea = 1'b0;
			v1_pi_wea = 1'b0;
			v0_pi_dina  = {DWIDTH{1'b0}};
			v1_pi_dina  = {DWIDTH{1'b0}};
		end
	end//ping
	else begin
		v0_pi_wea = 1'b0;
		v1_pi_wea = 1'b0;
		v0_pi_dina  = {DWIDTH{1'b0}};
		v1_pi_dina  = {DWIDTH{1'b0}};
	end//pang
end
assign v0_pi_addra = write_cnt;
assign v1_pi_addra = write_cnt;

always @(*)begin
	if(~pp_flag)begin//write ping read pang
		v0_pa_wea = 1'b0;
		v1_pa_wea = 1'b0;
		v0_pa_dina  = {DWIDTH{1'b0}};
		v1_pa_dina  = {DWIDTH{1'b0}};
	end//ping
	else begin
		if(x0_finial_vld)begin
			v0_pa_wea = 1'b0;
			v1_pa_wea = 1'b0;
			v0_pa_dina  = {DWIDTH{1'b0}};
			v1_pa_dina  = {DWIDTH{1'b0}};
		end
		else if(in_vld&in_rdy)begin
			v0_pa_wea = 1'b1;
			v1_pa_wea = 1'b1;
			v0_pa_dina  = x_in;
			v1_pa_dina  = z_in;
		end//write pang
		else if(write_in_vld&write_in_rdy)begin
			v0_pa_wea = 1'b1;
			v1_pa_wea = 1'b1;
			v0_pa_dina  = write_x_in;
			v1_pa_dina  = write_z_in;
		end//write pang
		else begin
			v0_pa_wea = 1'b0;
			v1_pa_wea = 1'b0;
			v0_pa_dina  = {DWIDTH{1'b0}};
			v1_pa_dina  = {DWIDTH{1'b0}};
		end
	end//pang
end
assign v0_pa_addra = write_cnt;
assign v1_pa_addra = write_cnt;

always @(*)begin
	if(~pp_flag)begin
		if(pp_switch_flag)begin
			v0_pi_addrb = x_trunc;
			v1_pi_addrb = z_trunc;
		end
		else begin
			v0_pi_addrb = {AWIDTH{1'b0}};
			v1_pi_addrb = {AWIDTH{1'b0}};
		end
	end//ping
	else begin
		v0_pi_addrb = x_trunc;
		v1_pi_addrb = z_trunc;
	end//pang
end

always @(*)begin
	if(~pp_flag)begin
		v0_pa_addrb = x_trunc;
		v1_pa_addrb = z_trunc;
	end//ping
	else begin
		if(pp_switch_flag)begin
			v0_pa_addrb = x_trunc;
			v1_pa_addrb = z_trunc;
		end
		else begin
			v0_pa_addrb = {AWIDTH{1'b0}};
			v1_pa_addrb = {AWIDTH{1'b0}};
		end
	end//pang
end

always @(*)begin
	if(~pp_flag)begin
		if(pp_switch_flag)begin
			v0_pi_regceb = 1'b1;
			v1_pi_regceb = 1'b1;
		end
		else begin
			v0_pi_regceb = 1'b0;
			v1_pi_regceb = 1'b0;
		end
	end
	else begin
		if(x1_finial_vld)begin
			v0_pi_regceb = 1'b0;
			v1_pi_regceb = 1'b0;
		end
		else if(read_in_vld&read_in_rdy)begin
			v0_pi_regceb = 1'b1;
			v1_pi_regceb = 1'b1;
		end
		else begin
			v0_pi_regceb = 1'b0;
			v1_pi_regceb = 1'b0;
		end
	end
end

always @(*)begin
	if(~pp_flag)begin
		if(x1_finial_vld)begin
			v0_pa_regceb = 1'b0;
			v1_pa_regceb = 1'b0;
		end
		else if(read_in_vld&read_in_rdy)begin
			v0_pa_regceb = 1'b1;
			v1_pa_regceb = 1'b1;
		end
		else begin
			v0_pa_regceb = 1'b0;
			v1_pa_regceb = 1'b0;
		end
	end
	else begin
		if(pp_switch_flag)begin
			v0_pa_regceb = 1'b1;
			v1_pa_regceb = 1'b1;
		end
		else begin
			v0_pa_regceb = 1'b0;
			v1_pa_regceb = 1'b0;
		end
	end
end

always @(posedge clk)begin
	if(v0_pi_regceb)begin
		v_xbuffer <= v0_pi_doutb;
	end
	else if(v0_pa_regceb)begin
		v_xbuffer <= v0_pa_doutb;
	end
end

always @(posedge clk)begin
	if(v1_pi_regceb)begin
		v_zbuffer <= v1_pi_doutb;
	end
	else if(v1_pa_regceb)begin
		v_zbuffer <= v1_pa_doutb;
	end
end
assign write_x_out = x0_buffer;
assign write_z_out = z0_buffer;
assign read_x_out = x1_buffer ^ v_xbuffer;
assign read_z_out = z1_buffer ^ v_zbuffer;
assign x_out = x1_buffer;
assign z_out = z1_buffer;
assign x_trunc = pp_switch_flag ? x0_buffer[48*32+:7] : read_x_in[48*32+:7]; 
assign z_trunc = pp_switch_flag ? z0_buffer[48*32+:7] : read_z_in[48*32+:7]; 
endmodule
