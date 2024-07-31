class data_transaction extends uvm_sequence_item;
	rand bit [`PASSWD_LEN*8 - 1:0]passwd;
	bit [`PASSWD_LEN*8 - 1:0]passwd_low;
	bit [`PASSWD_LEN*8 - 1:0]passwd_high;
	bit [32*8 - 1:0]passwd_o;
	function new(string name = "data_transaction");
		super.new(name);
		`uvm_info("data_transaction","new is called",UVM_LOW)
	endfunction

	function void post_randomize();
		this.print();
		`uvm_info("data_transaction","post_randomize is called",UVM_LOW)
		passwd_high = passwd[639:320];
		passwd_low = passwd[319:0];
	endfunction
	`uvm_object_utils_begin(data_transaction)
		`uvm_field_int(passwd,UVM_ALL_ON)
	`uvm_object_utils_end
endclass
