// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/03 07:40
// Last Modified : 2024/06/05 00:25
// File Name     : m32.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/03   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module M32(
	input [31:0] w0_i,
	input [31:0] w1_i,
	input [31:0] w2_i,
	input [31:0] w3_i,
	output[31:0] w0_o
);
//PARAMETER DEFINE
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

/*autowire*/
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

/*autoreg*/
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//WIRE DEFINE
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//REG DEFINE
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//main code
//---------------------------------------------------------------------------------head
	assign w0_o = M_32(w0_i,w1_i,w2_i,w3_i);

	function [31:0] sigma0_32;
	    input [31:0] x;
	    sigma0_32 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ {3'd0, x[31:3]};
	endfunction
	
	
	function [31:0] sigma1_32;
	    input [31:0] x;
	    sigma1_32 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ {10'd0, x[31:10]};
	endfunction
	
	function [31:0] M_32;
	    input [31:0] a,b,c,d;
	    M_32 = sigma1_32(b) + (c) + sigma0_32(d) + (a);
	endfunction

//---------------------------------------------------------------------------------tail
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
