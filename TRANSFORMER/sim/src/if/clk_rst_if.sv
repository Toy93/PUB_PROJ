// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:27
// Last Modified : 2024/06/10 11:27
// File Name     : clk_rst_if.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
interface clk_rst_if();
	logic clk;
	logic rst_n;

	initial begin
		clk <= 0;
		forever begin
			#5 clk <= ~clk;
		end
	end
endinterface
