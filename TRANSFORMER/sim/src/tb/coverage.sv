// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/06/10 11:28
// Last Modified : 2024/06/10 11:28
// File Name     : coverage.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
program automatic coverage(
		clk_rst_if     u_clk_rst_if    ,
		input_data_if  u_input_data_if ,
		output_data_if u_output_data_if
);
	event clk_rst_ev;
	covergroup cg_rst@(clk_rst_ev);
		cp_rst:coverpoint u_clk_rst_if.rst_n{
			bins eq0 = {0};
			bins eq1 = {1};
			bins zero2one = (0=>1);
			bins one2zero = (1=>0);
		} 
	endgroup
	
	initial begin
		cg_rst u_cg_rst;
		u_cg_rst = new();
		
		forever begin
			@(posedge u_clk_rst_if.clk);
			->clk_rst_ev;
		end
	end
endprogram
