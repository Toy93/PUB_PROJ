import uvm_pkg::*;
class core_base_class extends uvm_object;
	typedef enum bit{MAN,WOMAN}sex_e;
	string name;
	int unsigned age;
	sex_e sex;
	function new(string name="core_base_class");
		
	endfunction 
	`uvm_object_utils_begin(core_base_class)
		`uvm_field_string(name,UVM_ALL_ON)
		`uvm_field_int(age,UVM_ALL_ON)
		`uvm_field_enum(sex_e,sex,UVM_ALL_ON)
	`uvm_object_utils_end
endclass 

program test(
	input clk,
	input rst_n
);	

uvm_barrier ba;
initial begin
	ba = new("ba",3);
	set_report_severity_action(UVM_FATAL,UVM_DISPLAY);
	fork	
		//uvm_report_info("info","info_message",UVM_NONE,"test.sv",26);
		//uvm_report_warning("warning","warning_message",UVM_NONE,"test.sv",27);
		//uvm_report_error("error","error_message",UVM_NONE,"test.sv",28);
		//uvm_report_fatal("fatal","fatal_message",UVM_NONE,"test.sv",29);
		//`uvm_info("info","info_message",UVM_NONE)
		//`uvm_warning("warning","warning_message")
		//`uvm_fatal("fatal","fatal_message")
	join	
end
initial begin
	core_base_class u_core_base_class;
	u_core_base_class = core_base_class::type_id::create("u_core_base_class");
	$display("yqs=%s",u_core_base_class.sprint());
end
endprogram

