/*************************************************************************
    # File Name: virtual_sequencer.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 11:06:18 AM EDT
*************************************************************************/
class data_sequencer extends uvm_sequencer#(data_transaction);
	function new(string name = "data_sequencer",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("data_sequencer","new is called",UVM_LOW)
	endfunction	
	`uvm_component_utils(data_sequencer)
endclass

