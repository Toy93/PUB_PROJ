// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/05/26 09:54
// Last Modified : 2024/06/22 19:02
// File Name     : dump_wave.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/05/26   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
initial begin
	if($test$plusargs("DUMP_FSDB"))begin
		$fsdbDumpfile("tb.fsdb");//waveform name
		$fsdbDumpvars(0,testbench);
		$fsdbDumpMDA();
		$fsdbDumpSVA();
		$display("dump wave is on");
	end
end
