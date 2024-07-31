`include "gdefine.v"
module in_rom(
input		clk,
input		rstn,
input		gen_message_random_mem_ren,
input		hash_message_mem_ren,

input	[`MEM_ADDR_WIDTH-1:0]	gen_message_random_mem_raddr,
input	[`MEM_ADDR_WIDTH-1:0]	hash_message_mem_raddr,

output	reg	[255:0] mem_dout
);

reg	[255:0] mem [`MEM_DEPTH-1:0];
wire		mem_ren;
wire	[`MEM_ADDR_WIDTH-1:0] mem_raddr;

assign	mem_ren   = gen_message_random_mem_ren   || hash_message_mem_ren;
assign	mem_raddr = gen_message_random_mem_raddr || hash_message_mem_raddr;


`ifndef FPGA
always @(posedge clk) begin
    if (~rstn) begin
	mem[0] = 256'hD81C4D8D734FCBFBEADE3D3F8A039FAA2A2C9957E835AD55B22E75BF57BB556A;
	mem[1] = 256'hC800000000000000000000000000000000000000000000000000000000000000;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        mem_dout <= 'd0;
    end
    else if (mem_ren) begin
        mem_dout <= mem[mem_raddr];
    end
end

`else
wire	[255:0]	rom_dout;
	altsyncram	altsyncram_component (
				.address_a (mem_raddr),
				.clock0 (clk),
				.rden_a (mem_ren),
				.q_a (rom_dout),
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
				.data_a ({256{1'b1}}),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_b (1'b1),
				.wren_a (1'b0),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = "in.mif",
		altsyncram_component.intended_device_family = "Cyclone IV E",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 128,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.widthad_a = 7,
		altsyncram_component.width_a = 256,
		altsyncram_component.width_byteena_a = 1;

always @(*) begin
    mem_dout <= rom_dout;
end
`endif


endmodule
