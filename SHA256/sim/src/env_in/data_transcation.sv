// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:06
// Last Modified : 2024/06/26 23:32
// File Name     : data_transcation.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
class data_transaction extends uvm_sequence_item;
	bit [255:0]me_sha256_statebytes_o;
	bit [255:0]sha256_statebytes_o;
	bit [255:0]top_out;
	static int comp_times = 0;
	function new(string name = "data_transaction");
		super.new(name);
		`uvm_info(get_type_name(),"new is called",UVM_LOW)
	endfunction

	function void post_randomize();
		this.print();
		`uvm_info(get_type_name(),"post_randomize is called",UVM_LOW)
	endfunction

	`uvm_object_utils_begin(data_transaction)
	`uvm_object_utils_end
endclass
