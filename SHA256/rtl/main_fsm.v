`include "gdefine.v"
module main_fsm(
input		clk,
input		rstn,
input		start,

// gen_message_random
output	reg		en_gen_message_random,
input			gen_message_random_dout_vld,

input		gen_message_random_sha256_start,
input		gen_message_random_sha256_1st,
input		gen_message_random_sha256_final,
input	[255:0]	gen_message_random_sha256_state,
input	[511:0]	gen_message_random_sha256_data,
input	[6:0]	gen_message_random_sha256_len,

// hash_message
output reg		en_hash_message,
input		hash_message_dout_vld,
input	[55:0]	hash_message_tree,
input	[7:0]	hash_message_leaf_idx,

input		hash_message_sha256_start,
input		hash_message_sha256_1st,
input		hash_message_sha256_final,
input	[255:0]	hash_message_sha256_state,
input	[511:0]	hash_message_sha256_data,
input	[6:0]	hash_message_sha256_len,

// fors_sign hash_message
output reg		en_fors_sign,
output	[255:0]	fors_sign_in_wots_addr,
output	[255:0]	top_tree_addr,
input		fors_sign_sha256_start,
input		fors_sign_sha256_1st,
input		fors_sign_sha256_seed,
input		fors_sign_sha256_final,
input	[255:0]	fors_sign_sha256_state,
input	[511:0]	fors_sign_sha256_data,
input	[6:0]	fors_sign_sha256_len,

input		fors_sign_dout_vld,
input	[255:0]	fors_sign_root,

output reg		en_sign_dict_treehash,
output		sign_dict_treehash_mode,
input		sign_dict_treehash_done,
input	[7:0]	last_tree_height,
input	[31:0]	last_tree_index,
output		rst_last_tree_height_index,

// wots_sign hash_message
output reg		en_wots_sign,
output reg	[55:0]	wots_sign_hash_message_tree_shift,
output reg	[7:0]	wots_sign_leaf_idx,
output	[255:0]	wots_sign_in_wots_addr,
output	[255:0]	wots_sign_msg,
input		wots_sign_sha256_start,
input		wots_sign_sha256_1st,
input		wots_sign_sha256_seed,
input		wots_sign_sha256_final,
input	[255:0]	wots_sign_sha256_state,
input	[511:0]	wots_sign_sha256_data,
input	[6:0]	wots_sign_sha256_len,

input		wots_sign_thash_mode,
input		wots_sign_dout_vld,
input	[7:0]	wots_sign_cnt_i,
input	[3:0]	wots_sign_cnt_start,

// sha256 core
output		sha256_start,
output		sha256_1st,
output		sha256_seed,
output		sha256_final,
output	[255:0]	sha256_state,
output	[511:0]	sha256_din,
output	[6:0]	sha256_len,

//output
input		fors_sign_sig_vld,
input		wots_sign_sig_vld,
input	[255:0]	gen_message_random_dout,
input	[255:0]	fors_sign_dout,
input	[255:0]	wots_sign_dout,

output		dout_vld,
output	reg [255:0]	dout
);

// ------------------------------------------------------
// parameter
parameter S_IDLE               = 3'd0;
parameter S_GEN_MESSAGE_RANDOM = 3'd1;
parameter S_HASH_MESSAGE       = 3'd2;
parameter S_FORS_SIGN          = 3'd3;
parameter S_WOTS_SIGN          = 3'd4;
parameter S_TREEHASH           = 3'd5;

// ------------------------------------------------------
// wire && reg
wire	debug;
assign	debug = 1'b0;

reg	[2:0]	cu_st, ne_st;
reg		done;
reg	[3:0]	cnt_i;
reg		wots_addr, tree_addr;


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
        S_IDLE               : ne_st = start                       ?  S_GEN_MESSAGE_RANDOM : S_IDLE              ;

        S_GEN_MESSAGE_RANDOM : ne_st = gen_message_random_dout_vld ?  S_HASH_MESSAGE       : S_GEN_MESSAGE_RANDOM;
        S_HASH_MESSAGE       : ne_st = hash_message_dout_vld       ? (debug ? S_WOTS_SIGN :  S_FORS_SIGN)        : S_HASH_MESSAGE      ;
        S_FORS_SIGN          : ne_st = fors_sign_dout_vld          ?  S_WOTS_SIGN          : S_FORS_SIGN         ;

        S_WOTS_SIGN          : ne_st = wots_sign_dout_vld          ?  S_TREEHASH           : S_WOTS_SIGN         ;
	S_TREEHASH           : begin
            if (sign_dict_treehash_done) begin
                if (cnt_i == `SPX_D-1) begin // SPX_D = 8
                    ne_st = S_IDLE;
                end
		else begin
                    ne_st = S_WOTS_SIGN;
                end
            end
            else begin
                ne_st = S_TREEHASH;
            end
        end
        default : ne_st = S_IDLE;
    endcase
end

// ------------------------------------------------------
/* Compute the digest randomization value. */
// gen_message_random(sig, sk_prf, optrand, m, mlen);
always @(posedge clk) begin
    if (~rstn) begin
        en_gen_message_random <= 1'd0;
    end
    else begin
        en_gen_message_random <= (cu_st == S_IDLE) && (ne_st == S_GEN_MESSAGE_RANDOM);
    end
end

// ------------------------------------------------------
/* Derive the message digest and leaf index from R, PK and M. */
//    hash_message(mhash, &tree, &idx_leaf, sig, pk, m, mlen);
always @(posedge clk) begin
    if (~rstn) begin
        en_hash_message <= 1'd0;
    end
    else begin
        en_hash_message <= (cu_st == S_GEN_MESSAGE_RANDOM) && (ne_st == S_HASH_MESSAGE);
    end
end

// ------------------------------------------------------
// /* Sign the message hash using FORS. */
//    fors_sign(sig, root, mhash, sk_seed, pub_seed, wots_addr);
always @(posedge clk) begin
    if (~rstn) begin
        en_fors_sign <= 1'd0;
    end
    else begin
        en_fors_sign <= (cu_st == S_HASH_MESSAGE) && (ne_st == S_FORS_SIGN);
    end
end
always @(posedge clk) begin
    if (~rstn) begin
        en_sign_dict_treehash <= 1'd0;
    end
    else begin
        en_sign_dict_treehash <= (cu_st == S_WOTS_SIGN) && (ne_st == S_TREEHASH);
    end
end
assign	sign_dict_treehash_mode = (cu_st == S_TREEHASH);

//    set_tree_addr(wots_addr, tree);
//    set_keypair_addr(wots_addr, idx_leaf);
assign	fors_sign_in_wots_addr = {16'd0,
                                  hash_message_tree,
                                  32'd0,
                                  hash_message_leaf_idx,
                                  144'd0};

assign	top_tree_addr = {4'd0, cnt_i, //  tree_addr = set_layer_addr(tree_addr, i);
                         8'd0,
                         wots_sign_hash_message_tree_shift,
                         8'd2,  //  tree_addr = set_type(tree_addr, SPX_ADDR_TYPE_HASHTREE)
                         16'd0,
                         32'd0,
                         8'h0,
                         last_tree_height,
                         last_tree_index,
                         80'd0};

assign	rst_last_tree_height_index = ((cu_st == S_HASH_MESSAGE) || (cu_st == S_FORS_SIGN)) && (ne_st == S_WOTS_SIGN);

// ------------------------------------------------------
//  Takes a n-byte message and the 32-byte sk_see to compute a signature 'sig'.
always @(posedge clk) begin
    if (~rstn) begin
        en_wots_sign <= 1'd0;
    end
    else begin
        en_wots_sign <= (cu_st != S_WOTS_SIGN) && (ne_st == S_WOTS_SIGN);
    end
end

//    for (i = 0; i < SPX_D; i++) {
always @(posedge clk) begin
    if (~rstn) begin
        cnt_i <= 'd0;
    end
    else if (cu_st == S_IDLE) begin
        cnt_i <= 'd0;
    end
    else if ((cu_st == S_TREEHASH) && sign_dict_treehash_done) begin
        cnt_i <= cnt_i + 1'b1;
    end
end

//        set_layer_addr(tree_addr, i);
//        set_tree_addr(tree_addr, tree);
//
//        copy_subtree_addr(wots_addr, tree_addr);
//        set_keypair_addr(wots_addr, idx_leaf);
always @(*) begin
    case (cnt_i)
        4'd1 : wots_sign_hash_message_tree_shift = {8'd0, hash_message_tree[55:8]};
        4'd2 : wots_sign_hash_message_tree_shift = {16'd0, hash_message_tree[55:16]};
        4'd3 : wots_sign_hash_message_tree_shift = {24'd0, hash_message_tree[55:24]};
        4'd4 : wots_sign_hash_message_tree_shift = {32'd0, hash_message_tree[55:32]};
        4'd5 : wots_sign_hash_message_tree_shift = {40'd0, hash_message_tree[55:40]};
        4'd6 : wots_sign_hash_message_tree_shift = {48'd0, hash_message_tree[55:48]};
        4'd7 : wots_sign_hash_message_tree_shift =  56'd0;
        default : wots_sign_hash_message_tree_shift = hash_message_tree;
    endcase
end
always @(*) begin
    case (cnt_i)
        4'd1   : wots_sign_leaf_idx = hash_message_tree[7:0];
        4'd2   : wots_sign_leaf_idx = hash_message_tree[15:8];
        4'd3   : wots_sign_leaf_idx = hash_message_tree[23:16];
        4'd4   : wots_sign_leaf_idx = hash_message_tree[31:24];
        4'd5   : wots_sign_leaf_idx = hash_message_tree[39:32];
        4'd6   : wots_sign_leaf_idx = hash_message_tree[47:40];
        4'd7   : wots_sign_leaf_idx = hash_message_tree[55:48];
        default : wots_sign_leaf_idx = hash_message_leaf_idx;
    endcase
end
assign	wots_sign_in_wots_addr = {4'd0, cnt_i,
                                  8'd0,
                                  wots_sign_hash_message_tree_shift, //hash_message_tree,
                                  32'd0,
                                  wots_sign_leaf_idx,
                                  24'd0,
                                  wots_sign_cnt_i,
                                  24'd0,
                                  4'd0, wots_sign_cnt_start,
                                  80'd0};
assign	wots_sign_msg = (debug && (cnt_i == 'd0)) ? {256'h43ad5ff2f887f82dc1eb46abb88ef72597810c3d7aac5e5d88cd84c37b046d9b} : fors_sign_root;

// ------------------------------------------------------
// sha256 core
assign	sha256_start = gen_message_random_sha256_start ||
                       hash_message_sha256_start       ||
                       fors_sign_sha256_start          ||
                       wots_sign_sha256_start          ;
assign	sha256_1st   = gen_message_random_sha256_1st   ||
                       hash_message_sha256_1st         ||
                       fors_sign_sha256_1st            ||
                       wots_sign_sha256_1st            ;

assign	sha256_seed  = fors_sign_sha256_seed           ;
assign	sha256_final = gen_message_random_sha256_final ||
                       hash_message_sha256_final       ||
                       fors_sign_sha256_final          ||
                       wots_sign_sha256_final          ;
assign	sha256_state = (cu_st == S_GEN_MESSAGE_RANDOM) ? gen_message_random_sha256_state :
                       (cu_st == S_HASH_MESSAGE      ) ? hash_message_sha256_state       :
                      ((cu_st == S_FORS_SIGN) || wots_sign_thash_mode || sign_dict_treehash_mode) ? fors_sign_sha256_state :
                       (cu_st == S_WOTS_SIGN         ) ? wots_sign_sha256_state          : 'd0;
assign	sha256_din   = (cu_st == S_GEN_MESSAGE_RANDOM) ? gen_message_random_sha256_data  :
                       (cu_st == S_HASH_MESSAGE      ) ? hash_message_sha256_data        :
                      ((cu_st == S_FORS_SIGN) || wots_sign_thash_mode || sign_dict_treehash_mode) ? fors_sign_sha256_data  :
                       (cu_st == S_WOTS_SIGN         ) ? wots_sign_sha256_data           : 'd0;
assign	sha256_len   = (cu_st == S_GEN_MESSAGE_RANDOM) ? gen_message_random_sha256_len   :
                       (cu_st == S_HASH_MESSAGE      ) ? hash_message_sha256_len         :
                      ((cu_st == S_FORS_SIGN) || wots_sign_thash_mode || sign_dict_treehash_mode) ? fors_sign_sha256_len  :
                       (cu_st == S_WOTS_SIGN         ) ? wots_sign_sha256_len            : 'd0;

// ------------------------------------------------------
// data output  -----   sig
assign	dout_vld = gen_message_random_dout_vld || fors_sign_sig_vld || wots_sign_sig_vld;
always @(*) begin
    case(cu_st)
        S_GEN_MESSAGE_RANDOM : dout = gen_message_random_dout;
        S_FORS_SIGN          : dout = fors_sign_dout;
        S_WOTS_SIGN          : dout = wots_sign_dout;
        S_TREEHASH           : dout = fors_sign_dout;
        default              : dout = 'd0;
    endcase
end

endmodule
