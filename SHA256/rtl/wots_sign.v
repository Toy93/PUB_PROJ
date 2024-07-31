`include "gdefine.v"
module wots_sign(
input		clk,
input		rstn,

input		start,
input		rst_start_i,

input	[255:0]	msg,
input	[255:0]	sk_seed,
input	[255:0]	pub_seed,
input	[255:0]	wots_addr,

output	reg	sha256_start,
output	reg	sha256_1st,
output	reg	sha256_final,
//output	reg	sha256_seed,
output	[255:0]	sha256_state,
output	[511:0]	sha256_data,
output	[6:0]	sha256_len,
input		sha256_done,
input	[255:0]	sha256_dout,

output	reg	thash_start,
output		thash_mode,

output		sig_vld,
output	reg	dout_vld,
output	reg [255:0]	root,
output	reg [7:0] cnt_i_reg,
output	reg [3:0] cnt_start_reg,
output	[255:0]	dout);	// sig

// ------------------------------------------------------
// parameter
parameter S_IDLE          = 3'd0;
parameter S_CHAIN_LENGTHS = 3'd1;
parameter S_CUT0          = 3'd2;
parameter S_WOTS_GEN_SK   = 3'd3;
parameter S_CUT1          = 3'd4;
parameter S_WAIT          = 3'd5;
parameter S_GEN_CHAIN     = 3'd6;
parameter S_JUDGE         = 3'd7;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };

// ------------------------------------------------------
// wire && reg
reg	[2:0]	cu_st, ne_st;
wire	[255:0]	addr;
reg	[5:0]	cnt_chain;
reg	[7:0]	cnt_i;
reg	[3:0]	steps;
reg	[3:0]	cnt_start;
reg	[11:0]	cnt_len;

wire	[255:0]	fors_tree_addr;
reg	[255:0]	fors_pk_addr;

reg	[23:0]	indices;
wire	[18:0]	idx_offset;

reg		en_treehash;
reg		en_dict_thash;
wire		dict_thash;
wire		dict_thash_done;
wire		treehash_sha256_start;
wire		treehash_sha256_1st;
wire		treehash_sha256_seed;
wire		treehash_sha256_final;
wire	[255:0]	treehash_sha256_state;
wire	[511:0]	treehash_sha256_data;
wire	[6:0]	treehash_sha256_len;
wire		treehash_sig_vld;
wire		treehash_dout_vld;
wire	[255:0]	treehash_root;
wire	[255:0]	treehash_auth_path;

reg		buf_msb_dl, buf_lsb_dl;
reg	[511:0]	buffer;
reg	[255:0]	last_data;
reg	[255:0]	state;
wire		consump_en;
reg	[`MLEN_WIDTH-1:0]	len;

// ------------------------------------------------------
// main FSM
assign	addr = {wots_addr[255:120], cnt_i, wots_addr[111:88], 8'd0, wots_addr[79:0]};
always @(posedge clk) begin
    if (~rstn) begin
        cu_st <= S_IDLE;
    end
    else begin
        cu_st <= ne_st;
    end
end

always @(*) begin
    case(cu_st)
        S_IDLE          : ne_st = start  ? S_CHAIN_LENGTHS : S_IDLE;

        S_CHAIN_LENGTHS : ne_st = &cnt_chain ? S_CUT0          : S_CHAIN_LENGTHS;


        // Computes the starting value for a chain, i.e. the secret key.
        // Expects the address to be complete up to the chain address.
        S_CUT0        : ne_st = S_WOTS_GEN_SK; 
        S_WOTS_GEN_SK : ne_st = sha256_done ? ((steps == 4'd0) ? S_JUDGE : S_CUT1) : S_WOTS_GEN_SK;

        // Computes the chaining function.
        // out and in have to be n-byte arrays.
        
        // Interprets in as start-th value of the chain.
        // addr has to contain the address of the chain.
        S_CUT1        : ne_st = S_WAIT; 
        S_WAIT        : ne_st = sha256_done ? S_GEN_CHAIN : S_WAIT; 
        S_GEN_CHAIN   : begin
            if (sha256_done) begin
                /* Iterate 'steps' calls to the hash function. */
                // for (i = start; i < (start+steps) && i < SPX_WOTS_W; i++) {
                if (((cnt_start+1'b1) < steps) && ((cnt_start+1'b1) < `SPX_WOTS_W)) begin
                    ne_st = S_CUT1;
                end
                else begin
                    ne_st = S_JUDGE;
                end
            end
            else begin
                ne_st = S_GEN_CHAIN;
            end
        end

        S_JUDGE       : ne_st = (cnt_i == `SPX_WOTS_LEN-1) ? S_IDLE : S_CUT0; 

        default       : ne_st = S_IDLE;
    endcase
end

always @(*) begin
    case(cnt_i)
        8'd0  : steps = msg[255:252];
        8'd1  : steps = msg[251:248];
        8'd2  : steps = msg[247:244];
        8'd3  : steps = msg[243:240];
        8'd4  : steps = msg[239:236];
        8'd5  : steps = msg[235:232];
        8'd6  : steps = msg[231:228];
        8'd7  : steps = msg[227:224];
        8'd8  : steps = msg[223:220];
        8'd9  : steps = msg[219:216];
        8'd10 : steps = msg[215:212];
        8'd11 : steps = msg[211:208];
        8'd12 : steps = msg[207:204];
        8'd13 : steps = msg[203:200];
        8'd14 : steps = msg[199:196];
        8'd15 : steps = msg[195:192];
        8'd16 : steps = msg[191:188];
        8'd17 : steps = msg[187:184];
        8'd18 : steps = msg[183:180];
        8'd19 : steps = msg[179:176];
        8'd20 : steps = msg[175:172];
        8'd21 : steps = msg[171:168];
        8'd22 : steps = msg[167:164];
        8'd23 : steps = msg[163:160];
        8'd24 : steps = msg[159:156];
        8'd25 : steps = msg[155:152];
        8'd26 : steps = msg[151:148];
        8'd27 : steps = msg[147:144];
        8'd28 : steps = msg[143:140];
        8'd29 : steps = msg[139:136];
        8'd30 : steps = msg[135:132];
        8'd31 : steps = msg[131:128];
        8'd32 : steps = msg[127:124];
        8'd33 : steps = msg[123:120];
        8'd34 : steps = msg[119:116];
        8'd35 : steps = msg[115:112];
        8'd36 : steps = msg[111:108];
        8'd37 : steps = msg[107:104];
        8'd38 : steps = msg[103:100];
        8'd39 : steps = msg[99:96];
        8'd40 : steps = msg[95:92];
        8'd41 : steps = msg[91:88];
        8'd42 : steps = msg[87:84];
        8'd43 : steps = msg[83:80];
        8'd44 : steps = msg[79:76];
        8'd45 : steps = msg[75:72];
        8'd46 : steps = msg[71:68];
        8'd47 : steps = msg[67:64];
        8'd48 : steps = msg[63:60];
        8'd49 : steps = msg[59:56];
        8'd50 : steps = msg[55:52];
        8'd51 : steps = msg[51:48];
        8'd52 : steps = msg[47:44];
        8'd53 : steps = msg[43:40];
        8'd54 : steps = msg[39:36];
        8'd55 : steps = msg[35:32];
        8'd56 : steps = msg[31:28];
        8'd57 : steps = msg[27:24];
        8'd58 : steps = msg[23:20];
        8'd59 : steps = msg[19:16];
        8'd60 : steps = msg[15:12];
        8'd61 : steps = msg[11:8];
        8'd62 : steps = msg[7:4];
        8'd63 : steps = msg[3:0];

        8'd64 : steps = cnt_len[11:8];
        8'd65 : steps = cnt_len[7:4];
        8'd66 : steps = cnt_len[3:0];
        default : steps = 'd0;
    endcase
end


// cycle
assign	chain_lengths_en =  (cu_st == S_CHAIN_LENGTHS);
always @(posedge clk) begin
    if (~rstn) begin
        cnt_chain <= 'd0;
    end
    else if (start) begin
        cnt_chain <= 'd0;
    end
    else if (chain_lengths_en) begin
        cnt_chain <= cnt_chain + 1'b1;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        cnt_i <= 'd0;
    end
    else if (start) begin
        cnt_i <= 'd0;
    end
    else if (cu_st == S_JUDGE) begin
        cnt_i <= cnt_i + 1'b1;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        cnt_len <= 'd0;
    end
    else if (start) begin
        cnt_len <= 'd0;
    end
    else if (cu_st == S_CHAIN_LENGTHS) begin
        cnt_len <= cnt_len + 4'd15 - state[255:252];
    end
end

// start
always @(posedge clk) begin
    if (~rstn) begin
        cnt_start <= 'd0;
    end
    else if (start || (cu_st == S_JUDGE)) begin
        cnt_start <= 'd0;
    end
    else if ((cu_st == S_GEN_CHAIN) && (ne_st == S_CUT1)) begin
        cnt_start <= cnt_start + 1'b1;
    end
end

//assign	idx_offset = {cnt, 14'd0};
//// set_type(fors_tree_addr, SPX_ADDR_TYPE_FORSTREE);
//// set_tree_height(fors_tree_addr, 0);
//// set_tree_index(fors_tree_addr, indices[i] + idx_offset);
//assign	fors_tree_addr = {wots_addr[255:184], 8'd3, wots_addr[175:104], indices + idx_offset, wots_addr[79:0]};
////    set_type(fors_pk_addr, SPX_ADDR_TYPE_FORSPK);
//always @(posedge clk) begin
//    if (~rstn) begin
//        fors_pk_addr <= 'd0;
//    end
//    else if (start) begin
//        fors_pk_addr <= {wots_addr[255:184], 8'd4, wots_addr[175:0]};
//    end
//end
//
////    message_to_indices(indices, m);
//always @(*) begin
//    case(cnt)
//        5'd0  : indices = {mhash[301:296], mhash[311:304]};                 // 6 + 8
//        5'd1  : indices = {mhash[283:280], mhash[295:288], mhash[303:302]}; // 4 + 8 + 2
//        5'd2  : indices = {mhash[265:264], mhash[279:272], mhash[287:284]}; // 2 + 8 + 4
//        5'd3  : indices = {mhash[263:256], mhash[271:266]};                 // 8 + 6
//        5'd4  : indices = {mhash[245:240], mhash[255:248]};                 // 6 + 8
//        5'd5  : indices = {mhash[227:224], mhash[239:232], mhash[247:246]}; // 4 + 8 + 2
//        5'd6  : indices = {mhash[209:208], mhash[223:216], mhash[231:228]}; // 2 + 8 + 4
//        5'd7  : indices = {mhash[207:200], mhash[215:210]};                 // 8 + 6
//        5'd8  : indices = {mhash[189:184], mhash[199:192]};                 // 6 + 8
//        5'd9  : indices = {mhash[171:168], mhash[183:176], mhash[191:190]}; // 4 + 8 + 2
//        5'd10 : indices = {mhash[153:152], mhash[167:160], mhash[175:172]}; // 2 + 8 + 4
//        5'd11 : indices = {mhash[151:144], mhash[159:154]};                 // 8 + 6
//        5'd12 : indices = {mhash[133:128], mhash[143:136]};                 // 6 + 8
//        5'd13 : indices = {mhash[115:112], mhash[127:120], mhash[135:134]}; // 4 + 8 + 2
//        5'd14 : indices = {mhash[ 97: 96], mhash[111:104], mhash[119:116]}; // 2 + 8 + 4
//        5'd15 : indices = {mhash[ 95: 88], mhash[103: 98]};                 // 8 + 6
//        5'd16 : indices = {mhash[ 77: 72], mhash[ 87: 80]};                 // 6 + 8
//        5'd17 : indices = {mhash[ 59: 56], mhash[ 71: 64], mhash[ 79: 78]}; // 4 + 8 + 2
//        5'd18 : indices = {mhash[ 41: 40], mhash[ 55: 48], mhash[ 63: 60]}; // 2 + 8 + 4
//        5'd19 : indices = {mhash[ 39: 32], mhash[ 47: 42]};                 // 8 + 6
//        5'd20 : indices = {mhash[ 21: 16], mhash[ 31: 24]};                 // 6 + 8
//        5'd21 : indices = {mhash[  3:  0], mhash[ 15:  8], mhash[ 23: 22]}; // 4 + 8 + 2
//        default : indices = 'd0;
//    endcase
//end
//
//always @(posedge clk) begin
//    if (~rstn) begin
//        en_treehash <= 1'd0;
//    end
//    else begin
//        en_treehash <= (cu_st == S_CUT1);
//    end
//end
//always @(posedge clk) begin
//    if (~rstn) begin
//        en_dict_thash <= 1'd0;
//    end
//    else begin
//        en_dict_thash <= (cu_st == S_CUT2);
//    end
//end
//assign	dict_thash = (cu_st == S_THASH);
//treehash treehash_i0 (
//	.clk		(clk),
//	.rstn		(rstn),
//
//	.start		(en_treehash),
//
//	.sk_seed	(sk_seed),
//	.pub_seed	(pub_seed),
//	.leaf_idx	(indices),
//	.idx_offset	(idx_offset),
//	.tree_height	(`SPX_FORS_HEIGHT), // 'd14
//	.tree_addr	(wots_addr),
//	.fors_mode	(1'b1),
//
//	.en_dict_thash	(en_dict_thash),
//	.dict_thash	(dict_thash),
//	.dict_thash_done(dict_thash_done),
//
//	.sha256_start	(treehash_sha256_start),
//	.sha256_1st	(treehash_sha256_1st),
//	.sha256_seed	(treehash_sha256_seed),
//	.sha256_final	(treehash_sha256_final),
//	.sha256_state	(treehash_sha256_state),
//	.sha256_data	(treehash_sha256_data),
//	.sha256_len	(treehash_sha256_len),
//	.sha256_done	(sha256_done),
//	.sha256_dout	(sha256_dout),
//
//	.sig_vld	(treehash_sig_vld),
//	.dout_vld	(treehash_dout_vld),
//	.root		(treehash_root),
//	.auth_path	(treehash_auth_path));

always @(posedge clk) begin
    if (~rstn) begin
        buffer <= 'd0;
    end
    else if ((cu_st == S_CUT0) && (cnt_start == 4'd0)) begin
        buffer <= {sk_seed, addr};
    end
    else if ((cu_st == S_CUT1) || (cu_st == S_JUDGE)) begin
        buffer <= {addr[255:88], 4'd0, cnt_start, state, addr[79:0]};
    end
//    else if (cu_st == CUT3) begin
//        buffer <= {last_data, 32'h0, 224'd0};
//    end
//    else if (cu_st == CUT4) begin
//        buffer <= {last_data, 32'd1, 224'd0};
//    end
//    else begin
//        if (buf_msb_dl) begin
//            buffer[511:256] <= mem_rdata;
//        end
//        if (buf_lsb_dl) begin
//            buffer[255:  0] <= mem_rdata;
//        end
//    end
end

//// save sha256 result
//always @(posedge clk) begin
//    if (~rstn) begin
//        last_data <= 'd0;
//    end
//    else if ((cu_st == S_WOTS_GEN_SK) && sha256_done) begin
//        last_data <= sha256_dout;
//    end
//end


// state
always @(posedge clk) begin
    if (~rstn) begin
        state <= 'd0;
    end
    else if (start) begin
         state <= msg;
    end
    else if (cu_st == S_CHAIN_LENGTHS) begin
         state <= {state[251:0], 4'd0};
    end
    else if ((cu_st == S_CUT0) || (cu_st == S_CUT1)) begin
         state <= IV_256;
    end
    else if (sha256_done) begin
         state <= sha256_dout;
    end
end

////assign	consump_en = ((cu_st == CUT0) && (ne_st == SHA256_INC_BLOCK1)) ||
////                      (cu_st == CUT1);
always @(posedge clk) begin
    if (~rstn) begin
        len <= 'd0;
    end
    else if (start) begin
        len <= 6'd54; // `SPX_N(32) + `SPX_SHA256_ADDR_BYTES(22);
    end
//    else if ((cu_st == CUT0) && (ne_st == SHA256_INC_BLOCK1)) begin
//        len <= len - 7'h20;
//    end
//    else if (cu_st == CUT2) begin
//        len <= len - 7'h40;
//    end
//    else if (cu_st == CUT3) begin
//        len <= 7'h24;
//    end
//    else if (cu_st == CUT4) begin
//        len <= 7'h24;
//    end
end

always @(posedge clk) begin
    if (~rstn) begin
        thash_start <= 'd0;
    end
    else begin
        thash_start <= (cu_st == S_CUT1);
    end
end
assign	thash_mode = (cu_st == S_WAIT) || (cu_st == S_GEN_CHAIN);

always @(posedge clk) begin
    if (~rstn) begin
        sha256_start <= 'd0;
    end
    else begin
        sha256_start <= (cu_st == S_CUT0);
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_1st  <= 'd0;
//        sha256_seed <= 'd0;
    end
    else begin
        sha256_1st  <= (cu_st == S_CUT0) || (cu_st == S_CUT1); // || treehash_sha256_1st;
//        sha256_seed <= treehash_sha256_seed;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_final <= 'd0;
    end
    else begin
        sha256_final <= (cu_st == S_CUT0) || (cu_st == S_CUT1); // || treehash_sha256_final;
    end
end

assign	sha256_state = state;
assign	sha256_data  = buffer;
assign	sha256_len   = len;

always @(posedge clk) begin
    if (~rstn) begin
        dout_vld <= 'd0;
    end
    else begin
        dout_vld <= (cu_st == S_JUDGE) && (ne_st == S_IDLE);
    end
end

assign	sig_vld = (cu_st == S_JUDGE);// && (ne_st == S_CUT0);
assign	dout    = sha256_state;

always @(posedge clk) begin
    if (~rstn) begin
        cnt_start_reg <= 'd0;
        cnt_i_reg     <= 'd0;
    end
    else if (rst_start_i) begin
        cnt_start_reg <= 'd0;
        cnt_i_reg     <= 'd0;
    end
    else if ((cu_st == S_JUDGE) && (ne_st == S_IDLE)) begin
        cnt_start_reg <= cnt_start;
        cnt_i_reg     <= cnt_i;
    end
end

endmodule
