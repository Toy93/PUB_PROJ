`include "gdefine.v"
module gen_message_random (
input		clk,
input		rstn,

input		start,

input	[255:0]	sk_prf,
input	[255:0]	optrand,

output		mem_ren,
output	reg [`MEM_ADDR_WIDTH-1:0]	mem_raddr,
input	[255:0]	mem_rdata,

input	[`MLEN_WIDTH-1:0]	mlen,

output	reg	sha256_start,
output	reg	sha256_1st,
output	reg	sha256_final,
output	[255:0]	sha256_state,
output	[511:0]	sha256_data,
output	[6:0]	sha256_len,
input		sha256_done,
input	[255:0]	sha256_dout,

output	reg	dout_vld,
output	reg [255:0]	dout);	

// ------------------------------------------------------
// parameter
parameter INIT0  = 256'h3636363636363636363636363636363636363636363636363636363636363636;
parameter INIT1  = 256'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;

parameter IDLE                 = 4'd0;
parameter SHA256_INC_BLOCK0    = 4'd1;
parameter R_MEM0               = 4'd2;
parameter CUT0                 = 4'd3;
parameter SHA256_INC_FINALIZE0 = 4'd4;
parameter SHA256_INC_BLOCK1    = 4'd5;
parameter R_MEM1               = 4'd6;
parameter R_MEM2               = 4'd7;
parameter CUT1                 = 4'd8;
parameter CUT2                 = 4'd9;
parameter SHA256_INC_FINALIZE1 = 4'd10;
parameter CUT3                 = 4'd11;
parameter SHA256_0             = 4'd12;
parameter CUT4                 = 4'd13;
parameter SHA256_1             = 4'd14;

parameter CUT9                 = 4'd15;

parameter IV_256 = { 8'h6a, 8'h09, 8'he6, 8'h67, 8'hbb, 8'h67, 8'hae, 8'h85,
                     8'h3c, 8'h6e, 8'hf3, 8'h72, 8'ha5, 8'h4f, 8'hf5, 8'h3a,
                     8'h51, 8'h0e, 8'h52, 8'h7f, 8'h9b, 8'h05, 8'h68, 8'h8c,
                     8'h1f, 8'h83, 8'hd9, 8'hab, 8'h5b, 8'he0, 8'hcd, 8'h19 };

// ------------------------------------------------------
// wire && reg
reg	[3:0]	cu_st, ne_st;
wire		buf_msb, buf_lsb;
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
        cu_st <= IDLE;
    end
    else begin
        cu_st <= ne_st;
    end
end

always @(*) begin
    case(cu_st)
        IDLE               : ne_st = start       ?  SHA256_INC_BLOCK0 : IDLE;

        // sk_prf + 0x36
        SHA256_INC_BLOCK0  : ne_st = sha256_done ? R_MEM0             : SHA256_INC_BLOCK0;
        R_MEM0             : ne_st = CUT0;
        CUT0 : begin
             // if (`SPX_N + len =< `SPX_SHA256_BLOCK_BYTES) begin // c bug
             if (`SPX_N + len < `SPX_SHA256_BLOCK_BYTES) begin
                 ne_st = SHA256_INC_FINALIZE0; // not run the branch
             end
             else begin
                 ne_st = SHA256_INC_BLOCK1;
             end
        end

        // optrand + m(length of m < 32)
        SHA256_INC_FINALIZE0 : ne_st = sha256_done ? CUT9   : SHA256_INC_FINALIZE0; 
        CUT9                 : ne_st = IDLE;

        // optrand + m(length of m >= 32)
        SHA256_INC_BLOCK1    : ne_st = sha256_done ? R_MEM1 : SHA256_INC_BLOCK1;
        R_MEM1               : ne_st = (len <= 7'h20) ?  CUT1 : R_MEM2;
        R_MEM2               : ne_st = (len <= 7'h40) ?  CUT1 : CUT2;

        CUT1                 : ne_st = SHA256_INC_FINALIZE1;
        CUT2                 : ne_st = SHA256_INC_BLOCK1;


        SHA256_INC_FINALIZE1 : ne_st = sha256_done ? CUT3   : SHA256_INC_FINALIZE1; 

        CUT3                 : ne_st = SHA256_0;
        SHA256_0             : ne_st = sha256_done ? CUT4   : SHA256_0            ; 
        CUT4                 : ne_st = SHA256_1;
        SHA256_1             : ne_st = sha256_done ? IDLE   : SHA256_1            ; 

        default              : ne_st = IDLE;
    endcase
end

// read din mem
assign	buf_msb = (cu_st == R_MEM1);
assign	buf_lsb = (cu_st == R_MEM2);
assign	mem_ren = (cu_st == R_MEM0) || buf_msb || buf_lsb;
always @(posedge clk) begin
    if (~rstn) begin
        mem_raddr <= 'd0;
    end
    else if (cu_st ==  IDLE) begin
        mem_raddr <= 'd0;
    end
    else if (mem_ren) begin
        mem_raddr <= mem_raddr + 1'b1;
    end
end

// buf
always @(posedge clk) begin
    if (~rstn) begin
        buf_msb_dl <= 'd0;
        buf_lsb_dl <= 'd0;
    end
    else begin
        buf_msb_dl <= buf_msb;
        buf_lsb_dl <= buf_lsb;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        buffer <= 'd0;
    end
    else if (cu_st == IDLE) begin
        buffer <= {INIT0 ^ sk_prf, INIT0};
    end
    else if (cu_st == CUT0) begin
        buffer <= {optrand, mem_rdata};
    end
    else if (cu_st == CUT3) begin
        buffer <= {INIT1 ^ sk_prf, INIT1};
    end
    else if (cu_st == CUT4) begin
        buffer <= {last_data, 256'd0};
    end
    else begin
        if (buf_msb_dl) begin
            buffer[511:256] <= mem_rdata;
        end
        if (buf_lsb_dl) begin
            buffer[255:  0] <= mem_rdata;
        end
    end
end

// save 0x36 sha256 result
always @(posedge clk) begin
    if (~rstn) begin
        last_data <= 'd0;
    end
    else if ((cu_st == SHA256_INC_FINALIZE1) && sha256_done) begin
        last_data <= sha256_dout;
    end
end


// state
always @(posedge clk) begin
    if (~rstn) begin
        state <= 'd0;
    end
    else if (((cu_st == IDLE) && (ne_st == SHA256_INC_BLOCK0)) || (cu_st == CUT3)) begin
         state <= IV_256;
    end
    else if (sha256_done) begin
         state <= sha256_dout;
    end
end

assign	consump_en = ((cu_st == CUT0) && (ne_st == SHA256_INC_BLOCK1)) ||
                      (cu_st == CUT1);
always @(posedge clk) begin
    if (~rstn) begin
        len <= 'd0;
    end
    else if (start) begin
        len <= mlen;
    end
    else if ((cu_st == CUT0) && (ne_st == SHA256_INC_BLOCK1)) begin
        len <= len - 7'h20;
    end
    else if (cu_st == CUT2) begin
        len <= len - 7'h40;
    end
    else if (cu_st == CUT4) begin
        len <= 7'h20;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_start <= 'd0;
    end
    else begin
        sha256_start <= ((cu_st == IDLE) && (ne_st == SHA256_INC_BLOCK0)) ||
                         (cu_st == CUT0) ||
                         (cu_st == CUT1) ||
                         (cu_st == CUT2) ||
                         (cu_st == CUT3) ||
                         (cu_st == CUT4);
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        sha256_1st <= 'd0;
    end
    else begin
        sha256_1st <= ((cu_st == IDLE) && (ne_st == SHA256_INC_BLOCK0)) ||
                       (cu_st == CUT3);
    end
end

assign	sha256_state = state;
always @(posedge clk) begin
    if (~rstn) begin
        sha256_final <= 'd0;
    end
    else begin
        sha256_final <= (cu_st == CUT1) || (cu_st == CUT4);
    end
end

assign	sha256_state = state;
assign	sha256_data  = buffer;
assign	sha256_len   = ((cu_st == SHA256_INC_FINALIZE1) || (cu_st == SHA256_1)) ? len : 7'd64;

always @(posedge clk) begin
    if (~rstn) begin
        dout_vld <= 'd0;
    end
    else begin
        dout_vld <= (cu_st == SHA256_1) && sha256_done;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        dout <= 'd0;
    end
    else if ((cu_st == SHA256_1) && sha256_done) begin
        dout <= sha256_dout;
    end
end

endmodule
