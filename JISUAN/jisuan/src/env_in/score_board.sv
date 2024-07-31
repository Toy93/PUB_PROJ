/*************************************************************************
    # File Name: score_board.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:56:50 AM EDT
*************************************************************************/
class grandfather;
	string name= "grandfather";
	int weight= 300;
	virtual function new0();
		$display("I am %s",name);
	endfunction
endclass

class father extends grandfather;
	string name= "father";
	function new0();
		$display("I am %s",name);
	endfunction
	function void super_t;
		super.new0();
	endfunction
endclass

class son extends father;
	int weight=100;
	string name= "son";
	function new0();
		$display("I am %s",name);
	endfunction
endclass

class score_board extends uvm_scoreboard;
	uvm_blocking_get_port#(data_transaction) rm_port;
	uvm_blocking_get_port#(data_transaction) out_port;
	grandfather u_grandfather;
	father u_father;
	function new(string name = "score_board",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("score_board","new is called",UVM_LOW)
		u_father = new();
		u_father.super_t();
		u_father.new0();
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(score_board)
endclass

function void score_board::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("score_board","build_phase is called",UVM_LOW)
	rm_port = new("rm_port",this);
	out_port = new("out_port",this);
endfunction

function void score_board::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("score_board","connect_phase is called",UVM_LOW)
endfunction

task score_board::main_phase(uvm_phase phase);
	uvm_event ev_monitor_finish = uvm_event_pool::get_global("ev_monitor_finish");
	verify_ctrl vc;
	data_transaction rm_tr;
	data_transaction out_tr;
	int comp_times = 0;
	super.main_phase(phase);
	`uvm_info("score_board","main_phase is called",UVM_LOW)
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	phase.raise_objection(this,"yqs is raised!!!");
	ev_monitor_finish.wait_trigger();
	while(1)begin
		fork
			rm_port.get(rm_tr);
			out_port.get(out_tr);
		join 
		$display("score_board gets datas");
		if(rm_tr.passwd_o == out_tr.passwd_o)begin
			$display("data:%d	compare success",comp_times);
			$display("passwd_o(DUT):%0x",out_tr.passwd_o);
			$display("passwd_o(RM ):%0x",rm_tr.passwd_o);
		end	
		else begin
			$display("data:%d	compare failure!!!",comp_times);
			$display("passwd_o(DUT):%0x",out_tr.passwd_o);
			$display("passwd_o(RM ):%0x",rm_tr.passwd_o);
			`uvm_error("score_board","compare failure!!!");
		end
		$display("");
		comp_times++;
		if(comp_times == vc.data_num)
			break;
	end
	phase.drop_objection(this);
endtask
