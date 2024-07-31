// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:05
// Last Modified : 2024/06/22 18:52
// File Name     : verify_ctrl.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
class verify_ctrl extends uvm_object;
	rand byte data_num;
	constraint  data_num_cons{
		data_num inside {[0:15]};
		data_num == 2;
    }

	function new(string name="verify_ctrl");
		super.new(name);
		`uvm_info(get_type_name(),"new is called",UVM_LOW)
	endfunction	

	function void post_randomize();
		`uvm_info(get_type_name(),$sformatf("data_num :%d",data_num),UVM_LOW)
	endfunction

	`uvm_object_utils_begin(verify_ctrl)
		`uvm_field_int(data_num,UVM_ALL_ON)
	`uvm_object_utils_end
endclass
