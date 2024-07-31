/*************************************************************************
    # File Name: virtual_sequencer.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 11:06:18 AM EDT
*************************************************************************/
class virtual_sequencer extends uvm_sequencer;
	data_sequencer `DUT_TOP_NAME(data_sequencer);
	function new(string name = "virtual_sequencer",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("virtual_sequencer","new is called",UVM_LOW)
	endfunction	
	`uvm_component_utils(virtual_sequencer)
endclass

