// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/06 08:14
// Last Modified : 2024/06/09 14:45
// File Name     : crypto_hashblocks_sha256.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/06   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module crypto_hashblocks_sha256 (
input		clk,
input		rstn,

input		start,
input		block_1st,
input		pub_seed,
input		block_final,
input	[255:0]	statebytes,
input	[511:0]	in,
input	[6:0]	len,

output		dout_vld,
output	[255:0]	dout
);

// ------------------------------------------
// parameter
parameter IDLE  = 3'd0;
parameter PADD  = 3'd1;
parameter CONV0 = 3'd2;
parameter PADD0 = 3'd3;
parameter CONV  = 3'd4;
parameter END   = 3'd5;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };
// ------------------------------------------
// wire && reg
reg	[2:0]	cu_st, ne_st;
wire		enable;
wire		done;
reg	[6:0]	cnt;
reg	[60:0]	total_len;
reg	[31:0]	a,b,c,d,e,f,g,h;
reg	[31:0]	w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15;
wire	[31:0]	out_a,out_b,out_c,out_d,out_e,out_f,out_g,out_h;


reg		current_is_pub_seed_flag;
reg		have_hash_pub_seed_flag;
reg	[255:0]	sha256_pub_seed;

// -------------------------------------------
// code begin
// main FSM
always @(posedge clk) begin
    if (~rstn) begin
        cu_st <= IDLE;
    end
    else begin
        cu_st <= ne_st;
    end
end

always @(*) begin
    case(cu_st)
        IDLE   : begin 
            if (start) begin
                if (pub_seed && have_hash_pub_seed_flag) begin
                    ne_st = END;
                end
                else if (block_final) begin
                    ne_st = PADD;
                end
                else begin
                    ne_st = CONV;
                end
            end
            else begin
                ne_st = IDLE;
            end
        end

		PADD    :begin
			if(len < 7'd56)begin
				ne_st = CONV;
			end
			else begin
				ne_st = CONV0;
			end
		end
	
		CONV0   : begin
			if(done)begin
				ne_st = PADD0;
			end
			else begin
				ne_st = CONV0;
			end
		end
		PADD0   : begin
			ne_st = CONV;
		end
		CONV    :begin
			if(done)begin
				ne_st = END;
			end
			else begin
				ne_st = CONV;
			end
		end
		END     :begin
			ne_st = IDLE;
		end
		default :begin 
			ne_st = IDLE;
		end
    endcase
end

assign	enable = (cu_st == CONV) || (cu_st == CONV0);
assign	done   = (cnt == 7'h6f);
always @(posedge clk) begin
    if (~rstn) begin
        cnt <= 'd0;
    end
    else if (start || done) begin
        cnt <= 'd0;
    end
    else if (enable) begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        total_len <= 'd0;
    end
    else if (block_1st) begin
        total_len <= len;
    end
    else if (block_final) begin
        total_len <= total_len + len;
    end
    else if (start) begin
        total_len <= total_len + 7'd64;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        {a,b,c,d,e,f,g,h} <= 'd0;
    end
    else if (block_1st) begin
        {a,b,c,d,e,f,g,h} <= IV_256;
    end
    else if (start) begin
        {a,b,c,d,e,f,g,h} <= statebytes;
    end
    else if (dout_vld || (cu_st == PADD0)) begin
        {a,b,c,d,e,f,g,h} <= dout;
    end
    else if (enable) begin
        case(cnt)
            7'h0  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w0 ,32'h428a2f98);
            7'h1  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w1 ,32'h71374491);
            7'h2  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w2 ,32'hb5c0fbcf);
            7'h3  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w3 ,32'he9b5dba5);
            7'h4  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w4 ,32'h3956c25b);
            7'h5  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w5 ,32'h59f111f1);
            7'h6  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w6 ,32'h923f82a4);
            7'h7  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w7 ,32'hab1c5ed5);
            7'h8  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w8 ,32'hd807aa98);
            7'h9  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w9 ,32'h12835b01);
            7'ha  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w10,32'h243185be);
            7'hb  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w11,32'h550c7dc3);
            7'hc  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w12,32'h72be5d74);
            7'hd  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w13,32'h80deb1fe);
            7'he  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w14,32'h9bdc06a7);
            7'hf  : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w15,32'hc19bf174);

            7'h20 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w0 ,32'he49b69c1);
            7'h21 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w1 ,32'hefbe4786);
            7'h22 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w2 ,32'h0fc19dc6);
            7'h23 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w3 ,32'h240ca1cc);
            7'h24 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w4 ,32'h2de92c6f);
            7'h25 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w5 ,32'h4a7484aa);
            7'h26 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w6 ,32'h5cb0a9dc);
            7'h27 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w7 ,32'h76f988da);
            7'h28 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w8 ,32'h983e5152);
            7'h29 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w9 ,32'ha831c66d);
            7'h2a : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w10,32'hb00327c8);
            7'h2b : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w11,32'hbf597fc7);
            7'h2c : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w12,32'hc6e00bf3);
            7'h2d : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w13,32'hd5a79147);
            7'h2e : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w14,32'h06ca6351);
            7'h2f : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w15,32'h14292967);

            7'h40 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w0 ,32'h27b70a85);
            7'h41 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w1 ,32'h2e1b2138);
            7'h42 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w2 ,32'h4d2c6dfc);
            7'h43 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w3 ,32'h53380d13);
            7'h44 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w4 ,32'h650a7354);
            7'h45 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w5 ,32'h766a0abb);
            7'h46 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w6 ,32'h81c2c92e);
            7'h47 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w7 ,32'h92722c85);
            7'h48 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w8 ,32'ha2bfe8a1);
            7'h49 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w9 ,32'ha81a664b);
            7'h4a : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w10,32'hc24b8b70);
            7'h4b : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w11,32'hc76c51a3);
            7'h4c : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w12,32'hd192e819);
            7'h4d : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w13,32'hd6990624);
            7'h4e : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w14,32'hf40e3585);
            7'h4f : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w15,32'h106aa070);

            7'h60 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w0 ,32'h19a4c116);
            7'h61 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w1 ,32'h1e376c08);
            7'h62 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w2 ,32'h2748774c);
            7'h63 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w3 ,32'h34b0bcb5);
            7'h64 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w4 ,32'h391c0cb3);
            7'h65 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w5 ,32'h4ed8aa4a);
            7'h66 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w6 ,32'h5b9cca4f);
            7'h67 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w7 ,32'h682e6ff3);
            7'h68 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w8 ,32'h748f82ee);
            7'h69 : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w9 ,32'h78a5636f);
            7'h6a : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w10,32'h84c87814);
            7'h6b : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w11,32'h8cc70208);
            7'h6c : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w12,32'h90befffa);
            7'h6d : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w13,32'ha4506ceb);
            7'h6e : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w14,32'hbef9a3f7);
            7'h6f : {a,b,c,d,e,f,g,h} <= F_32(a,b,c,d,e,f,g,h,w15,32'hc67178f2);

        endcase
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= 'd0;
    end
    else if (start) begin
        {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= in;
    end
// padding
    else if (cu_st == PADD) begin
        case(len)
            7'd1  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:504], 8'h80, 432'd0, total_len, 3'd0};
            7'd2  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:496], 8'h80, 424'd0, total_len, 3'd0};
            7'd3  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:488], 8'h80, 416'd0, total_len, 3'd0};
            7'd4  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:480], 8'h80, 408'd0, total_len, 3'd0};
            7'd5  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:472], 8'h80, 400'd0, total_len, 3'd0};
            7'd6  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:464], 8'h80, 392'd0, total_len, 3'd0};
            7'd7  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:456], 8'h80, 384'd0, total_len, 3'd0};
            7'd8  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:448], 8'h80, 376'd0, total_len, 3'd0};
            7'd9  : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:440], 8'h80, 368'd0, total_len, 3'd0};
            7'd10 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:432], 8'h80, 360'd0, total_len, 3'd0};
            7'd11 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:424], 8'h80, 352'd0, total_len, 3'd0};
            7'd12 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:416], 8'h80, 344'd0, total_len, 3'd0};
            7'd13 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:408], 8'h80, 336'd0, total_len, 3'd0};
            7'd14 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:400], 8'h80, 328'd0, total_len, 3'd0};
            7'd15 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:392], 8'h80, 320'd0, total_len, 3'd0};
            7'd16 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:384], 8'h80, 312'd0, total_len, 3'd0};
            7'd17 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:376], 8'h80, 304'd0, total_len, 3'd0};
            7'd18 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:368], 8'h80, 296'd0, total_len, 3'd0};
            7'd19 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:360], 8'h80, 288'd0, total_len, 3'd0};
            7'd20 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:352], 8'h80, 280'd0, total_len, 3'd0};
            7'd21 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:344], 8'h80, 272'd0, total_len, 3'd0};
            7'd22 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:336], 8'h80, 264'd0, total_len, 3'd0};
            7'd23 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:328], 8'h80, 256'd0, total_len, 3'd0};
            7'd24 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:320], 8'h80, 248'd0, total_len, 3'd0};
            7'd25 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:312], 8'h80, 240'd0, total_len, 3'd0};
            7'd26 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:304], 8'h80, 232'd0, total_len, 3'd0};
            7'd27 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:296], 8'h80, 224'd0, total_len, 3'd0};
            7'd28 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:288], 8'h80, 216'd0, total_len, 3'd0};
            7'd29 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:280], 8'h80, 208'd0, total_len, 3'd0};
            7'd30 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:272], 8'h80, 200'd0, total_len, 3'd0};
            7'd31 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:264], 8'h80, 192'd0, total_len, 3'd0};
            7'd32 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:256], 8'h80, 184'd0, total_len, 3'd0};
            7'd33 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:248], 8'h80, 176'd0, total_len, 3'd0};
            7'd34 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:240], 8'h80, 168'd0, total_len, 3'd0};
            7'd35 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:232], 8'h80, 160'd0, total_len, 3'd0};
            7'd36 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:224], 8'h80, 152'd0, total_len, 3'd0};
            7'd37 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:216], 8'h80, 144'd0, total_len, 3'd0};
            7'd38 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:208], 8'h80, 136'd0, total_len, 3'd0};
            7'd39 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:200], 8'h80, 128'd0, total_len, 3'd0};
            7'd40 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:192], 8'h80, 120'd0, total_len, 3'd0};
            7'd41 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:184], 8'h80, 112'd0, total_len, 3'd0};
            7'd42 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:176], 8'h80, 104'd0, total_len, 3'd0};
            7'd43 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:168], 8'h80,  96'd0, total_len, 3'd0};
            7'd44 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:160], 8'h80,  88'd0, total_len, 3'd0};
            7'd45 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:152], 8'h80,  80'd0, total_len, 3'd0};
            7'd46 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:144], 8'h80,  72'd0, total_len, 3'd0};
            7'd47 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:136], 8'h80,  64'd0, total_len, 3'd0};
            7'd48 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:128], 8'h80,  56'd0, total_len, 3'd0};
            7'd49 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:120], 8'h80,  48'd0, total_len, 3'd0};
            7'd50 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:112], 8'h80,  40'd0, total_len, 3'd0};
            7'd51 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:104], 8'h80,  32'd0, total_len, 3'd0};
            7'd52 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 96], 8'h80,  24'd0, total_len, 3'd0};
            7'd53 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 88], 8'h80,  16'd0, total_len, 3'd0};
            7'd54 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 80], 8'h80,   8'd0, total_len, 3'd0};
            7'd55 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 72], 8'h80, /*0'd0,*/ total_len, 3'd0};

            7'd56 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 64], 8'h80,  56'd0/*, total_len, 3'd0*/};
            7'd57 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 56], 8'h80,  48'd0/*, total_len, 3'd0*/};
            7'd58 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 48], 8'h80,  40'd0/*, total_len, 3'd0*/};
            7'd59 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 40], 8'h80,  32'd0/*, total_len, 3'd0*/};
            7'd60 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 32], 8'h80,  24'd0/*, total_len, 3'd0*/};
            7'd61 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 24], 8'h80,  16'd0/*, total_len, 3'd0*/};
            7'd62 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511: 16], 8'h80,   8'd0/*, total_len, 3'd0*/};
            7'd63 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {in[511:  8], 8'h80/*, 4'd0, total_len, 3'd0*/};

            7'd64 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <=  in;
        endcase
    end
    else if (cu_st == PADD0) begin
        case(len)
            7'd56 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd57 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd58 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd59 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd60 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd61 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd62 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};
            7'd63 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= {448'd0, total_len, 3'd0};

            7'd64 : {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= { 8'h80, 440'd0, total_len, 3'd0};
        endcase
    end
    else if (enable) begin
        case(cnt)
            7'h10, 7'h30, 7'h50  : w0  <= M_32(w0 , w14, w9 , w1 );
            7'h11, 7'h31, 7'h51  : w1  <= M_32(w1 , w15, w10, w2 );
            7'h12, 7'h32, 7'h52  : w2  <= M_32(w2 , w0 , w11, w3 );
            7'h13, 7'h33, 7'h53  : w3  <= M_32(w3 , w1 , w12, w4 );
            7'h14, 7'h34, 7'h54  : w4  <= M_32(w4 , w2 , w13, w5 );
            7'h15, 7'h35, 7'h55  : w5  <= M_32(w5 , w3 , w14, w6 );
            7'h16, 7'h36, 7'h56  : w6  <= M_32(w6 , w4 , w15, w7 );
            7'h17, 7'h37, 7'h57  : w7  <= M_32(w7 , w5 , w0 , w8 );
            7'h18, 7'h38, 7'h58  : w8  <= M_32(w8 , w6 , w1 , w9 );
            7'h19, 7'h39, 7'h59  : w9  <= M_32(w9 , w7 , w2 , w10);
            7'h1a, 7'h3a, 7'h5a  : w10 <= M_32(w10, w8 , w3 , w11);
            7'h1b, 7'h3b, 7'h5b  : w11 <= M_32(w11, w9 , w4 , w12);
            7'h1c, 7'h3c, 7'h5c  : w12 <= M_32(w12, w10, w5 , w13);
            7'h1d, 7'h3d, 7'h5d  : w13 <= M_32(w13, w11, w6 , w14);
            7'h1e, 7'h3e, 7'h5e  : w14 <= M_32(w14, w12, w7 , w15);
            7'h1f, 7'h3f, 7'h5f  : w15 <= M_32(w15, w13, w8 , w0 );
        endcase
    end
end
assign out_a = a + statebytes[255:224];
assign out_b = b + statebytes[223:192];
assign out_c = c + statebytes[191:160];
assign out_d = d + statebytes[159:128];
assign out_e = e + statebytes[127: 96];
assign out_f = f + statebytes[ 95: 64];
assign out_g = g + statebytes[ 63: 32];
assign out_h = h + statebytes[ 31:  0];

assign	dout_vld = cu_st == END;
assign	dout     = (current_is_pub_seed_flag && have_hash_pub_seed_flag) ? sha256_pub_seed : {out_a, out_b, out_c, out_d, out_e, out_f, out_g, out_h};

always @(posedge clk) begin
    if (~rstn) begin
        current_is_pub_seed_flag <= 'd0;
    end
    else if (dout_vld) begin
        current_is_pub_seed_flag <= 'd0;
    end
    else if (pub_seed) begin
        current_is_pub_seed_flag <= 1'b1;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        have_hash_pub_seed_flag <= 'd0;
    end
    else if (current_is_pub_seed_flag && dout_vld) begin
        have_hash_pub_seed_flag <= 1'b1;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_pub_seed <= 'd0;
    end
    else if (~have_hash_pub_seed_flag && current_is_pub_seed_flag && dout_vld) begin
        sha256_pub_seed <= dout;
    end
end


//#define SHR(x, c) ((x) >> (c))
//#define ROTR_32(x, c) (((x) >> (c)) | ((x) << (32 - (c))))
//#define ROTR_64(x, c) (((x) >> (c)) | ((x) << (64 - (c))))

//#define Ch(x, y, z) (((x) & (y)) ^ (~(x) & (z)))
//#define Maj(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

//#define Sigma0_32(x) (ROTR_32(x, 2) ^ ROTR_32(x,13) ^ ROTR_32(x,22))
function [31:0] F_Sigma0_32;
    input [31:0] x;
    F_Sigma0_32 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]};
endfunction
//#define Sigma1_32(x) (ROTR_32(x, 6) ^ ROTR_32(x,11) ^ ROTR_32(x,25))
function [31:0] F_Sigma1_32;
    input [31:0] x;
    F_Sigma1_32 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
endfunction
//#define sigma0_32(x) (ROTR_32(x, 7) ^ ROTR_32(x,18) ^ SHR(x, 3))
function [31:0] sigma0_32;
    input [31:0] x;
    sigma0_32 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ {3'd0, x[31:3]};
endfunction
//#define sigma1_32(x) (ROTR_32(x,17) ^ ROTR_32(x,19) ^ SHR(x,10))
function [31:0] sigma1_32;
    input [31:0] x;
    sigma1_32 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ {10'd0, x[31:10]};
endfunction


//#define M_32(w0, w14, w9, w1) w0 = sigma1_32(w14) + (w9) + sigma0_32(w1) + (w0);
function [31:0] M_32;
    input [31:0] a,b,c,d;
    M_32 = sigma1_32(b) + (c) + sigma0_32(d) + (a);
endfunction


function [255:0] F_32;
    input [31:0] a;
    input [31:0] b;
    input [31:0] c;
    input [31:0] d;
    input [31:0] e;
    input [31:0] f;
    input [31:0] g;
    input [31:0] h;
    input [31:0] w;
    input [31:0] k;
    reg   [31:0] T1;
    reg   [31:0] T2;
    reg   [31:0] a0;
    reg   [31:0] b0;
    reg   [31:0] c0;
    reg   [31:0] d0;
    reg   [31:0] e0;
    reg   [31:0] f0;
    reg   [31:0] g0;
    reg   [31:0] h0;

    begin
        T1 = h + F_Sigma1_32(e) + ((e&f) ^ ((~e)&g))/*Ch(e, f, g)*/ + (k) + (w);
        T2 = F_Sigma0_32(a) + ((a&b)^(a&c)^(b&c));//Maj(a, b, c);
        h0 = g;
        g0 = f;
        f0 = e;
        e0 = d + T1;
        d0 = c;
        c0 = b;
        b0 = a;
        a0 = T1 + T2;
        F_32 = {a0,b0,c0,d0,e0,f0,g0,h0};
    end
endfunction

endmodule
