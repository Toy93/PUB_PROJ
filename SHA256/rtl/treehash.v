`include "gdefine.v"
module treehash (
input		clk,
input		rstn,

input		start,
input		rst_start_i,

input	[255:0]	sk_seed,
input	[255:0]	pub_seed,
input	[23:0]	leaf_idx,
input	[18:0]	idx_offset,
input	[3:0]	tree_height,
input	[255:0]	tree_addr,
input		fors_mode,

input		en_dict_thash,
input		dict_thash,
output		dict_thash_done,

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
output	reg [7:0] last_tree_height,
output	reg [31:0] last_tree_index,

output	reg	sig_vld,
output	reg	dout_vld,
output	[255:0]	root,
output	[255:0]	auth_path);	// sig

// ------------------------------------------------------
// parameter
parameter S_IDLE        = 5'd0;
parameter S_CUT0        = 5'd1;
parameter S_GEN_LEAF0   = 5'd2;
parameter S_CUT1        = 5'd3;
parameter S_GEN_LEAF1   = 5'd4;
parameter S_READY0      = 5'd5;
parameter S_WHILE       = 5'd6;
parameter S_CUT2        = 5'd7;
parameter S_THASH       = 5'd8;
parameter S_READY1      = 5'd9;
parameter S_READY2      = 5'd10;
parameter S_IDX         = 5'd11;
parameter S_OUT         = 5'd12;
parameter W_CUT0        = 5'd13;
parameter W_GEN_SK      = 5'd14;
parameter W_CUT1        = 5'd15;
parameter W_GEN_CHAIN   = 5'd16;
parameter W_JUDGE       = 5'd17;
parameter W_CUT2        = 5'd18;
parameter W_THASH       = 5'd19;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };

// ------------------------------------------------------
// wire && reg
reg	[4:0]	cu_st, ne_st;
reg	[31:0]	idx;
reg	[3:0]	offset;

reg	[7:0]	heights[14:0];// unsigned int heights[tree_height + 1];

// # stack depth is 15
// # wots pk depth is 67
reg	[255:0]	stack[15:0];// unsigned char stack[(tree_height + 1)*SPX_N];
reg	[255:0]	wots_gen_leaf_pk[66:0];// wots_gen_leaf --> pk
reg	[255:0]	auth_path_mem[14:0];
wire		thash_r_stack_en;
wire	[6:0]	thash_r_stack_addr;
reg	[255:0]	stack_out;
reg	[255:0]	wots_gen_leaf_pk_out;
wire	[255:0]	thash_r_stack_dout;

wire		need_while;

reg	[255:0]	fors_tree_addr;
wire	[255:0]	fors_pk_addr;

reg		en_thash;
wire		thash_din_vld;
wire	[255:0]	thash_din;
wire	[6:0]	thash_din_addr;
wire	[6:0]	inblocks_addr;
reg	[6:0]	inblocks;
wire		leaf_en;
reg	[255:0]	thash_addr;
wire	[255:0]	gen_chain_addr;
wire		thash_sha256_start;
wire		thash_sha256_1st;
wire		thash_sha256_seed;
wire		thash_sha256_final;
wire	[255:0]	thash_sha256_state;
wire	[511:0]	thash_sha256_data;
wire	[6:0]	thash_sha256_len;
wire		thash_sha256_done;
wire	[255:0]	thash_sha256_dout;
wire		thash_dout_vld;
wire	[255:0]	thash_dout;

reg	[31:0]	tree_idx;
wire	[7:0]	set_tree_height;
wire	[31:0]	set_tree_index;
reg	[7:0]	reg_tree_height;
reg	[31:0]	reg_tree_index;

reg	[511:0]	buffer;
reg	[255:0]	last_data;
reg	[255:0]	state;
wire		consump_en;
reg	[`MLEN_WIDTH-1:0]	len;

wire		wots_gen_leaf_done;

// -------------------------------------
// auth_path mem
wire		auth_path_wen0;
wire		auth_path_wen1;
wire		read_auth_path_en;
reg	[3:0]	read_auth_path_addr;
reg	[255:0]	auth_path_tmp;

// -------------------------------------
// wots function 
reg	[6:0]	wots_gen_pk_cnt;
reg	[3:0]	gen_chain_cnt;

// -------------------------------------
// root mem
wire		w_root_mem_en;
reg	[255:0]	root_mem[21:0];
wire		thash_r_root_en;
wire	[4:0]	thash_r_root_addr;
reg	[255:0]	root_out;
wire	[255:0]	thash_r_root_dout;

integer	i;

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
        S_IDLE      : begin
            if (start) begin
                ne_st = S_CUT0;
            end
            else if (en_sign_dict_treehash) begin
                ne_st = W_CUT0;
            end
            else begin
                ne_st = S_IDLE;
            end
        end

        // fors_gen_leaf
        S_CUT0      : ne_st = S_GEN_LEAF0;
        // fors_gen_sk(leaf, sk_seed, fors_leaf_addr);
        S_GEN_LEAF0 : ne_st = sha256_done    ? S_CUT1   : S_GEN_LEAF0;
        S_CUT1      : ne_st = S_GEN_LEAF1;
        // fors_sk_to_leaf(leaf, leaf, pub_seed, fors_leaf_addr);
        S_GEN_LEAF1 : ne_st = thash_dout_vld ? S_READY0 : S_GEN_LEAF1;

// shared
        S_READY0    : ne_st = S_WHILE;

        S_WHILE     : ne_st = need_while     ? S_CUT2   : S_IDX;

        S_CUT2      : ne_st = S_THASH;
        S_THASH     : ne_st = thash_dout_vld ? S_READY1 : S_THASH;

        S_READY1    : ne_st = S_READY2;
        S_READY2    : ne_st = S_WHILE;

        S_IDX       : ne_st = (idx < (sign_dict_treehash_mode ? 15'd255 : 15'd16383)/* (1'b1 << tree_height)*/) ? (sign_dict_treehash_mode ? W_CUT0 : S_CUT0) : S_OUT;

        //  Read auth_path RAM
        S_OUT       : ne_st = (sign_dict_treehash_mode ? (read_auth_path_addr == 4'd7) : (read_auth_path_addr == 4'd13)) ? S_IDLE : S_OUT;

// --------------------------------------
// Computes the leaf at a given address. First generates the WOTS key pair,
//  then computes leaf by hashing horizontally.
// static void wots_gen_leaf(unsigned char *leaf, const unsigned char *sk_seed,
//                           const unsigned char *pub_seed,
//                           uint32_t addr_idx, const uint32_t tree_addr[8])
//      wots_gen_leaf -> wots_gen_pk -> wots_gen_sk
        W_CUT0      : ne_st = W_GEN_SK;
        W_GEN_SK    : ne_st = sha256_done    ? W_CUT1  : W_GEN_SK   ;

        W_CUT1      : ne_st = W_GEN_CHAIN;
        W_GEN_CHAIN : begin
            if (thash_dout_vld) begin
// for (i = start; i < (start+steps) && i < SPX_WOTS_W; i++)
//    i  ===   gen_chain_cnt
                if (((gen_chain_cnt+1'b1) < (`SPX_WOTS_W-1'b1)) && (gen_chain_cnt < `SPX_WOTS_W)) begin
                    ne_st = W_CUT1;
                end
                else begin
                    ne_st = W_JUDGE;
                end
            end
            else begin
                ne_st = W_GEN_CHAIN;
            end
        end

        // wots_gen_pk : for (i = 0; i < SPX_WOTS_LEN; i++) {
        W_JUDGE     : ne_st = (wots_gen_pk_cnt<`SPX_WOTS_LEN-1) ? W_CUT0 : W_CUT2;

        W_CUT2      : ne_st = W_THASH;
        W_THASH     : ne_st = thash_dout_vld ? S_READY0 : W_THASH;

        default     : ne_st = S_IDLE;
    endcase
end

// -------------------------------------
// idx --> for (idx = 0; idx < (uint32_t)(1 << tree_height); idx++) {
always @(posedge clk) begin
    if (~rstn) begin
        idx <= 'd0;
    end
    else if (start || en_sign_dict_treehash || (cu_st == S_OUT)) begin
        idx <= 'd0;
    end
    else if (cu_st == S_IDX) begin
        idx <= idx + 1'b1;
    end
end

// -------------------------------------
// offset
always @(posedge clk) begin
    if (~rstn) begin
        offset <= 'd0;
    end
    else if (start || en_sign_dict_treehash) begin
        offset <= 'd0;
    end
    else if (wots_gen_leaf_done) begin
        offset <= offset + 1'b1;
    end
    else if (thash_dout_vld) begin
        if (cu_st == S_THASH) begin
            offset <= offset - 1'b1;
        end
        else if (cu_st == S_GEN_LEAF1) begin
            offset <= offset + 1'b1;
        end
    end
end

// -------------------------------------
// heights 
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<15;i=i+1)
            heights[i] <= 'd0;
    end
    else if (start || en_sign_dict_treehash) begin
        for (i=0;i<15;i=i+1)
            heights[i] <= 'd0;
    end
    else if (cu_st == S_READY1) begin
        heights[offset - 1] <= heights[offset - 1] + 1'b1;
    end
    else if (cu_st == S_READY0) begin
        heights[offset - 1] <= 'd0;
    end
end

assign	need_while = (offset >= 3'd2) && (heights[offset-1] == heights[offset-2]);

// -------------------------------------
// wots_gen_leaf --> pk
`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<67;i=i+1)
            wots_gen_leaf_pk[i] <= 'd0;
    end
    else if (cu_st == W_JUDGE) begin
        wots_gen_leaf_pk[wots_gen_pk_cnt] <= sha256_state;
    end
end
always @(posedge clk) begin
    if (~rstn) begin
        wots_gen_leaf_pk_out <= 'd0;
    end
    else if (thash_r_stack_en) begin
        wots_gen_leaf_pk_out <= wots_gen_leaf_pk[thash_r_stack_addr];
    end
end
    
`else
wire		write_wots_gen_leaf_pk_en;
wire	[6:0]	write_wots_gen_leaf_pk_addr;
wire	[255:0]	write_wots_gen_leaf_pk_data;
wire		read_wots_gen_leaf_pk_en;
wire	[6:0]	read_wots_gen_leaf_pk_addr;
wire	[255:0]	read_wots_gen_leaf_pk_data;
wire	[6:0]	wots_gen_leaf_pk_addr;
assign	write_wots_gen_leaf_pk_en   = cu_st == W_JUDGE;
assign	write_wots_gen_leaf_pk_addr = wots_gen_pk_cnt;
assign	write_wots_gen_leaf_pk_data = sha256_state;
assign	read_wots_gen_leaf_pk_en    = thash_r_stack_en;
assign	read_wots_gen_leaf_pk_addr  = thash_r_stack_addr;
assign	wots_gen_leaf_pk_addr       = write_wots_gen_leaf_pk_en ? write_wots_gen_leaf_pk_addr : read_wots_gen_leaf_pk_addr;

	altsyncram	wots_gen_leaf_pk_altsyncram_component (
				.address_a (wots_gen_leaf_pk_addr),
				.clock0 (clk),
				.data_a (write_wots_gen_leaf_pk_data),
				.wren_a (write_wots_gen_leaf_pk_en),
				.rden_a (read_wots_gen_leaf_pk_en),
				.q_a (read_wots_gen_leaf_pk_data),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		wots_gen_leaf_pk_altsyncram_component.clock_enable_input_a = "BYPASS",
		wots_gen_leaf_pk_altsyncram_component.clock_enable_output_a = "BYPASS",
		wots_gen_leaf_pk_altsyncram_component.intended_device_family = "Cyclone IV E",
		wots_gen_leaf_pk_altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		wots_gen_leaf_pk_altsyncram_component.lpm_type = "altsyncram",
		wots_gen_leaf_pk_altsyncram_component.numwords_a = 128,
		wots_gen_leaf_pk_altsyncram_component.operation_mode = "SINGLE_PORT",
		wots_gen_leaf_pk_altsyncram_component.outdata_aclr_a = "NONE",
		wots_gen_leaf_pk_altsyncram_component.outdata_reg_a = "UNREGISTERED",
		wots_gen_leaf_pk_altsyncram_component.power_up_uninitialized = "FALSE",
		wots_gen_leaf_pk_altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		wots_gen_leaf_pk_altsyncram_component.widthad_a = 7,
		wots_gen_leaf_pk_altsyncram_component.width_a = 256,
		wots_gen_leaf_pk_altsyncram_component.width_byteena_a = 1;

`endif

// -------------------------------------
// stack 
`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<16;i=i+1)
            stack[i] <= 'd0;
    end
    else if (start || en_sign_dict_treehash) begin
        for (i=0;i<16;i=i+1)
            stack[i] <= 'd0;
    end
//    else if (cu_st == W_JUDGE) begin
//        stack[wots_gen_pk_cnt] <= sha256_state;
//    end
    else if (thash_dout_vld) begin
        if ((cu_st == S_GEN_LEAF1) || (cu_st == W_THASH)) begin
            stack[offset] <= state;
        end
        else if (cu_st == S_THASH) begin
            stack[offset-2] <= state;
        end
    end
//    else if (sha256_done) begin
//        if (cu_st == W_GEN_SK) begin
//            stack[wots_gen_pk_cnt] <= sha256_dout;
//        end
//    end
end

always @(posedge clk) begin
    if (~rstn) begin
        stack_out <= 'd0;
    end
    else if ((cu_st == S_OUT) && (read_auth_path_addr == 4'd0)) begin
        stack_out <= stack[0];
    end
    else if (thash_r_stack_en) begin
        stack_out <= stack[thash_r_stack_addr];
    end
end
assign thash_r_stack_dout = (cu_st == W_THASH) ? wots_gen_leaf_pk_out : stack_out; 

`else

wire		write_stack_en;
wire	[3:0]	write_stack_addr;
wire	[255:0]	write_stack_data;
wire		read_stack_en;
wire	[3:0]	read_stack_addr;
wire	[255:0]	read_stack_data;
wire	[3:0]	stack_addr;
assign	write_stack_en   = thash_dout_vld && ((cu_st == S_GEN_LEAF1) || (cu_st == W_THASH) || (cu_st == S_THASH));
assign	write_stack_addr = ((cu_st == S_GEN_LEAF1) || (cu_st == W_THASH)) ? offset : offset-2'd2;
assign	write_stack_data = state;
assign	read_stack_en    = ((cu_st == S_OUT) && (read_auth_path_addr == 4'd0)) || thash_r_stack_en;
assign	read_stack_addr  = thash_r_stack_en ? thash_r_stack_addr[3:0] : 'd0;
assign	stack_addr       = write_stack_en ? write_stack_addr : read_stack_addr;

	altsyncram	stack_altsyncram_component (
				.address_a (stack_addr),
				.clock0 (clk),
				.data_a (write_stack_data),
				.wren_a (write_stack_en),
				.rden_a (read_stack_en),
				.q_a (read_stack_data),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		stack_altsyncram_component.clock_enable_input_a = "BYPASS",
		stack_altsyncram_component.clock_enable_output_a = "BYPASS",
		stack_altsyncram_component.intended_device_family = "Cyclone IV E",
		stack_altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		stack_altsyncram_component.lpm_type = "altsyncram",
		stack_altsyncram_component.numwords_a = 16,
		stack_altsyncram_component.operation_mode = "SINGLE_PORT",
		stack_altsyncram_component.outdata_aclr_a = "NONE",
		stack_altsyncram_component.outdata_reg_a = "UNREGISTERED",
		stack_altsyncram_component.power_up_uninitialized = "FALSE",
		stack_altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		stack_altsyncram_component.widthad_a = 4,
		stack_altsyncram_component.width_a = 256,
		stack_altsyncram_component.width_byteena_a = 1;

assign thash_r_stack_dout = (cu_st == W_THASH) ? read_wots_gen_leaf_pk_data : read_stack_data; 
`endif

// -----------------------------------------
// wots_gen_pk_cnt  --> i
always @(posedge clk) begin
    if (~rstn) begin
        wots_gen_pk_cnt <= 'd0;
    end
    else if (en_sign_dict_treehash  || (cu_st == S_READY0)) begin
        wots_gen_pk_cnt <= 'd0;
    end
    else if (cu_st == W_JUDGE) begin
        wots_gen_pk_cnt <= wots_gen_pk_cnt + 1'b1;
    end
end

// gen_chain_cnt  --> i
always @(posedge clk) begin
    if (~rstn) begin
        gen_chain_cnt <= 'd0;
    end
    else if (cu_st == W_CUT0) begin
        gen_chain_cnt <= 'd0;
    end
    else if ((cu_st == W_GEN_CHAIN) && (ne_st == W_CUT1)) begin
        gen_chain_cnt <= gen_chain_cnt + 1'b1;
    end
end

// -------------------------------------
// root mem
assign	w_root_mem_en = (cu_st == S_OUT) && (read_auth_path_addr == 4'd1);
`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<22;i=i+1)
            root_mem[i] <= 'd0;
    end
    else if (w_root_mem_en) begin
        root_mem[idx_offset[18:14]] <= thash_r_stack_dout;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        root_out <= 'd0;
    end
    else if (thash_r_root_en) begin
        root_out <= root_mem[thash_r_root_addr];
    end
end
assign thash_r_root_dout = root_out; 
assign root = root_out; 

`else

wire		write_root_out_en;
wire	[4:0]	write_root_out_addr;
wire	[255:0]	write_root_out_data;
wire		read_root_out_en;
wire	[4:0]	read_root_out_addr;
wire	[255:0]	read_root_out_data;
wire	[4:0]	root_out_addr;
assign	write_root_out_en   = w_root_mem_en;
assign	write_root_out_addr = idx_offset[18:14];
assign	write_root_out_data = thash_r_stack_dout;
assign	read_root_out_en    = thash_r_root_en;
assign	read_root_out_addr  = thash_r_root_addr;
assign	root_out_addr       = write_root_out_en ? write_root_out_addr : read_root_out_addr;

	altsyncram	root_out_altsyncram_component (
				.address_a (root_out_addr),
				.clock0 (clk),
				.data_a (write_root_out_data),
				.wren_a (write_root_out_en),
				.rden_a (read_root_out_en),
				.q_a (read_root_out_data),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		root_out_altsyncram_component.clock_enable_input_a = "BYPASS",
		root_out_altsyncram_component.clock_enable_output_a = "BYPASS",
		root_out_altsyncram_component.intended_device_family = "Cyclone IV E",
		root_out_altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		root_out_altsyncram_component.lpm_type = "altsyncram",
		root_out_altsyncram_component.numwords_a = 32,
		root_out_altsyncram_component.operation_mode = "SINGLE_PORT",
		root_out_altsyncram_component.outdata_aclr_a = "NONE",
		root_out_altsyncram_component.outdata_reg_a = "UNREGISTERED",
		root_out_altsyncram_component.power_up_uninitialized = "FALSE",
		root_out_altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		root_out_altsyncram_component.widthad_a = 5,
		root_out_altsyncram_component.width_a = 256,
		root_out_altsyncram_component.width_byteena_a = 1;

assign thash_r_root_dout = read_root_out_data; 
assign root = read_root_out_data; 
`endif

// -------------------------------------
// thash
always @(posedge clk) begin
    if (~rstn) begin
        en_thash <= 1'd0;
    end
    else begin
        en_thash <= (cu_st == S_CUT1) ||
                    (cu_st == S_CUT2) ||
                    (cu_st == W_CUT1) ||
                    (cu_st == W_CUT2);
    end
end

//assign	thash_din_vld  = ((cu_st == W_GEN_SK) || (cu_st == W_GEN_CHAIN) || (cu_st == S_GEN_LEAF0)) && sha256_done;
assign	thash_din_vld  = (((cu_st == W_GEN_SK) || (cu_st == S_GEN_LEAF0)) && sha256_done) ||
                          ((cu_st == W_GEN_CHAIN) && thash_dout_vld);
assign	thash_din      = (cu_st == W_GEN_CHAIN) ? sha256_state : sha256_dout;
assign	thash_din_addr = 'd0;
assign	inblocks_addr  = (cu_st == S_THASH) ? offset - 2'd2 : 0;

//assign	inblocks  = sign_dict_treehash_mode ? 7'd1 : (dict_thash ? `SPX_FORS_TREES : ((cu_st == S_THASH) ? 7'd2 : 7'd1));
always @(*) begin
    if (sign_dict_treehash_mode) begin
        inblocks  = (cu_st == W_THASH) ? `SPX_WOTS_LEN : ((cu_st == S_THASH) ? 7'd2 : 7'd1);
    end
    else if (dict_thash) begin
        inblocks  = `SPX_FORS_TREES;
    end
    else if (cu_st == S_THASH) begin
        inblocks  = 7'd2;
    end
    else begin
        inblocks  = 7'd1;
    end
end
assign	leaf_en = (sign_dict_treehash_mode && (cu_st != W_THASH) && (cu_st != S_THASH)) ||
                  (cu_st == S_GEN_LEAF1);

always @(*) begin
    if (sign_dict_treehash_mode) begin
        if (cu_st == S_THASH) begin
            thash_addr = fors_tree_addr;
        end
        else if (cu_st == W_THASH) begin
            thash_addr = {tree_addr[255:184], 8'd1, idx, 144'd0}; //tree_addr[143:0]};
        end
        else begin
            thash_addr = gen_chain_addr;
        end
    end
    else if (dict_thash) begin
        thash_addr = fors_pk_addr;
    end
    else begin
        thash_addr = fors_tree_addr;
    end
end
thash thash_i0 (
	.clk		(clk),
	.rstn		(rstn),

	.start		(en_thash || en_dict_thash),

	.din_vld	(thash_din_vld),
	.din_addr	(thash_din_addr),
	.din		(thash_din),
	.inblocks	(inblocks),
	.inblocks_addr	(inblocks_addr),
	.pub_seed	(pub_seed),
	.addr		(thash_addr),

	.leaf_en	(leaf_en),

	.r_stack_en	(thash_r_stack_en),
	.r_stack_addr	(thash_r_stack_addr),
	.r_stack_dout	(thash_r_stack_dout),

	.root_en	(dict_thash),
	.r_root_en	(thash_r_root_en),
	.r_root_addr	(thash_r_root_addr),
	.r_root_dout	(thash_r_root_dout),

	.wots_sign_thash_mode	(wots_sign_thash_mode),
	.wots_sign_thash_start	(wots_sign_thash_start),
	.wots_sign_thash_1st	(wots_sign_thash_1st),
	.wots_sign_thash_final	(wots_sign_thash_final),
	.wots_sign_thash_state	(wots_sign_thash_state),
	.wots_sign_thash_data	(wots_sign_thash_data),
	.wots_sign_thash_len	(wots_sign_thash_len),

	.sha256_start	(thash_sha256_start),
	.sha256_1st	(thash_sha256_1st),
	.sha256_seed	(thash_sha256_seed),
	.sha256_final	(thash_sha256_final),
	.sha256_state	(thash_sha256_state),
	.sha256_data	(thash_sha256_data),
	.sha256_len	(thash_sha256_len),
	.sha256_done	(sha256_done),
	.sha256_dout	(sha256_dout),

	.dout_vld	(thash_dout_vld),
	.dout		(thash_dout));

always @(posedge clk) begin
    if (~rstn) begin
        tree_idx <= 'd0;
    end
    else if ((cu_st == S_WHILE) && (ne_st == S_CUT2)) begin
        tree_idx <= idx >> (heights[offset - 1] + 1'b1);
    end
end
//assign	tree_idx        = (idx >> (heights[offset - 1] + 1'b1));
assign	set_tree_height = heights[offset - 1] + 1'b1;
assign	set_tree_index  = tree_idx + (idx_offset >> (heights[offset-1] + 1'b1));
always @(posedge clk) begin
    if (~rstn) begin
        fors_tree_addr <= 'd0;
    end
    else if (cu_st == S_CUT0) begin
        fors_tree_addr <= {tree_addr[255:184], 8'd3, tree_addr[175:112], idx + idx_offset, 80'd0};
    end
    else if (cu_st == W_CUT0) begin
        fors_tree_addr <= {tree_addr[255:184], 8'd2, tree_addr[175:112], idx + idx_offset, 80'd0};
    end
    else if (cu_st == S_CUT2) begin
// /* Compute index of the new node, in the next layer. */
//    tree_idx = (idx >> (heights[offset - 1] + 1));
//
// /* Set the address of the node we're creating. */
//    set_tree_height(tree_addr, heights[offset - 1] + 1);
//    set_tree_index(tree_addr, tree_idx + (idx_offset >> (heights[offset-1] + 1)));
        fors_tree_addr <= {fors_tree_addr[255:120], set_tree_height, set_tree_index, fors_tree_addr[79:0]};
    end
//    else if (cu_st == W_CUT0) begin
//        fors_tree_addr <= {tree_addr[255:184], 8'd0, tree_addr[175:0]};
//    end
end
always @(posedge clk) begin
    if (~rstn) begin
        reg_tree_height <= 'd0;
        reg_tree_index  <= 'd0;
    end
    else if (cu_st == S_CUT2) begin
        reg_tree_height <= set_tree_height;
        reg_tree_index  <= set_tree_index;
    end
end
always @(posedge clk) begin
    if (~rstn) begin
        last_tree_height <= 'd0;
        last_tree_index  <= 'd0;
    end
    else if (rst_start_i) begin
        last_tree_height <= 'd0;
        last_tree_index  <= 'd0;
    end
    else if ((cu_st == S_OUT) && (ne_st == S_IDLE)) begin
        last_tree_height <= reg_tree_height;
        last_tree_index  <= reg_tree_index;
    end
end
assign	fors_pk_addr   = {tree_addr[255:184], 8'd4, tree_addr[175:0]};
assign	gen_chain_addr = {tree_addr[255:184],
                          8'd0,
                          idx,
                          tree_addr[143:120],
                          1'd0,wots_gen_pk_cnt,
                          tree_addr[111:88],
                          4'd0, gen_chain_cnt,
                          tree_addr[79:0]};

always @(*) begin
    case(cu_st)
        S_GEN_LEAF0 : buffer = {sk_seed, fors_tree_addr};
        W_GEN_SK    : buffer = {sk_seed, gen_chain_addr};
        default     : buffer = 'd0;
    endcase
end
//always @(posedge clk) begin
//    if (~rstn) begin
//        buffer <= 'd0;
//    end
//    else if (cu_st == S_CUT0) begin
//        buffer <= {sk_seed, fors_tree_addr};
//    end
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
//end

// save tmp result
always @(posedge clk) begin
    if (~rstn) begin
        last_data <= 'd0;
    end
    else if ((cu_st == S_GEN_LEAF0) && sha256_done) begin
        last_data <= sha256_dout;
    end
end


// state
always @(posedge clk) begin
    if (~rstn) begin
        state <= 'd0;
    end
    else if ((cu_st == S_CUT0) || (cu_st == W_CUT0)) begin
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
    else if (start || en_sign_dict_treehash) begin
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
        sha256_start <= (cu_st == S_CUT0) ||
                        (cu_st == W_CUT0) ||
                         thash_sha256_start;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_1st  <= 'd0;
        sha256_seed <= 'd0;
    end
    else begin
        sha256_1st  <= (cu_st == S_CUT0) ||
                       (cu_st == W_CUT0) ||
                        thash_sha256_1st;
        sha256_seed <= thash_sha256_seed;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_final <= 'd0;
    end
    else begin
        sha256_final <= (cu_st == S_CUT0) ||
                        (cu_st == W_CUT0) ||
                         thash_sha256_final;
    end
end

assign	sha256_state = ((cu_st == S_GEN_LEAF1) || (cu_st == S_THASH) || (cu_st == W_GEN_CHAIN) || (cu_st == W_THASH) || dict_thash || wots_sign_thash_mode) ? thash_sha256_state : state;
assign	sha256_data  = ((cu_st == S_GEN_LEAF1) || (cu_st == S_THASH) || (cu_st == W_GEN_CHAIN) || (cu_st == W_THASH) || dict_thash || wots_sign_thash_mode) ? thash_sha256_data  : buffer;
assign	sha256_len   = ((cu_st == S_GEN_LEAF1) || (cu_st == S_THASH) || (cu_st == W_GEN_CHAIN) || (cu_st == W_THASH) || dict_thash || wots_sign_thash_mode) ? thash_sha256_len   : len;

// -------------------------------------
// auth_path mem
assign	auth_path_wen0 = ((((cu_st == S_GEN_LEAF1) || (cu_st == W_THASH)) && thash_dout_vld) && ((leaf_idx ^ 24'h1) == idx));
assign	auth_path_wen1 = ((cu_st == S_READY2) && (((leaf_idx >> heights[offset - 1]) ^ 24'h1) == tree_idx));
assign	read_auth_path_en = cu_st == S_OUT;
always @(posedge clk) begin
    if (~rstn) begin
        read_auth_path_addr <= 'd0;
    end
    else if (start || en_sign_dict_treehash) begin
        read_auth_path_addr <= 'd0;
    end
    else if (read_auth_path_en) begin
        read_auth_path_addr <= read_auth_path_addr + 1'b1;
    end
end

`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<15;i=i+1)
            auth_path_mem[i] <= 'd0;
    end
    else if (start || en_sign_dict_treehash) begin
        for (i=0;i<15;i=i+1)
            auth_path_mem[i] <= 'd0;
    end
    else if (auth_path_wen0) begin
        auth_path_mem[0] <= sha256_state;
    end
    else if (auth_path_wen1) begin
        auth_path_mem[heights[offset - 1]] <= sha256_state;
    end
end
always @(posedge clk) begin
    if (~rstn) begin
        auth_path_tmp <= 'd0;
    end
    else begin
        auth_path_tmp <= auth_path_mem[read_auth_path_addr];
    end
end
assign	auth_path = auth_path_tmp;

`else

wire		write_auth_path_mem_en;
wire	[3:0]	write_auth_path_mem_addr;
wire	[255:0]	write_auth_path_mem_data;
wire		read_auth_path_mem_en;
wire	[3:0]	read_auth_path_mem_addr;
wire	[255:0]	read_auth_path_mem_data;
wire	[3:0]	auth_path_mem_addr;
assign	write_auth_path_mem_en   = auth_path_wen0 || auth_path_wen1;
assign	write_auth_path_mem_addr = auth_path_wen0 ? 'd0 : heights[offset - 1];
assign	write_auth_path_mem_data = sha256_state;
assign	read_auth_path_mem_en    = 1'b1;
assign	read_auth_path_mem_addr  = read_auth_path_addr;
assign	auth_path_mem_addr       = write_auth_path_mem_en ? write_auth_path_mem_addr : read_auth_path_mem_addr;

	altsyncram	auth_path_mem_altsyncram_component (
				.address_a (auth_path_mem_addr),
				.clock0 (clk),
				.data_a (write_auth_path_mem_data),
				.wren_a (write_auth_path_mem_en),
				.rden_a (read_auth_path_mem_en),
				.q_a (read_auth_path_mem_data),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		auth_path_mem_altsyncram_component.clock_enable_input_a = "BYPASS",
		auth_path_mem_altsyncram_component.clock_enable_output_a = "BYPASS",
		auth_path_mem_altsyncram_component.intended_device_family = "Cyclone IV E",
		auth_path_mem_altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		auth_path_mem_altsyncram_component.lpm_type = "altsyncram",
		auth_path_mem_altsyncram_component.numwords_a = 16,
		auth_path_mem_altsyncram_component.operation_mode = "SINGLE_PORT",
		auth_path_mem_altsyncram_component.outdata_aclr_a = "NONE",
		auth_path_mem_altsyncram_component.outdata_reg_a = "UNREGISTERED",
		auth_path_mem_altsyncram_component.power_up_uninitialized = "FALSE",
		auth_path_mem_altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		auth_path_mem_altsyncram_component.widthad_a = 4,
		auth_path_mem_altsyncram_component.width_a = 256,
		auth_path_mem_altsyncram_component.width_byteena_a = 1;

assign	auth_path = read_auth_path_mem_data; //auth_path_tmp;

`endif

// -------------------------------------

always @(posedge clk) begin
    if (~rstn) begin
        sig_vld <= 'd0;
    end
    else begin
        sig_vld <= read_auth_path_en;
    end
end

//assign	auth_path = sha256_state;

always @(posedge clk) begin
    if (~rstn) begin
        dout_vld <= 'd0;
    end
    else begin
        dout_vld <= (cu_st == S_OUT) && (ne_st == S_IDLE);
    end
end
assign	dict_thash_done = dict_thash && thash_dout_vld;

assign	wots_gen_leaf_done = (cu_st == W_THASH) && thash_dout_vld;

//always @(posedge clk) begin
//    if (~rstn) begin
//        tree     <= 'd0;
//        leaf_idx <= 'd0;
//    end
//    else if ((cu_st == SHA256_1) && sha256_done) begin
//        tree     <= sha256_dout[199:144];
//        leaf_idx <= sha256_dout[143:136];
//    end
//end

endmodule
