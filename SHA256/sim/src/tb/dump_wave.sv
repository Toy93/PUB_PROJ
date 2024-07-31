// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/05/26 09:54
// Last Modified : 2024/05/26 09:58
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
	bit dump_fsdb;
	if($test$plusargs("DUMP_FSDB"))begin
		$fsdbDumpfile("tb.fsdb");//waveform name
		$fsdbDumpvars(0,testbench);
		$fsdbDumpMDA();
		$fsdbDumpSVA();
		$fsdbDumpflush();
	end
end
