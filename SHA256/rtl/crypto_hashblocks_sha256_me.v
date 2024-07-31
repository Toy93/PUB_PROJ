// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/03 08:08
// Last Modified : 2024/07/18 22:26
// File Name     : crypto_hashblocks_sha256_me.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/03   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module CRYPTO_HASHBLOCKS_SHA256_ME(
	input               clk          , 
	input               rst_n        , 
    
	input               start        , 
	input               block_1st    , 
	input               pub_seed     , 
	input               block_final  , 
	input   [255:0]     statebytes_i , 
	input   [511:0]     in           , 
	input   [6:0]       len          , 
    
	output  reg         dout_vld     , 
	output  reg [255:0] statebytes_o

);
//PARAMETER DEFINE
//---------------------------------------------------------------------------------head
	parameter IDEL       = 0;
	parameter FM32_CAL   = 1;
	parameter STATE_INIT = 2;
	parameter IV_A_INIT_VAL = {8'h6a, 8'h09, 8'he6, 8'h67};
	parameter IV_B_INIT_VAL = {8'hbb, 8'h67, 8'hae, 8'h85};
	parameter IV_C_INIT_VAL = {8'h3c, 8'h6e, 8'hf3, 8'h72};
	parameter IV_D_INIT_VAL = {8'ha5, 8'h4f, 8'hf5, 8'h3a};
	parameter IV_E_INIT_VAL = {8'h51, 8'h0e, 8'h52, 8'h7f};
	parameter IV_F_INIT_VAL = {8'h9b, 8'h05, 8'h68, 8'h8c};
	parameter IV_G_INIT_VAL = {8'h1f, 8'h83, 8'hd9, 8'hab};
	parameter IV_H_INIT_VAL = {8'h5b, 8'he0, 8'hcd, 8'h19};

//---------------------------------------------------------------------------------tail

/*autowire*/
    //Start of automatic wire
    //Define assign wires here
    wire                        fm32_cal_en                     ;
    wire                        one_fm32_done                   ;
    wire                        four_fm32_done                  ;
    //Define instance wires here
    wire [3:0]                  addr                            ;
    //End of automatic wire
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

/*autoreg*/
    //Start of automatic reg
    //Define flip-flop registers here
    reg  [1:0]                  cnt0                            ;
    reg  [1:0]                  cnt1                            ;
    reg  [6:0]                  len_lock                        ;
    reg                         pub_seed_lock        ; // REG_NEW
    reg                         exist_pub_seed         ;
    reg  [255:0]                sha256_pub_seed                 ;
    reg  [60:0]                 sum_len                       ; // REG_NEW
    //Define combination registers here
    //End of automatic reg
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//WIRE DEFINE
//---------------------------------------------------------------------------------head
    wire [31:0]                a_add_state                     ;
    wire [31:0]                b_add_state                     ;
    wire [31:0]                c_add_state                     ;
    wire [31:0]                d_add_state                     ;
    wire [31:0]                e_add_state                     ;
    wire [31:0]                f_add_state                     ;
    wire [31:0]                g_add_state                     ;
    wire [31:0]                h_add_state                     ;
    wire [31:0]                 k[7:0]                         ;
    wire [31:0]                a_i[8:0]                     ;
    wire [31:0]                b_i[8:0]                     ;
    wire [31:0]                c_i[8:0]                     ;
    wire [31:0]                d_i[8:0]                     ;
    wire [31:0]                e_i[8:0]                     ;
    wire [31:0]                f_i[8:0]                     ;
    wire [31:0]                g_i[8:0]                     ;
    wire [31:0]                h_i[8:0]                     ;
    wire [31:0]                w0_o[7:0];
    wire [60:0]                sum_len_comb                 ; // WIRE_NEW
//---------------------------------------------------------------------------------tail

//REG DEFINE
//---------------------------------------------------------------------------------head
    reg  [31:0]             a                               ;
    reg  [31:0]             b                               ;
    reg  [31:0]             c                               ;
    reg  [31:0]             d                               ;
    reg  [31:0]             e                               ;
    reg  [31:0]             f                               ;
    reg  [31:0]             g                               ;
    reg  [31:0]             h                               ;
    reg  [31:0]             w[15:0]                         ;
    reg  [1:0]              state_c							;
    reg  [1:0]              state_n                			;
    reg  [31:0]             w0_i[7:0]                       ;
    reg  [31:0]             w1_i[7:0];
    reg  [31:0]             w2_i[7:0];
    reg  [31:0]             w3_i[7:0];
//---------------------------------------------------------------------------------tail

//main code
//---------------------------------------------------------------------------------head
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			state_c <= IDEL;
		end
		else begin
			state_c <= state_n;
		end
	end

	always@(*)begin
		case(state_c)
			IDEL:begin
                if(start & (~exist_pub_seed | ~pub_seed))begin
					state_n = FM32_CAL;
                end
                else begin
                    state_n = state_c;
                end
            end
            FM32_CAL:begin
                if(four_fm32_done)begin
					state_n = STATE_INIT;
                end
				else begin
					state_n = state_c;
				end
            end
            STATE_INIT:begin
				if(len_lock <= 127)begin
					state_n = IDEL;
				end
				else begin
					state_n = FM32_CAL;
				end
            end
            default:begin
                state_n = IDEL;
            end
		endcase
    end

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			cnt0 <= 2'd0;
		end
		else begin
			case(state_c)
				FM32_CAL:begin
					if(cnt1==2'd1)begin
						if(cnt0 != 2'd3)begin
							cnt0 <= cnt0+2'd1;
						end
					end
				end
				STATE_INIT:begin
					cnt0 <= 2'd0;
				end
			endcase
		end
	end

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			cnt1 <= 2'd0;
		end
		else begin
			case(state_c)
				FM32_CAL:begin
					if(cnt0 != 2'd3 || cnt1 != 2'd1)begin
						if(cnt1 == 2'd1)begin
							cnt1 <= 2'd0;
						end
						else begin
							cnt1 <= cnt1+2'd1;
						end
					end
				end
				STATE_INIT:begin
					cnt1 <= 2'd0;
				end
			endcase
		end
	end

	assign addr = 2*cnt0+cnt1;
	KROM U_KROM(/*autoinst*/
        .addr                   (addr[3:0]                      ), //input
        .k0                     (k[0]                           ), //output
        .k1                     (k[1]                           ), //output
        .k2                     (k[2]                           ), //output
        .k3                     (k[3]                           ), //output
        .k4                     (k[4]                           ), //output
        .k5                     (k[5]                           ), //output
        .k6                     (k[6]                           ), //output
        .k7                     (k[7]                           )  //output
    );
	
	always@(posedge clk)begin
		case(state_c)
			IDEL:begin
				if(block_1st)begin
					a <= IV_A_INIT_VAL;
					b <= IV_B_INIT_VAL;
					c <= IV_C_INIT_VAL;
					d <= IV_D_INIT_VAL;
					e <= IV_E_INIT_VAL;
					f <= IV_F_INIT_VAL;
					g <= IV_G_INIT_VAL;
					h <= IV_H_INIT_VAL;
				end
				else if(start)begin
					a <= statebytes_i[7*32+:32];
					b <= statebytes_i[6*32+:32];
					c <= statebytes_i[5*32+:32];
					d <= statebytes_i[4*32+:32];
					e <= statebytes_i[3*32+:32];
					f <= statebytes_i[2*32+:32];
					g <= statebytes_i[1*32+:32];
					h <= statebytes_i[0*32+:32];
				end
			end
			FM32_CAL:begin
				a <= a_i[8];
				b <= b_i[8];
				c <= c_i[8];
				d <= d_i[8];
				e <= e_i[8];
				f <= f_i[8];
				g <= g_i[8];
				h <= h_i[8];
			end
			STATE_INIT:begin
				a <= a_add_state;
				b <= b_add_state;
				c <= c_add_state;
				d <= d_add_state;
				e <= e_add_state;
				f <= f_add_state;
				g <= g_add_state;
				h <= h_add_state;
			end
		endcase
	end

	always@(posedge clk)begin
		case(state_c)
			IDEL:begin
				if(start)begin
					if(block_final)begin
						case(len)
	7'd1  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:504], 8'h80, 432'd0, sum_len_comb, 3'd0};
	7'd2  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:496], 8'h80, 424'd0, sum_len_comb, 3'd0};
	7'd3  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:488], 8'h80, 416'd0, sum_len_comb, 3'd0};
	7'd4  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:480], 8'h80, 408'd0, sum_len_comb, 3'd0};
	7'd5  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:472], 8'h80, 400'd0, sum_len_comb, 3'd0};
	7'd6  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:464], 8'h80, 392'd0, sum_len_comb, 3'd0};
	7'd7  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:456], 8'h80, 384'd0, sum_len_comb, 3'd0};
	7'd8  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:448], 8'h80, 376'd0, sum_len_comb, 3'd0};
	7'd9  : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:440], 8'h80, 368'd0, sum_len_comb, 3'd0};
	7'd10 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:432], 8'h80, 360'd0, sum_len_comb, 3'd0};
	7'd11 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:424], 8'h80, 352'd0, sum_len_comb, 3'd0};
	7'd12 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:416], 8'h80, 344'd0, sum_len_comb, 3'd0};
	7'd13 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:408], 8'h80, 336'd0, sum_len_comb, 3'd0};
	7'd14 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:400], 8'h80, 328'd0, sum_len_comb, 3'd0};
	7'd15 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:392], 8'h80, 320'd0, sum_len_comb, 3'd0};
	7'd16 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:384], 8'h80, 312'd0, sum_len_comb, 3'd0};
	7'd17 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:376], 8'h80, 304'd0, sum_len_comb, 3'd0};
	7'd18 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:368], 8'h80, 296'd0, sum_len_comb, 3'd0};
	7'd19 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:360], 8'h80, 288'd0, sum_len_comb, 3'd0};
	7'd20 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:352], 8'h80, 280'd0, sum_len_comb, 3'd0};
	7'd21 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:344], 8'h80, 272'd0, sum_len_comb, 3'd0};
	7'd22 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:336], 8'h80, 264'd0, sum_len_comb, 3'd0};
	7'd23 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:328], 8'h80, 256'd0, sum_len_comb, 3'd0};
	7'd24 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:320], 8'h80, 248'd0, sum_len_comb, 3'd0};
	7'd25 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:312], 8'h80, 240'd0, sum_len_comb, 3'd0};
	7'd26 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:304], 8'h80, 232'd0, sum_len_comb, 3'd0};
	7'd27 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:296], 8'h80, 224'd0, sum_len_comb, 3'd0};
	7'd28 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:288], 8'h80, 216'd0, sum_len_comb, 3'd0};
	7'd29 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:280], 8'h80, 208'd0, sum_len_comb, 3'd0};
	7'd30 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:272], 8'h80, 200'd0, sum_len_comb, 3'd0};
	7'd31 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:264], 8'h80, 192'd0, sum_len_comb, 3'd0};
	7'd32 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:256], 8'h80, 184'd0, sum_len_comb, 3'd0};
	7'd33 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:248], 8'h80, 176'd0, sum_len_comb, 3'd0};
	7'd34 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:240], 8'h80, 168'd0, sum_len_comb, 3'd0};
	7'd35 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:232], 8'h80, 160'd0, sum_len_comb, 3'd0};
	7'd36 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:224], 8'h80, 152'd0, sum_len_comb, 3'd0};
	7'd37 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:216], 8'h80, 144'd0, sum_len_comb, 3'd0};
	7'd38 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:208], 8'h80, 136'd0, sum_len_comb, 3'd0};
	7'd39 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:200], 8'h80, 128'd0, sum_len_comb, 3'd0};
	7'd40 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:192], 8'h80, 120'd0, sum_len_comb, 3'd0};
	7'd41 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:184], 8'h80, 112'd0, sum_len_comb, 3'd0};
	7'd42 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:176], 8'h80, 104'd0, sum_len_comb, 3'd0};
	7'd43 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:168], 8'h80,  96'd0, sum_len_comb, 3'd0};
	7'd44 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:160], 8'h80,  88'd0, sum_len_comb, 3'd0};
	7'd45 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:152], 8'h80,  80'd0, sum_len_comb, 3'd0};
	7'd46 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:144], 8'h80,  72'd0, sum_len_comb, 3'd0};
	7'd47 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:136], 8'h80,  64'd0, sum_len_comb, 3'd0};
	7'd48 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:128], 8'h80,  56'd0, sum_len_comb, 3'd0};
	7'd49 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:120], 8'h80,  48'd0, sum_len_comb, 3'd0};
	7'd50 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:112], 8'h80,  40'd0, sum_len_comb, 3'd0};
	7'd51 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:104], 8'h80,  32'd0, sum_len_comb, 3'd0};
	7'd52 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 96], 8'h80,  24'd0, sum_len_comb, 3'd0};
	7'd53 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 88], 8'h80,  16'd0, sum_len_comb, 3'd0};
	7'd54 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 80], 8'h80,   8'd0, sum_len_comb, 3'd0};
	7'd55 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 72], 8'h80, /*0'd0,*/ sum_len_comb, 3'd0};
	7'd56 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 64], 8'h80,  56'd0/*, sum_len_comb, 3'd0*/};
	7'd57 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 56], 8'h80,  48'd0/*, sum_len_comb, 3'd0*/};
	7'd58 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 48], 8'h80,  40'd0/*, sum_len_comb, 3'd0*/};
	7'd59 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 40], 8'h80,  32'd0/*, sum_len_comb, 3'd0*/};
	7'd60 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 32], 8'h80,  24'd0/*, sum_len_comb, 3'd0*/};
	7'd61 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 24], 8'h80,  16'd0/*, sum_len_comb, 3'd0*/};
	7'd62 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511: 16], 8'h80,   8'd0/*, sum_len_comb, 3'd0*/};
	7'd63 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= {in[511:  8], 8'h80/*, 4'd0, sum_len_comb, 3'd0*/};
	7'd64 : {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <=  in;
        				endcase
					end
					else begin
						{w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= in;
					end
				end
			end
			FM32_CAL:begin
				if(cnt0 != 2'd3)begin//?????
					case(cnt1)
						0:begin
							w[0] <= w0_o[0];
							w[1] <= w0_o[1];
							w[2] <= w0_o[2];
							w[3] <= w0_o[3];
							w[4] <= w0_o[4];
							w[5] <= w0_o[5];
							w[6] <= w0_o[6];
							w[7] <= w0_o[7];
						end
						1:begin
							w[8] <= w0_o[0];
							w[9] <= w0_o[1];
							w[10] <= w0_o[2];
							w[11] <= w0_o[3];
							w[12] <= w0_o[4];
							w[13] <= w0_o[5];
							w[14] <= w0_o[6];
							w[15] <= w0_o[7];
						end
					endcase
				end
			end
		endcase
	end
	
	assign a_i[0] = a;
	assign b_i[0] = b;
	assign c_i[0] = c;
	assign d_i[0] = d;
	assign e_i[0] = e;
	assign f_i[0] = f;
	assign g_i[0] = g;
	assign h_i[0] = h;

	always @(*)begin
		case(cnt1)
			0:begin
				w0_i[0] = w[0];
				w1_i[0] = w[14];
				w2_i[0] = w[9]; 
				w3_i[0] = w[1]; 

				w0_i[1] = w[1];
				w1_i[1] = w[15];
				w2_i[1] = w[10];
				w3_i[1] = w[2]; 

				w0_i[2] = w[2]; 
				w1_i[2] = w0_o[0];
				w2_i[2] = w[11]; 
				w3_i[2] = w[3]; 

				w0_i[3] = w[3];
				w1_i[3] = w0_o[1];
				w2_i[3] = w[12]; 
				w3_i[3] = w[4]; 

				w0_i[4] = w[4];
				w1_i[4] = w0_o[2];
				w2_i[4] = w[13]; 
				w3_i[4] = w[5]; 

				w0_i[5] = w[5];
				w1_i[5] = w0_o[3];
				w2_i[5] = w[14];
				w3_i[5] = w[6]; 

				w0_i[6] = w[6]; 
				w1_i[6] = w0_o[4];
				w2_i[6] = w[15]; 
				w3_i[6] = w[7]; 

				w0_i[7] = w[7];
				w1_i[7] = w0_o[5];
				w2_i[7] = w0_o[0]; 
				w3_i[7] = w[8]; 
			end
			default:begin//1
				w0_i[0] = w[8];
				w1_i[0] = w[6];
				w2_i[0] = w[1]; 
				w3_i[0] = w[9]; 

				w0_i[1] = w[9];
				w1_i[1] = w[7];
				w2_i[1] = w[2];
				w3_i[1] = w[10]; 

				w0_i[2] = w[10]; 
				w1_i[2] = w0_o[0];
				w2_i[2] = w[3]; 
				w3_i[2] = w[11]; 

				w0_i[3] = w[11]; 
				w1_i[3] = w0_o[1];
				w2_i[3] = w[4]; 
				w3_i[3] = w[12]; 

				w0_i[4] = w[12];
				w1_i[4] = w0_o[2];
				w2_i[4] = w[5]; 
				w3_i[4] = w[13]; 

				w0_i[5] = w[13];
				w1_i[5] = w0_o[3];
				w2_i[5] = w[6];
				w3_i[5] = w[14]; 

				w0_i[6] = w[14]; 
				w1_i[6] = w0_o[4];
				w2_i[6] = w[7]; 
				w3_i[6] = w[15]; 

				w0_i[7] = w[15];
				w1_i[7] = w0_o[5];
				w2_i[7] = w0_o[0]; 
				w3_i[7] = w[0]; 
			end
		endcase
	end

	generate 
		genvar I;
		for(I = 0; I < 8; I = I+1)begin
			F32 U_F32(/*AUTOINST*/
    		    .a_i                    (a_i[I]                      ), //input
    		    .b_i                    (b_i[I]                      ), //input
    		    .c_i                    (c_i[I]                      ), //input
    		    .d_i                    (d_i[I]                      ), //input
    		    .e_i                    (e_i[I]                      ), //input
    		    .f_i                    (f_i[I]                      ), //input
    		    .g_i                    (g_i[I]                      ), //input
    		    .h_i                    (h_i[I]                      ), //input
    		    .w                      (w0_i[I]                     ), //input
    		    .k                      (k[I]                        ), //input
    		    .a_o                    (a_i[I+1]                    ), //output
    		    .b_o                    (b_i[I+1]                    ), //output
    		    .c_o                    (c_i[I+1]                    ), //output
    		    .d_o                    (d_i[I+1]                    ), //output
    		    .e_o                    (e_i[I+1]                    ), //output
    		    .f_o                    (f_i[I+1]                    ), //output
    		    .g_o                    (g_i[I+1]                    ), //output
    		    .h_o                    (h_i[I+1]                    )  //output
    		);
			
			M32 U_M32(/*autoinst*/
    		    .w0_i                   (w0_i[I]                     ), //input
    		    .w1_i                   (w1_i[I]                     ), //input
    		    .w2_i                   (w2_i[I]                     ), //input
    		    .w3_i                   (w3_i[I]                     ), //input
    		    .w0_o                   (w0_o[I]                     )  //output
    		);
		end
	endgenerate
	
	assign a_add_state = a + statebytes_o[7*32+:32];
	assign b_add_state = b + statebytes_o[6*32+:32];
	assign c_add_state = c + statebytes_o[5*32+:32];
	assign d_add_state = d + statebytes_o[4*32+:32];
	assign e_add_state = e + statebytes_o[3*32+:32];
	assign f_add_state = f + statebytes_o[2*32+:32];
	assign g_add_state = g + statebytes_o[1*32+:32];
	assign h_add_state = h + statebytes_o[0*32+:32];

    assign fm32_cal_en   = state_c == FM32_CAL ? 1'b1 : 1'b0;
    assign one_fm32_done = cnt1 == 2'd1;
    assign four_fm32_done= state_c == FM32_CAL && cnt0 == 2'd3 && cnt1 == 2'd1 ? 1'b1 : 1'b0;

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			len_lock <= 7'd0;
		end
		else if(start)begin
			len_lock <= len;
		end
		else if(state_c == STATE_INIT)begin
			len_lock <= len_lock - 7'd64;
		end
	end
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            dout_vld <= 1'b0;
        end
        else if(start & exist_pub_seed & pub_seed)begin
            dout_vld <= 1'b1;
        end
        else if(state_c == STATE_INIT && (len_lock <= 7'd127))begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= 1'b0;
        end
    end

	always@(posedge clk)begin
		case(state_c)
			IDEL:begin
				if(start)begin
					if(pub_seed&exist_pub_seed)begin
						statebytes_o <= sha256_pub_seed;
					end
					else begin
						statebytes_o <= statebytes_i;
					end
				end
			end
			STATE_INIT:begin
				statebytes_o <= {a_add_state,b_add_state,c_add_state,d_add_state,e_add_state,f_add_state,g_add_state,h_add_state}; 
			end
		endcase
	end

//---------------------------------------------------------------------------------tail
	
	always @(posedge clk or negedge rst_n) begin
	    if (~rst_n) begin
	        pub_seed_lock <= 'd0;
	    end
	    else if (start) begin
	        pub_seed_lock <= pub_seed;
	    end
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
    	    exist_pub_seed <= 1'd0;
    	end
    	else if (pub_seed_lock & dout_vld) begin
    	    exist_pub_seed <= 1'b1;
    	end
	end
	
	always @(posedge clk) begin
		if(dout_vld)begin
			if(~exist_pub_seed & pub_seed_lock)begin
				sha256_pub_seed <= statebytes_o;
			end
		end
	end

	always @(posedge clk) begin
	    if (block_1st) begin
	        sum_len <= len;
	    end
	    else if (block_final) begin
	        sum_len <= sum_len + len;
	    end
	    else if (start) begin
	        sum_len <= sum_len + 7'd64;
	    end
	end
	assign sum_len_comb = block_1st ? len : sum_len+len;
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
