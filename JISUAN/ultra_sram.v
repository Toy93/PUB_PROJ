/*************************************************************************
    # File Name: ultra_sram.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Sat 09 Apr 2022 11:09:07 AM EDT
    # Last Modified:2022-04-16 09:43
    # Update Count:19
*************************************************************************/
module ULTRA_SRAM#(
	parameter AWIDTH = 12,  // Address Width
	parameter DWIDTH = 72,  // Data Width
	parameter NBPIPE = 3   // Number of pipeline Registers
)(
	input					clk,    // Clock 
	input 					rstb,   // Reset
	input 					wea,    // Write Enable
	input 					regceb, // Output Register Enable
	input 					mem_en, // Memory Enable
	input		[DWIDTH-1:0]dina,   // Data <wire_or_reg>  
	input 		[AWIDTH-1:0]addra,  // Write Address
	input 		[AWIDTH-1:0]addrb,  // Read  Address
	output reg	[DWIDTH-1:0]doutb	// Data Output
);

reg [DWIDTH-1:0] mem[(1<<AWIDTH)-1:0];        // Memory Declaration
reg [DWIDTH-1:0] mem_pipe_reg[NBPIPE-1:0];    // Pipelines for memory
reg				 mem_en_pipe_reg[NBPIPE:0];   // Pipelines for memory enable  
integer          i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk)begin
	if(mem_en)begin
		if(wea)begin
			mem[addra] <= dina;
		end
	end
end

//always @(posedge clk or negedge rstb)begin
//	if(~rstb)begin
//		doutb <= {DWIDTH{1'b0}};
//	end
//	else if(mem_en&regceb)begin
//		doutb <= mem[addrb];
//	end
//end
always @(*)begin
	if(mem_en&regceb)begin
		doutb = mem[addrb];
	end
	else begin
		doutb = {DWIDTH{1'b0}};
	end
end
endmodule
