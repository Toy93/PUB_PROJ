// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/06/10 11:05
// Last Modified : 2024/06/10 11:09
// File Name     : virtual_sequencer.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
class virtual_sequencer extends uvm_sequencer;
	data_sequencer `DUT_TOP_NAME(data_sequencer);
	function new(string name = "virtual_sequencer",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("virtual_sequencer","new is called",UVM_LOW)
	endfunction	
	`uvm_component_utils(virtual_sequencer)
endclass

