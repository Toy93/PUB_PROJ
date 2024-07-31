// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/06 08:19
// Last Modified : 2024/06/13 23:10
// File Name     : crypto_sign.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/06   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
`include "gdefine.v"
module crypto_sign (
	input           clk             ,
	input           rstn	        ,
	input           start           ,
	output          dout_vld        ,
	output [255:0]	dout		    //sig
);

/*autowire*/
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here
    wire                        sha256_done_me                  ;
    wire [255:0]                sha256_dout_me                  ;
    //End of automatic wire

// gen_message_random
wire		en_gen_message_random;
wire		gen_message_random_mem_ren;
wire	[`MEM_ADDR_WIDTH-1:0]	gen_message_random_mem_raddr;
wire		gen_message_random_dout_vld;
wire	[255:0]	gen_message_random_dout;

wire		gen_message_random_sha256_start;
wire		gen_message_random_sha256_1st;
wire		gen_message_random_sha256_final;
wire	[255:0]	gen_message_random_sha256_state;
wire	[511:0]	gen_message_random_sha256_data;
wire	[6:0]	gen_message_random_sha256_len;

// hash_message
wire		en_hash_message;
wire		hash_message_mem_ren;
wire	[`MEM_ADDR_WIDTH-1:0]	hash_message_mem_raddr;
wire		hash_message_dout_vld;
wire	[55:0]	hash_message_tree;
wire	[7:0]	hash_message_leaf_idx;
wire	[311:0]	hash_message_dout;

wire		hash_message_sha256_start;
wire		hash_message_sha256_1st;
wire		hash_message_sha256_final;
wire	[255:0]	hash_message_sha256_state;
wire	[511:0]	hash_message_sha256_data;
wire	[6:0]	hash_message_sha256_len;

// fors_sign hash_message
wire		en_fors_sign;
wire	[255:0]	fors_sign_in_wots_addr;
wire	[255:0]	top_tree_addr;
wire		fors_sign_sha256_start;
wire		fors_sign_sha256_1st;
wire		fors_sign_sha256_seed;
wire		fors_sign_sha256_final;
wire	[255:0]	fors_sign_sha256_state;
wire	[511:0]	fors_sign_sha256_data;
wire	[6:0]	fors_sign_sha256_len;

wire		fors_sign_sig_vld;
wire		fors_sign_dout_vld;
wire	[255:0]	fors_sign_root;
wire	[255:0]	fors_sign_dout;

wire		en_sign_dict_treehash;
wire		sign_dict_treehash_mode;
wire		sign_dict_treehash_done;
wire	[7:0]	last_tree_height;
wire	[31:0]	last_tree_index;
wire		rst_last_tree_height_index;

// wots_sign hash_message
wire		en_wots_sign;
wire	[55:0]	wots_sign_hash_message_tree_shift;
wire	[7:0]	wots_sign_leaf_idx;
wire	[255:0]	wots_sign_in_wots_addr;
wire	[255:0]	wots_sign_msg;
wire		wots_sign_sha256_start;
wire		wots_sign_sha256_1st;
wire		wots_sign_sha256_seed;
wire		wots_sign_sha256_final;
wire	[255:0]	wots_sign_sha256_state;
wire	[511:0]	wots_sign_sha256_data;
wire	[6:0]	wots_sign_sha256_len;

wire		wots_sign_sig_vld;
wire		wots_sign_thash_start;
wire		wots_sign_thash_mode;
wire		wots_sign_dout_vld;
wire	[255:0]	wots_sign_root;
wire	[7:0]	wots_sign_cnt_i;
wire	[3:0]	wots_sign_cnt_start;
wire	[255:0]	wots_sign_dout;

// sha256 core
wire		sha256_start;
wire		sha256_1st;
wire		sha256_seed;
wire		sha256_final;
wire	[255:0]	sha256_state;
wire	[511:0]	sha256_din;
wire		sha256_done;
wire	[255:0]	sha256_dout;
wire	[6:0]	sha256_len;

//reg	[255:0] mem [`MEM_DEPTH-1:0];
wire	[255:0] mem_dout;
wire		mem_ren;
wire	[`MEM_ADDR_WIDTH-1:0] mem_raddr;
 
// ------------------------------------------------------
// all input parameter
wire	[255:0]	sk_seed, sk_prf, pk_seed, pk_root, R;
wire	[`MLEN_WIDTH-1:0]	mlen;
//assign sk = {sk_seed, sk_prf, pk_seed, pk_root}
assign	sk_seed = 256'h7c9935a0b07694aa0c6d10e4db6b1add2fd81a25ccb148032dcd739936737f2d;
assign	sk_prf  = 256'hb505d7cfad1b497499323c8686325e4792f267aafa3f87ca60d01cb54f29202a;
assign	pk_seed = 256'h3e784ccb7ebcdcfd45542b7f6af778742e0f4479175084aa488b3b74340678aa;
assign	pk_root = 256'h75f71fc57e89707ba9654d9e80fefa2e8bd7606ec1b0452c3759ee737650e1f4;
assign	R       = 256'hee716762c15e3b72aa7650a63b9a510040b03c0fe70475c0463bbc45a0ba5b79;

assign	mlen    = `MLEN_WIDTH'h21;

// ------------------------------------------------------
// main FSM
main_fsm main_fsm_i0 (
	.clk					(clk),
	.rstn					(rstn),
	.start					(start),

// gen_message_random
	.en_gen_message_random			(en_gen_message_random),
	.gen_message_random_dout_vld		(gen_message_random_dout_vld),

	.gen_message_random_sha256_start	(gen_message_random_sha256_start),
	.gen_message_random_sha256_1st		(gen_message_random_sha256_1st),
	.gen_message_random_sha256_final	(gen_message_random_sha256_final),
	.gen_message_random_sha256_state	(gen_message_random_sha256_state),
	.gen_message_random_sha256_data		(gen_message_random_sha256_data),
	.gen_message_random_sha256_len		(gen_message_random_sha256_len),

// hash_message
	.en_hash_message			(en_hash_message),
	.hash_message_dout_vld			(hash_message_dout_vld),
	.hash_message_tree			(hash_message_tree),
	.hash_message_leaf_idx			(hash_message_leaf_idx),

	.hash_message_sha256_start		(hash_message_sha256_start),
	.hash_message_sha256_1st		(hash_message_sha256_1st),
	.hash_message_sha256_final		(hash_message_sha256_final),
	.hash_message_sha256_state		(hash_message_sha256_state),
	.hash_message_sha256_data		(hash_message_sha256_data),
	.hash_message_sha256_len		(hash_message_sha256_len),

// fors_sign hash_message
	.en_fors_sign				(en_fors_sign),
	.fors_sign_in_wots_addr			(fors_sign_in_wots_addr),
	.top_tree_addr				(top_tree_addr),
	.fors_sign_sha256_start			(fors_sign_sha256_start),
	.fors_sign_sha256_1st			(fors_sign_sha256_1st),
	.fors_sign_sha256_seed			(fors_sign_sha256_seed),
	.fors_sign_sha256_final			(fors_sign_sha256_final),
	.fors_sign_sha256_state			(fors_sign_sha256_state),
	.fors_sign_sha256_data			(fors_sign_sha256_data),
	.fors_sign_sha256_len			(fors_sign_sha256_len),

	.fors_sign_dout_vld			(fors_sign_dout_vld),
	.fors_sign_root				(fors_sign_root),

	.en_sign_dict_treehash			(en_sign_dict_treehash),
	.sign_dict_treehash_mode		(sign_dict_treehash_mode),
	.sign_dict_treehash_done		(sign_dict_treehash_done),
	.last_tree_height			(last_tree_height),
	.last_tree_index			(last_tree_index),
	.rst_last_tree_height_index		(rst_last_tree_height_index),

// wots_sign hash_message
	.en_wots_sign				(en_wots_sign),
	.wots_sign_hash_message_tree_shift	(wots_sign_hash_message_tree_shift),
	.wots_sign_leaf_idx			(wots_sign_leaf_idx),
	.wots_sign_in_wots_addr			(wots_sign_in_wots_addr),
	.wots_sign_msg				(wots_sign_msg),
	.wots_sign_sha256_start			(wots_sign_sha256_start),
	.wots_sign_sha256_1st			(wots_sign_sha256_1st),
	.wots_sign_sha256_seed			(wots_sign_sha256_seed),
	.wots_sign_sha256_final			(wots_sign_sha256_final),
	.wots_sign_sha256_state			(wots_sign_sha256_state),
	.wots_sign_sha256_data			(wots_sign_sha256_data),
	.wots_sign_sha256_len			(wots_sign_sha256_len),

	.wots_sign_thash_mode			(wots_sign_thash_mode),
	.wots_sign_dout_vld			(wots_sign_dout_vld),
	.wots_sign_cnt_i			(wots_sign_cnt_i),
	.wots_sign_cnt_start			(wots_sign_cnt_start),

// sha256 core
	.sha256_start				(sha256_start),
	.sha256_1st				(sha256_1st),
	.sha256_seed				(sha256_seed),
	.sha256_final				(sha256_final),
	.sha256_state				(sha256_state),
	.sha256_din				(sha256_din),
	.sha256_len				(sha256_len),

// output
	.fors_sign_sig_vld		(fors_sign_sig_vld),
	.wots_sign_sig_vld		(wots_sign_sig_vld),

	.gen_message_random_dout	(gen_message_random_dout),
	.fors_sign_dout			(fors_sign_dout),
	.wots_sign_dout			(wots_sign_dout),

	.dout_vld			(dout_vld),
	.dout				(dout));

gen_message_random gen_message_random_i0 (
	.clk		(clk),
        .rstn		(rstn),

	.start		(en_gen_message_random),

	.sk_prf		(sk_prf),
	.optrand	(R),

	.mem_ren	(gen_message_random_mem_ren),
	.mem_raddr	(gen_message_random_mem_raddr),
	.mem_rdata	(mem_dout),

       	.mlen		(mlen),

	.sha256_start	(gen_message_random_sha256_start),
	.sha256_1st	(gen_message_random_sha256_1st),
	.sha256_final	(gen_message_random_sha256_final),
	.sha256_state	(gen_message_random_sha256_state),
	.sha256_data	(gen_message_random_sha256_data),
	.sha256_len	(gen_message_random_sha256_len),
	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.dout_vld	(gen_message_random_dout_vld),
	.dout		(gen_message_random_dout));

hash_message hash_message_i0 (
	.clk		(clk),
        .rstn		(rstn),

	.start		(en_hash_message),

	.R		(gen_message_random_dout), // sig
	.pk_seed	(pk_seed),
	.pk_root	(pk_root),

	.mem_ren	(hash_message_mem_ren),
	.mem_raddr	(hash_message_mem_raddr),
	.mem_rdata	(mem_dout),

       	.mlen		(mlen),

	.sha256_start	(hash_message_sha256_start),
	.sha256_1st	(hash_message_sha256_1st),
	.sha256_final	(hash_message_sha256_final),
	.sha256_state	(hash_message_sha256_state),
	.sha256_data	(hash_message_sha256_data),
	.sha256_len	(hash_message_sha256_len),
	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.dout_vld	(hash_message_dout_vld),
	.tree		(hash_message_tree),
	.leaf_idx	(hash_message_leaf_idx),
	.dout		(hash_message_dout)); // mhash

fors_sign fors_sign_i0 (
  	.clk		(clk),
  	.rstn		(rstn),

  	.start		(en_fors_sign),
	.rst_start_i	(rst_last_tree_height_index),

	.mhash		(hash_message_dout),
	.sk_seed	(sk_seed),
	.pub_seed	(pk_seed),
	.wots_addr	(sign_dict_treehash_mode ? top_tree_addr : fors_sign_in_wots_addr),
        .wots_leaf_idx	(wots_sign_leaf_idx),

	.sha256_start	(fors_sign_sha256_start),
	.sha256_1st	(fors_sign_sha256_1st),
	.sha256_seed	(fors_sign_sha256_seed),
	.sha256_final	(fors_sign_sha256_final),
	.sha256_state	(fors_sign_sha256_state),
	.sha256_data	(fors_sign_sha256_data),
	.sha256_len	(fors_sign_sha256_len),
  	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.wots_sign_thash_mode	(wots_sign_thash_mode),
	.wots_sign_thash_start	(wots_sign_thash_start),
	.wots_sign_thash_1st	(wots_sign_sha256_1st),
	.wots_sign_thash_final	(wots_sign_sha256_final),
	.wots_sign_thash_state	(wots_sign_sha256_state),
	.wots_sign_thash_data	(wots_sign_sha256_data),
	.wots_sign_thash_len	(wots_sign_sha256_len),

        .en_sign_dict_treehash	(en_sign_dict_treehash),
        .sign_dict_treehash_mode(sign_dict_treehash_mode),
        .sign_dict_treehash_done(sign_dict_treehash_done),
	.last_tree_height	(last_tree_height),
	.last_tree_index	(last_tree_index),

	.sig_vld	(fors_sign_sig_vld),
	.dout_vld	(fors_sign_dout_vld),
	.root		(fors_sign_root),
	.dout		(fors_sign_dout));// sig

wots_sign wots_sign_i0 (
  	.clk		(clk),
  	.rstn		(rstn),

  	.start		(en_wots_sign),
	.rst_start_i	(gen_message_random_dout_vld),

	.msg		(wots_sign_msg),
	.sk_seed	(sk_seed),
	.pub_seed	(pk_seed),
	.wots_addr	(wots_sign_in_wots_addr),

	.sha256_start	(wots_sign_sha256_start),
	.sha256_1st	(wots_sign_sha256_1st),
	.sha256_final	(wots_sign_sha256_final),
	.sha256_state	(wots_sign_sha256_state),
	.sha256_data	(wots_sign_sha256_data),
	.sha256_len	(wots_sign_sha256_len),
  	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.thash_start	(wots_sign_thash_start),
	.thash_mode	(wots_sign_thash_mode),
	.sig_vld	(wots_sign_sig_vld),
	.dout_vld	(wots_sign_dout_vld),
	.root		(wots_sign_root),
	.cnt_i_reg	(wots_sign_cnt_i),
	.cnt_start_reg	(wots_sign_cnt_start),
	.dout		(wots_sign_dout));// sig

	CRYPTO_HASHBLOCKS_SHA256_ME CRYPTO_HASHBLOCKS_SHA256_ME(/*autoinst*/
        .clk                    (clk                            ), //input
        .rst_n                  (rstn                           ), //input
        .start                  (sha256_start                   ), //input
        .block_1st              (sha256_1st                     ), //input
        .pub_seed               (sha256_seed                    ), //input
        .block_final            (sha256_final                   ), //input
        .statebytes_i           (sha256_state                   ), //input
        .in                     (sha256_din                     ), //input
        .len                    (sha256_len                     ), //input
        //.dout_vld               (sha256_done_me                 ), //output
        //.statebytes_o           (sha256_dout_me[255:0]          )  //output
        .dout_vld               (sha256_done                    ), //output
        .statebytes_o           (sha256_dout                    )  //output
    );

	//crypto_hashblocks_sha256 sha256_core (/*autoinst*/
    //    .clk                    (clk                            ), //input
    //    .rstn                   (rstn                           ), //input
    //    .start                  (sha256_start                   ), //input
    //    .block_1st              (sha256_1st                     ), //input
    //    .pub_seed               (sha256_seed                    ), //input
    //    .block_final            (sha256_final                   ), //input
    //    .statebytes             (sha256_state                   ), //input
    //    .in                     (sha256_din                     ), //input
    //    .len                    (sha256_len                     ), //input
    //    .dout_vld               (sha256_done)					, //output
    //    .dout                   (sha256_dout)  //output
    //);

// msg data memory
in_rom in_rom_i0(
	.clk				(clk),
	.rstn				(rstn),
	.gen_message_random_mem_ren	(gen_message_random_mem_ren),
	.hash_message_mem_ren		(hash_message_mem_ren),

	.gen_message_random_mem_raddr	(gen_message_random_mem_raddr),
	.hash_message_mem_raddr		(hash_message_mem_raddr),

	.mem_dout			(mem_dout));

endmodule
