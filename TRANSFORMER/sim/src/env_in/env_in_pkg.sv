// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:06
// Last Modified : 2024/06/10 11:09
// File Name     : env_in_pkg.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
`ifndef ENV_IN_PKG
`define ENV_IN_PKG
`include "uvm_pkg.sv"
`include "uvm_macros.svh"
package env_in_pkg;
	import uvm_pkg::*;
	`include "verify_ctrl.sv"
	`include "data_transcation.sv"
	`include "data_sequencer.sv"
	`include "virtual_sequencer.sv"
	`include "data_sequence.sv"
	`include "virtual_sequence.sv"
	`include "out_monitor.sv"
	`include "in_monitor.sv"
	`include "data_driver.sv"
	`include "score_board.sv"
	`include "rm_model.sv"
	`include "out_agent.sv"
	`include "in_agent.sv"
	`include "env.sv"
	`include "base_test.sv"
endpackage
`endif
