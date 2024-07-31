`include "gdefine.v"
module fors_sign(
input		clk,
input		rstn,

input		start,
input		rst_start_i,

input	[311:0]	mhash,
input	[255:0]	sk_seed,
input	[255:0]	pub_seed,
input	[255:0]	wots_addr,
input	[7:0]	wots_leaf_idx,

output	reg	sha256_start,
output	reg	sha256_1st,
output	reg	sha256_final,
output	reg	sha256_seed,
output	[255:0]	sha256_state,
output	[511:0]	sha256_data,
output	[6:0]	sha256_len,
input		sha256_done,
input	[255:0]	sha256_dout,

input		wots_sign_thash_mode,
input		wots_sign_thash_start,
input		wots_sign_thash_1st,
input		wots_sign_thash_final,
input	[255:0]	wots_sign_thash_state,
input	[511:0]	wots_sign_thash_data,
input	[6:0]	wots_sign_thash_len,

input		en_sign_dict_treehash,
input		sign_dict_treehash_mode,
output		sign_dict_treehash_done,
output	[7:0]	last_tree_height,
output	[31:0]	last_tree_index,

output	reg	sig_vld,
output	reg	dout_vld,
output	reg [255:0]	root,
output	reg [255:0]	dout);	// sig

// ------------------------------------------------------
// parameter
parameter S_IDLE        = 3'd0;
parameter S_CUT0        = 3'd1;
parameter S_FORS_GEN_SK = 3'd2;
parameter S_CUT1        = 3'd3;
parameter S_TREEHASH    = 3'd4;
parameter S_CUT2        = 3'd5;
parameter S_THASH       = 3'd6;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };

// ------------------------------------------------------
// wire && reg
reg	[3:0]	cu_st, ne_st;
reg	[4:0]	cnt;

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
        S_IDLE        : ne_st = start       ? S_CUT0        : S_IDLE;


        /* Include the secret key part that produces the selected leaf node. */
        S_CUT0        : ne_st = S_FORS_GEN_SK; 
        S_FORS_GEN_SK : ne_st = sha256_done ? S_CUT1        : S_FORS_GEN_SK;

        /* Compute the authentication path for this leaf node. */
        S_CUT1        : ne_st = S_TREEHASH; 
        S_TREEHASH    : begin
            if (treehash_dout_vld) begin
                if (cnt == `SPX_FORS_TREES-1) begin // for (i = 0; i < SPX_FORS_TREES; i++) {
                    ne_st = S_CUT2;
                end
                else begin
                   ne_st = S_CUT0;
                end
            end
            else begin
                ne_st = S_TREEHASH;
            end
        end

        /* Hash horizontally across all tree roots to derive the public key. */
        S_CUT2        : ne_st = S_THASH; 
        S_THASH       : ne_st = dict_thash_done ? S_IDLE        : S_THASH;

        default       : ne_st = S_IDLE;
    endcase
end

// cycle SPX_FORS_TREES
always @(posedge clk) begin
    if (~rstn) begin
        cnt <= 'd0;
    end
    else if (cu_st == S_IDLE) begin
        cnt <= 'd0;
    end
    else if ((cu_st == S_TREEHASH) && treehash_dout_vld) begin
        cnt <= cnt + 1'b1;
    end
end

assign	idx_offset = {cnt, 14'd0}; // idx_offset = i * (1 << SPX_FORS_HEIGHT);
// set_type(fors_tree_addr, SPX_ADDR_TYPE_FORSTREE);
// set_tree_height(fors_tree_addr, 0);
// set_tree_index(fors_tree_addr, indices[i] + idx_offset);
assign	fors_tree_addr = {wots_addr[255:184], 8'd3, wots_addr[175:104], indices + idx_offset, wots_addr[79:0]};
//    set_type(fors_pk_addr, SPX_ADDR_TYPE_FORSPK);
always @(posedge clk) begin
    if (~rstn) begin
        fors_pk_addr <= 'd0;
    end
    else if (start) begin
        fors_pk_addr <= {wots_addr[255:184], 8'd4, wots_addr[175:0]};
    end
end

//    message_to_indices(indices, m);
always @(*) begin
    if (sign_dict_treehash_mode) begin 
        // leaf_idx
        indices = wots_leaf_idx;
    end
    else begin
        case(cnt)
            5'd0  : indices = {mhash[301:296], mhash[311:304]};                 // 6 + 8
            5'd1  : indices = {mhash[283:280], mhash[295:288], mhash[303:302]}; // 4 + 8 + 2
            5'd2  : indices = {mhash[265:264], mhash[279:272], mhash[287:284]}; // 2 + 8 + 4
            5'd3  : indices = {mhash[263:256], mhash[271:266]};                 // 8 + 6
            5'd4  : indices = {mhash[245:240], mhash[255:248]};                 // 6 + 8
            5'd5  : indices = {mhash[227:224], mhash[239:232], mhash[247:246]}; // 4 + 8 + 2
            5'd6  : indices = {mhash[209:208], mhash[223:216], mhash[231:228]}; // 2 + 8 + 4
            5'd7  : indices = {mhash[207:200], mhash[215:210]};                 // 8 + 6
            5'd8  : indices = {mhash[189:184], mhash[199:192]};                 // 6 + 8
            5'd9  : indices = {mhash[171:168], mhash[183:176], mhash[191:190]}; // 4 + 8 + 2
            5'd10 : indices = {mhash[153:152], mhash[167:160], mhash[175:172]}; // 2 + 8 + 4
            5'd11 : indices = {mhash[151:144], mhash[159:154]};                 // 8 + 6
            5'd12 : indices = {mhash[133:128], mhash[143:136]};                 // 6 + 8
            5'd13 : indices = {mhash[115:112], mhash[127:120], mhash[135:134]}; // 4 + 8 + 2
            5'd14 : indices = {mhash[ 97: 96], mhash[111:104], mhash[119:116]}; // 2 + 8 + 4
            5'd15 : indices = {mhash[ 95: 88], mhash[103: 98]};                 // 8 + 6
            5'd16 : indices = {mhash[ 77: 72], mhash[ 87: 80]};                 // 6 + 8
            5'd17 : indices = {mhash[ 59: 56], mhash[ 71: 64], mhash[ 79: 78]}; // 4 + 8 + 2
            5'd18 : indices = {mhash[ 41: 40], mhash[ 55: 48], mhash[ 63: 60]}; // 2 + 8 + 4
            5'd19 : indices = {mhash[ 39: 32], mhash[ 47: 42]};                 // 8 + 6
            5'd20 : indices = {mhash[ 21: 16], mhash[ 31: 24]};                 // 6 + 8
            5'd21 : indices = {mhash[  3:  0], mhash[ 15:  8], mhash[ 23: 22]}; // 4 + 8 + 2
            default : indices = 'd0;
        endcase
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        en_treehash <= 1'd0;
    end
    else begin
        en_treehash <= (cu_st == S_CUT1);
    end
end
always @(posedge clk) begin
    if (~rstn) begin
        en_dict_thash <= 1'd0;
    end
    else begin
        en_dict_thash <= (cu_st == S_CUT2);
    end
end
assign	dict_thash = (cu_st == S_THASH);
treehash treehash_i0 (
	.clk		(clk),
	.rstn		(rstn),

	.start		(en_treehash),
	.rst_start_i	(rst_start_i),

	.sk_seed	(sk_seed),
	.pub_seed	(pub_seed),
	.leaf_idx	(indices),
	.idx_offset	(idx_offset),
	.tree_height	(`SPX_FORS_HEIGHT), // 'd14
	.tree_addr	(wots_addr),
	.fors_mode	(1'b1),

	.en_dict_thash	(en_dict_thash),
	.dict_thash	(dict_thash),
	.dict_thash_done(dict_thash_done),

	.sha256_start	(treehash_sha256_start),
	.sha256_1st	(treehash_sha256_1st),
	.sha256_seed	(treehash_sha256_seed),
	.sha256_final	(treehash_sha256_final),
	.sha256_state	(treehash_sha256_state),
	.sha256_data	(treehash_sha256_data),
	.sha256_len	(treehash_sha256_len),
	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.wots_sign_thash_mode	(wots_sign_thash_mode),
	.wots_sign_thash_start	(wots_sign_thash_start),
	.wots_sign_thash_1st	(wots_sign_thash_1st),
	.wots_sign_thash_final	(wots_sign_thash_final),
	.wots_sign_thash_state	(wots_sign_thash_state),
	.wots_sign_thash_data	(wots_sign_thash_data),
	.wots_sign_thash_len	(wots_sign_thash_len),

	.en_sign_dict_treehash	(en_sign_dict_treehash),
	.sign_dict_treehash_mode(sign_dict_treehash_mode),
	.last_tree_height	(last_tree_height),
	.last_tree_index	(last_tree_index),

	.sig_vld	(treehash_sig_vld),
	.dout_vld	(treehash_dout_vld),
	.root		(treehash_root),
	.auth_path	(treehash_auth_path)); // sig

assign	sign_dict_treehash_done = sign_dict_treehash_mode && treehash_dout_vld;

always @(posedge clk) begin
    if (~rstn) begin
        buffer <= 'd0;
    end
    else if (cu_st == S_CUT0) begin
        buffer <= {sk_seed, fors_tree_addr};
    end
//    else if (cu_st == CUT0) begin
//        buffer <= {pk_root, mem_rdata};
//    end
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

//// save 0x36 sha256 result
//always @(posedge clk) begin
//    if (~rstn) begin
//        last_data <= 'd0;
//    end
//    else if ((cu_st == SHA256_INC_FINALIZE1) && sha256_done) begin
//        last_data <= sha256_dout;
//    end
//end
//
//
// state
always @(posedge clk) begin
    if (~rstn) begin
        state <= 'd0;
    end
    else if (cu_st == S_CUT0) begin
         state <= IV_256;
    end
    else if (sha256_done) begin
         state <= sha256_dout;
    end
end

//assign	consump_en = ((cu_st == CUT0) && (ne_st == SHA256_INC_BLOCK1)) ||
//                      (cu_st == CUT1);
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
        sha256_start <= 'd0;
    end
    else begin
        sha256_start <= (cu_st == S_CUT0) || treehash_sha256_start;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_1st  <= 'd0;
        sha256_seed <= 'd0;
    end
    else begin
        sha256_1st  <= (cu_st == S_CUT0) || treehash_sha256_1st;
        sha256_seed <= treehash_sha256_seed;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_final <= 'd0;
    end
    else begin
        sha256_final <= (cu_st == S_CUT0) || treehash_sha256_final;
    end
end

assign	sha256_state = ((cu_st == S_TREEHASH) || (cu_st == S_THASH) || wots_sign_thash_mode || sign_dict_treehash_mode) ? treehash_sha256_state : state;
assign	sha256_data  = ((cu_st == S_TREEHASH) || (cu_st == S_THASH) || wots_sign_thash_mode || sign_dict_treehash_mode) ? treehash_sha256_data  : buffer;
assign	sha256_len   = ((cu_st == S_TREEHASH) || (cu_st == S_THASH) || wots_sign_thash_mode || sign_dict_treehash_mode) ? treehash_sha256_len   : len;

always @(posedge clk) begin
    if (~rstn) begin
        dout_vld <= 'd0;
    end
    else begin
        dout_vld <= (cu_st == S_THASH) && dict_thash_done;
    end
end

always @(*) begin
    if (sign_dict_treehash_mode) begin
        sig_vld = treehash_sig_vld;
        dout    = treehash_auth_path;
    end
    else begin
        case(cu_st)
            S_FORS_GEN_SK : begin sig_vld = sha256_done;      dout = sha256_dout;        end
            S_TREEHASH    : begin sig_vld = treehash_sig_vld; dout = treehash_auth_path; end
            default       : begin sig_vld = 1'b0;             dout = 'd0;                end
        endcase
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        root     <= 'd0;
    end
    else if (((cu_st == S_THASH) && dict_thash_done) || sign_dict_treehash_done) begin
        root     <= sha256_state;
    end
end

endmodule
