// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/05/26 09:57
// Last Modified : 2024/05/26 09:57
// File Name     : run_test.sv
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
	string tc_name = "";
	$value$plusargs("UVM_TESTNAME=%s",tc_name);
	run_test(tc_name);
end
