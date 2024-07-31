class data_transaction extends uvm_sequence_item;

	rand bit [8:0]sw;

	logic [23:0]cmd;
	logic [7:0]cmd_addr;
	logic [7:0]reg_data;
	logic [7:0]led;
	
	function new(string name = "data_transaction");
		super.new(name);
		`uvm_info(get_type_name(),"new is called",UVM_LOW)
	endfunction
	
	function void post_randomize();
		`uvm_info(get_type_name(),"post_randomize is called",UVM_LOW)
		this.print();
		write_file();
	endfunction

	extern function void write_file();
	`uvm_object_utils_begin(data_transaction)
		`uvm_field_int(sw, UVM_ALL_ON)
	`uvm_object_utils_end
endclass

function void data_transaction::write_file();
	integer fp;
	//fp = $fopen("program.txt","w");
	//if(fp == 0)begin
	//	`uvm_fatal(get_type_name(),"open program.txt failure!")
	//end
	//$fclose(fp);
endfunction
