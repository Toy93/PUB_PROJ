/*************************************************************************
    # File Name: rm_model.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:56:34 AM EDT
*************************************************************************/
class rm_model extends uvm_component;
	uvm_analysis_port#(data_transaction) ap;
	function new(string name = "rm_model",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("rm_model","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(rm_model)
endclass

function void rm_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("rm_model","build_phase is called",UVM_LOW)
	ap = new("ap",this);
endfunction

function void rm_model::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("rm_model","connect_phase is called",UVM_LOW)
endfunction

task rm_model::main_phase(uvm_phase phase);
	bit [`PASSWD_LEN*8 - 1:0]password;
	data_transaction tr;
	integer fp;
	uvm_event ev_write_finish = uvm_event_pool::get_global("ev_write_finish");
	super.main_phase(phase);
	`uvm_info("rm_model","main_phase is called",UVM_LOW)
	ev_write_finish.wait_trigger();
	$display("rm_model ev_write_finish is triggered!!!");
	$system("cd ../src/ref_c/src;gcc jisuan_20220425.c;./a.out");
	fp = $fopen("../src/ref_c/test_data/output.txt","r");
	if(fp == 0)
		`uvm_fatal("rm_model","can't open output.txt file");
	tr = new("tr");
	$fscanf(fp,"%x",tr.passwd_o);
	while(!$feof(fp))begin
		$display("read data from output.txt:%x",tr.passwd_o);
		ap.write(tr);
		tr = new("tr");
		$fscanf(fp,"%x",tr.passwd_o);
	end
endtask
