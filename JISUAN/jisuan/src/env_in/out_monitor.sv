/*************************************************************************
    # File Name: out_monitor.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:55:56 AM EDT
*************************************************************************/
class out_monitor extends uvm_monitor;
	virtual clk_rst_if clk_if;
	virtual output_data_if out_if;
	verify_ctrl vc;
	uvm_analysis_port#(data_transaction) ap;
	function new(string name = "out_monitor",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("out_monitor","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task reset_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(out_monitor)
endclass

function void out_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("out_monitor","build_phase is called",UVM_LOW)
	ap = new("ap",this);
endfunction

function void out_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("out_monitor","connect_phase is called",UVM_LOW)
 	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	if(!uvm_config_db#(virtual clk_rst_if)::get(this,"","vif_clk_rst",clk_if))
		`uvm_fatal("out_monitor","virtual interface must be set for clk_if")
	if(!uvm_config_db#(virtual output_data_if)::get(this,"","vif_output_data",out_if))
		`uvm_fatal("out_monitor","virtual interface must be set for out_if")
endfunction

task out_monitor::reset_phase(uvm_phase phase);
	super.reset_phase(phase);
	`uvm_info("out_monitor","reset_phase is called",UVM_LOW)
	out_if.out_rdy <= 1'b1;
endtask

task out_monitor::main_phase(uvm_phase phase);
	int run_times = 0;
	data_transaction tr;
	uvm_event ev_monitor_finish = uvm_event_pool::get_global("ev_monitor_finish");
	super.main_phase(phase);
	`uvm_info("out_monitor","main_phase is called",UVM_LOW)
	while(1)begin
		@(posedge clk_if.clk);
		if(out_if.out_vld&out_if.out_rdy)begin
			tr = new("tr");
			tr.passwd_o = out_if.password_o;
			ap.write(tr);
			run_times++;
			if(run_times == vc.data_num)begin
				break;
			end	
		end
	end
	ev_monitor_finish.trigger();
	$display("ev_monitor_finish is triggered");
endtask
