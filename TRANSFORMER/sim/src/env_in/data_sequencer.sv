// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/06/10 11:06
// Last Modified : 2024/06/10 11:09
// File Name     : data_sequencer.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
class data_sequencer extends uvm_sequencer#(data_transaction);
	function new(string name = "data_sequencer",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("data_sequencer","new is called",UVM_LOW)
	endfunction	
	`uvm_component_utils(data_sequencer)
endclass

