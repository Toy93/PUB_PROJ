/*************************************************************************
    # File Name: base_test.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:55:28 AM EDT
*************************************************************************/
class base_test extends uvm_test;
	env `DUT_TOP_NAME(env);
	function new(string name = "base_test",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("base_test","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task reset_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);

	`uvm_component_utils(base_test)
endclass

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("base_test","build_phase is called",UVM_LOW)
	`DUT_TOP_NAME(env) = env::type_id::create(`DUT_TOP_NAME_STR(env),this);
	uvm_config_db#(uvm_object_wrapper)::set(this,"jisuan_env.jisuan_in_agent.jisuan_virtual_sequencer.main_phase","default_sequence",virtual_sequence::type_id::get());
endfunction

function void base_test::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("base_test","connect_phase is called",UVM_LOW)
	set_report_severity_action_hier(UVM_ERROR,UVM_COUNT);
endfunction

task base_test::reset_phase(uvm_phase phase);
	super.reset_phase(phase);
	`uvm_info("base_test","reset_phase is called",UVM_LOW)
	fork
		$display("rand_t2=%0d",$urandom_range(0,100));
		$display("rand_t1=%0d",$urandom_range(0,100));
	join
endtask

task base_test::main_phase(uvm_phase phase);
	super.main_phase(phase);
	`uvm_info("base_test","main_phase is called",UVM_LOW)
endtask

function void base_test::report_phase(uvm_phase phase);
	int err_num;
	uvm_report_server server;
	super.report_phase(phase);
	`uvm_info("base_test","report_phase is called",UVM_LOW)
	server = get_report_server();
	err_num = server.get_severity_count(UVM_ERROR);
	if(err_num == 0)
		$display("\033[;32m=================TEST CASE PASSED=============\033[0m");
	else 
		$display("\033[;31m=================TEST CASE FAILED=============\031[0m");
endfunction
