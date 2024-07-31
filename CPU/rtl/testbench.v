// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/17 22:02
// Last Modified : 2024/04/20 16:45
// File Name     : testbench.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/17   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module testbench();
	
	/*parameter*/
	/*autodef*/
	reg clk;
	reg [9:0]sw;
	wire [7:0]led;
	
	initial begin
		sw[9] = 1'b1;
		#10;
		sw[9] = 1'b0;
		#10;
		sw[9] = 1'b1;
	end

	initial begin
		clk = 1'b0;
		forever begin
			#20 clk = ~clk;
		end
	end
	
	initial begin
		bit dump_fsdb;
		if($test$plusargs("DUMP_FSDB"))begin
`ifdef DUMP_FSDB
			$fsdbDumpfile("tb.fsdb");//waveform name
			$fsdbDumpvars(0,testbench);
			$fsdbDumpMDA();
			$fsdbDumpSVA();
			$fsdbDumpflush();
`endif
		end
	end

	initial begin
		sw[7:0]= 8'b0;
		sw[8]   = 1'b0;
		forever begin
			sw[7:0] <= $random();
			@(posedge clk);
			sw[8] <= 1'b1;
			repeat(10)begin
				@(posedge clk);
				sw[8]<= 1'b0;
				sw[7:0]<= $random();
				repeat(15000)begin
					@(posedge clk);
				end
				sw[8]<= 1'b1;
				repeat(15000)begin
					@(posedge clk);
				end
			end
		end
	end
	
	PICO_MIPS U_PICO_MIPS(/*autoinst*/
        .clk                    (clk                            ), //input
        .sw                     (sw[9:0]                        ), //input
        .led                    (led[7:0]                       )  //output
    );

endmodule
//Local Variables:
//verilog-library-directories:("../../../rtl")
//verilog-library-directories-recursive:1
//End:
