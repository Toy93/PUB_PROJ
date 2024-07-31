// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:17
// Last Modified : 2024/04/17 22:46
// File Name     : program_memory.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module PROGRAM_MEMORY(
	input clk,
	input rst_n,
	input [7:0]cmd_addr,
	
	output [23:0]cmd
);
	/*parameter*/
	/*autodef*/
	SP_RAM_256X24 U_SP_RAM_256X24(/*autoinst*/
        .clk                    (clk                            ), //input
        .rst_n                  (rst_n                          ), //input //INST_NEW
        .addr                   (cmd_addr                      ), //input
        .dout                   (cmd                     )  //output
    );

endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
