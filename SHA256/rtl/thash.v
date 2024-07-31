`include "gdefine.v"
module thash (
input		clk,
input		rstn,

input		start,

input		din_vld,
input	[6:0]	din_addr,
input	[255:0]	din,
input	[6:0]	inblocks,
input	[6:0]	inblocks_addr,
input	[255:0]	pub_seed,
input	[255:0]	addr,

input		leaf_en,

output		r_stack_en,
output	[6:0]	r_stack_addr,
input	[255:0]	r_stack_dout,

input		root_en,
output		r_root_en,
output	[4:0]	r_root_addr,
input	[255:0]	r_root_dout,

input		wots_sign_thash_mode,
input		wots_sign_thash_start,
input		wots_sign_thash_1st,
input		wots_sign_thash_final,
input	[255:0]	wots_sign_thash_state,
input	[511:0]	wots_sign_thash_data,
input	[6:0]	wots_sign_thash_len,

output	reg	sha256_start,
output	reg	sha256_1st,
output	reg	sha256_final,
output		sha256_seed,
output	[255:0]	sha256_state,
output	[511:0]	sha256_data,
output	[6:0]	sha256_len,
input		sha256_done,
input	[255:0]	sha256_dout,

output	reg	dout_vld,
output	reg [255:0]	dout);

// ------------------------------------------------------
// parameter
parameter S_IDLE    = 4'd0;
parameter S_CUT0    = 4'd1;
parameter S_SEED    = 4'd2;
parameter S_RMEM0   = 4'd3;
parameter S_RMEM1   = 4'd4;
parameter S_CUT1    = 4'd5;
parameter S_INC     = 4'd6;
parameter S_JUDGE   = 4'd7;
parameter S_CUT2    = 4'd8;
parameter S_FINAL   = 4'd9;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };

parameter MEM_DEPTH     = 7'd67;

// ------------------------------------------------------
// wire && reg
reg	[3:0]	cu_st, ne_st;
reg	[6:0]	block_num, raddr;
reg	[687:0]	buffer;
reg	[255:0]	last_data;
reg	[255:0]	state;
reg	[`MLEN_WIDTH-1:0]	len;

reg	[255:0]	mem[0:MEM_DEPTH-1];
wire		rmem_en0;
wire		rmem_en1;
wire		rmem_en;
wire		r_leaf_mem_en;
reg		rmem_en0_dl;
reg		rmem_en1_dl;
reg	[255:0]	mem_out;

integer i;

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
        S_IDLE  : ne_st = (start || wots_sign_thash_start)       ? S_CUT0  : S_IDLE;

        S_CUT0  : ne_st = S_SEED;
        S_SEED  : ne_st = sha256_done ? (wots_sign_thash_mode ? S_CUT2 : S_RMEM0) : S_SEED;

        S_RMEM0 : ne_st = (block_num == 7'd1) ? S_CUT2 : S_RMEM1;
        S_RMEM1 : ne_st = S_CUT1;

        S_CUT1  : ne_st = S_INC;
        S_INC   : ne_st = sha256_done ? S_JUDGE : S_INC;

        S_JUDGE : ne_st = (block_num == 7'd0) ? S_CUT2 : S_RMEM0;

        S_CUT2  : ne_st = S_FINAL;
        S_FINAL : ne_st = sha256_done ? S_IDLE  : S_FINAL;

        default : ne_st = S_IDLE;
    endcase
end

// --------------------------------------------------------
// mem save data
assign	rmem_en0  = (cu_st == S_RMEM0);
assign	rmem_en1  = (cu_st == S_RMEM1);
assign	rmem_en   = rmem_en0 || rmem_en1;

assign	r_leaf_mem_en = leaf_en && rmem_en;

`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
        for (i=0;i<MEM_DEPTH;i=i+1)
            mem[i] <= 'd0;
    end
    else if (din_vld) begin
        mem[din_addr] <= din;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        mem_out <= 'd0;
    end
    else if (r_leaf_mem_en) begin
        mem_out <= mem[raddr];
    end
end

`else

wire		write_mem_en;
wire	[6:0]	write_mem_addr;
wire	[255:0]	write_mem_data;
wire		read_mem_en;
wire	[6:0]	read_mem_addr;
wire	[255:0]	read_mem_data;
wire	[6:0]	mem_addr;
assign	write_mem_en   = din_vld;
assign	write_mem_addr = din_addr;
assign	write_mem_data = din;
assign	read_mem_en    = r_leaf_mem_en;
assign	read_mem_addr  = raddr;
assign	mem_addr       = write_mem_en ? write_mem_addr : read_mem_addr;

	altsyncram	mem_altsyncram_component (
				.address_a (mem_addr),
				.clock0 (clk),
				.data_a (write_mem_data),
				.wren_a (write_mem_en),
				.rden_a (read_mem_en),
				.q_a (read_mem_data),
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
		mem_altsyncram_component.clock_enable_input_a = "BYPASS",
		mem_altsyncram_component.clock_enable_output_a = "BYPASS",
		mem_altsyncram_component.intended_device_family = "Cyclone IV E",
		mem_altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		mem_altsyncram_component.lpm_type = "altsyncram",
		mem_altsyncram_component.numwords_a = 128,
		mem_altsyncram_component.operation_mode = "SINGLE_PORT",
		mem_altsyncram_component.outdata_aclr_a = "NONE",
		mem_altsyncram_component.outdata_reg_a = "UNREGISTERED",
		mem_altsyncram_component.power_up_uninitialized = "FALSE",
		mem_altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		mem_altsyncram_component.widthad_a = 7,
		mem_altsyncram_component.width_a = 256,
		mem_altsyncram_component.width_byteena_a = 1;

always @(*) begin
    mem_out = read_mem_data;
end
`endif

// --------------------------------------------------------

// block num
always @(posedge clk) begin
    if (~rstn) begin
        block_num <= 'd0;
        raddr     <= 'd0;
    end
    else if (start) begin
        block_num <= wots_sign_thash_mode ? 2'd1 : inblocks;
        raddr     <= inblocks_addr;
    end
    else if (rmem_en) begin
        block_num <= block_num - 1'b1;
        raddr     <= raddr     + 1'b1;
    end
end
assign	r_stack_en   = (~leaf_en) && rmem_en && (~root_en);
assign	r_stack_addr = raddr;
assign	r_root_en    = (~leaf_en) && rmem_en &&   root_en;
assign	r_root_addr  = raddr[4:0];

always @(posedge clk) begin
    if (~rstn) begin
        rmem_en0_dl <= 'd0;
        rmem_en1_dl <= 'd0;
    end
    else begin
        rmem_en0_dl <= rmem_en0;
        rmem_en1_dl <= rmem_en1;
    end
end

// shift regs
always @(posedge clk) begin
    if (~rstn) begin
        buffer <= 'd0;
    end
    else if (cu_st == S_CUT0) begin
        buffer <= {pub_seed, 256'd0, addr[255:80]};
    end
    else if (rmem_en0_dl) begin
        if (leaf_en) begin
            buffer <= {buffer[175:0], mem_out, 256'd0};
        end
        else if (root_en) begin
            buffer <= {buffer[175:0], r_root_dout, 256'd0};
        end
        else begin
            buffer <= {buffer[175:0], r_stack_dout, 256'd0};
        end
    end
    else if (rmem_en1_dl) begin
        if (leaf_en) begin
            buffer <= {buffer[687:256], mem_out};
        end
        else if (root_en) begin
            buffer <= {buffer[687:256], r_root_dout};
        end
        else begin
            buffer <= {buffer[687:256], r_stack_dout};
        end
    end
    else if (cu_st == S_CUT2) begin
        buffer <= wots_sign_thash_mode ? {wots_sign_thash_data, 176'd0} : {buffer[175:0], 512'd0};
    end
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
//                      (cu_st == CUT2);
always @(posedge clk) begin
    if (~rstn) begin
        len <= 'd0;
    end
    else if (start || wots_sign_thash_start || (cu_st == S_CUT1)) begin
        len <= 7'd64;
    end
    else if (cu_st == S_CUT2) begin
        //if (inblocks == 2'd1) begin
        if (inblocks[0] || wots_sign_thash_mode) begin
            len <= 7'd54;
        end
        //else if ((inblocks == 7'd22) || (inblocks == 7'd2)) begin
        else begin
            len <= 7'd22;
        end
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
                        (cu_st == S_CUT1) ||
                        (cu_st == S_CUT2);
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_1st <= 'd0;
    end
    else begin
        sha256_1st <= (cu_st == S_CUT0);
    end
end
assign	sha256_seed = sha256_1st;

always @(posedge clk) begin
    if (~rstn) begin
        sha256_final <= 'd0;
    end
    else begin
        sha256_final <= (cu_st == S_CUT2);
    end
end

assign	sha256_state = state;
assign	sha256_data  = buffer[687:176];
assign	sha256_len   = len;

//assign	sig_vld = (cu_st == S_FORS_GEN_SK) && sha256_done);

always @(posedge clk) begin
    if (~rstn) begin
        dout_vld <= 'd0;
    end
    else begin
        dout_vld <= (cu_st == S_FINAL) && sha256_done;
    end
end

//always @(posedge clk) begin
//    if (~rstn) begin
//        dout <= 'd0;
//    end
//    else begin
//        if ((cu_st == SHA256_0) && sha256_done) begin
//            dout[311:56] <= sha256_dout;
//        end
//        if ((cu_st == SHA256_1) && sha256_done) begin
//            dout[55:0] <= sha256_dout[255:200];
//        end
//    end
//end
//
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
