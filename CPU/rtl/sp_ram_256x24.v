// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 19:54
// Last Modified : 2024/05/14 07:21
// File Name     : sp_ram_256x24.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module SP_RAM_256X24(    
    input            clk  , 
	input            rst_n,
    input      [7:0] addr , 

    output     [23:0]dout
);
	integer i;
	reg [23:0] mem[255:0];
    
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n)begin
			`ifdef SIM
			$readmemb("program.txt",mem);
			`elsif
			mem[0 ] <= 24'b000101_00101_00000_00000011;
			mem[1 ] <= 24'b000101_00110_00000_00000011;
			mem[2 ] <= 24'b000101_00111_00000_00000011;
			mem[3 ] <= 24'b000101_01000_00000_00000011;
			mem[4 ] <= 24'b000101_01001_00000_11110000;
			mem[5 ] <= 24'b000101_01010_00000_00001111;
			mem[6 ] <= 24'b000110_01100_00000_00000010;
			mem[7 ] <= 24'b001010_01100_01011_00000110;
			mem[8 ] <= 24'b000110_01100_00000_00000010;
			mem[9 ] <= 24'b001000_01100_01011_00001000;
			mem[10] <= 24'b000110_00001_00000_00000001;
			mem[11] <= 24'b000110_01100_00000_00000010;
			mem[12] <= 24'b001010_01100_01011_00001011;
			mem[13] <= 24'b000110_01100_00000_00000010;
			mem[14] <= 24'b001000_01100_01011_00001101;
			mem[15] <= 24'b000110_00010_00000_00000001;
			mem[16] <= 24'b000110_01100_00000_00000010;
			mem[17] <= 24'b001010_01100_01011_00010000;
			mem[18] <= 24'b000011_00101_00101_00000001;
			mem[19] <= 24'b000011_00110_00110_00000010;
			mem[20] <= 24'b000001_00101_00101_00000110;
			mem[21] <= 24'b000001_00101_00101_00001001;
			mem[22] <= 24'b000011_00111_00111_00000001;
			mem[23] <= 24'b000011_01000_01000_00000010;
			mem[24] <= 24'b000001_00111_00111_00001000;
			mem[25] <= 24'b000001_00111_00111_00001010;
			mem[26] <= 24'b001011_00011_00101_00000000;
			mem[27] <= 24'b000110_01100_00000_00000010;
			mem[28] <= 24'b001000_01100_01011_00011011;
			mem[29] <= 24'b001011_00011_00111_00000000;
			`endif

			`ifdef DEBUG
			for(i = 0; i < $size(mem); i = i+1)begin
				$display("mem[%d]:%b",i,mem[i]);
			end
			`endif
		end
	end
    
	assign dout = mem[addr];
endmodule