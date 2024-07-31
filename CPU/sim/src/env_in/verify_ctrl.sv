class verify_ctrl extends uvm_object;
	rand byte unsigned data_num;
	constraint  data_num_cons{
		data_num inside {[1:255]};
    }

	function new(string name="verify_ctrl");
		super.new(name);
		`uvm_info(get_type_name(),"new is called",UVM_LOW)
	endfunction	

	function void post_randomize();
		$display("data_num :%d",data_num);
	endfunction

	`uvm_object_utils_begin(verify_ctrl)
		`uvm_field_int(data_num,UVM_ALL_ON)
	`uvm_object_utils_end
endclass
