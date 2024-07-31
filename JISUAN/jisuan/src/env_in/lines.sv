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
		$display("=================TEST CASE PASSED=============");
	else 
		$display("=================TEST CASE FAILED=============");
endfunction
class data_driver extends uvm_driver#(data_transaction);
	virtual clk_rst_if clk_if;
	virtual input_data_if in_if;
	verify_ctrl vc;
	function new(string name = "data_driver",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("data_driver","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task reset_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(data_driver)
endclass

function void data_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("data_driver","build_phase is called",UVM_LOW)
endfunction

function void data_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("data_driver","connect_phase is called",UVM_LOW)
	if(!uvm_config_db#(virtual clk_rst_if)::get(this,"","vif_clk_rst",clk_if))
		`uvm_fatal("data_driver","virtual interface must be set for clk_if")
	if(!uvm_config_db#(virtual input_data_if)::get(this,"","vif_input_data",in_if))
		`uvm_fatal("data_driver","virtual interface must be set for in_if")
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
endfunction

task data_driver::reset_phase(uvm_phase phase);
	super.reset_phase(phase);
	`uvm_info("data_driver","data_driver is called",UVM_LOW)
	in_if.in_vld = 1'b0;
endtask 

task data_driver::main_phase(uvm_phase phase);
	bit get_data = 1'b0;
	int send_data_num = 0;
	super.main_phase(phase);
	`uvm_info("data_driver","main_phase is called",UVM_LOW)
	repeat(5)@(posedge clk_if.clk);
	fork
		//while(1)begin
		//	@(posedge clk_if.clk);
		//	if(send_data_num == vc.data_num)begin
		//		in_if.in_vld <= 1'b0;
		//	end
		//	else if(in_if.in_vld&in_if.in_rdy)begin
		//		repeat($urandom % 10)@(posedge clk_if.clk);
		//			in_if.in_vld <= 1'b1;
		//		repeat($urandom % 10)@(posedge clk_if.clk);
		//			in_if.in_vld <= 1'b0;
		//	end
		//	else if(in_if.in_rdy)begin
		//		repeat($urandom % 10)@(posedge clk_if.clk);
		//			in_if.in_vld <= 1'b1;
		//		repeat($urandom % 10)@(posedge clk_if.clk);
		//			in_if.in_vld <= 1'b0;
		//	end
		//end
		//while(1)begin
		//	@(posedge clk_if.clk)begin
		//		in_if.password <= req.passwd;
		//	end
		//end
		while(1)begin
			seq_item_port.get_next_item(req);
			@(posedge clk_if.clk);
			in_if.in_vld <= 1'b1;
			in_if.in_sel <= 1'b0;
			in_if.password <= req.passwd_low;
			while(1)begin
				@(posedge clk_if.clk);
				if(in_if.in_vld&in_if.in_rdy&(~in_if.in_sel))begin
					in_if.password <= req.passwd_high;
					in_if.in_sel <= 1'b1;
				end
				else if(in_if.in_vld&in_if.in_rdy&in_if.in_sel)begin
					break;
				end
			end
			//while(1)begin
			//	@(posedge clk_if.clk);
			//	if(in_if.in_vld&in_if.in_rdy)begin
			//		break;
			//	end
			//end
			//send_data_num++;
			seq_item_port.item_done();
			$display("item_done");
			in_if.in_vld <= 1'b0;
			in_if.in_sel <= 1'b0;
		end
	join
endtask 
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

class data_sequence extends uvm_sequence#(data_transaction);
	data_transaction tr;
	verify_ctrl vc;
	function new(string name = "data_sequence");
		super.new(name);
		`uvm_info("data_sequence","new is called",UVM_LOW)
	endfunction	
	extern task body();
	`uvm_object_utils(data_sequence)
endclass

task data_sequence::body();
	`uvm_info("data_sequence","body is called",UVM_LOW)
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	for(int i = 0; i < vc.data_num; i++)begin
		`uvm_create(tr);
		tr.randomize();
		`uvm_send(tr);
	end
	$display("data_sequence send datas finish");
endtask
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
/*************************************************************************
    # File Name: env.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 10:52:52 AM EDT
*************************************************************************/
class env extends uvm_env;
	in_agent `DUT_TOP_NAME(in_agent);
	out_agent `DUT_TOP_NAME(out_agent);
	rm_model `DUT_TOP_NAME(rm_model);
	score_board `DUT_TOP_NAME(score_board);
	verify_ctrl vc;
	uvm_tlm_analysis_fifo#(data_transaction) rm_fifo;
	uvm_tlm_analysis_fifo#(data_transaction) out_fifo;
	function new(string name = "env",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("env","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	`uvm_component_utils(env)
endclass

function void env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("env","build_phase is called",UVM_LOW)
	`DUT_TOP_NAME(in_agent) = in_agent::type_id::create(`DUT_TOP_NAME_STR(in_agent),this);
	`DUT_TOP_NAME(out_agent) = out_agent::type_id::create(`DUT_TOP_NAME_STR(out_agent),this);
	`DUT_TOP_NAME(rm_model) = rm_model::type_id::create(`DUT_TOP_NAME_STR(rm_model),this);
	`DUT_TOP_NAME(score_board) = score_board::type_id::create(`DUT_TOP_NAME_STR(score_board),this);
	rm_fifo = new("rm_fifo",this);
	out_fifo = new("out_fifo",this);
	vc = new();
	vc.randomize();
	uvm_resource_db#(verify_ctrl)::set("","verify_ctrl",vc);
endfunction

function void env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("env","connect_phase is called",UVM_LOW)
	`DUT_TOP_NAME(rm_model).ap.connect(rm_fifo.analysis_export);
	`DUT_TOP_NAME(out_agent).`DUT_TOP_NAME(out_monitor).ap.connect(out_fifo.analysis_export);
	`DUT_TOP_NAME(score_board).rm_port.connect(rm_fifo.blocking_get_export);
	`DUT_TOP_NAME(score_board).out_port.connect(out_fifo.blocking_get_export);
endfunction
/*************************************************************************
    # File Name: in_agent.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:53:49 AM EDT
*************************************************************************/
class in_agent extends uvm_agent;
	data_sequencer `DUT_TOP_NAME(data_sequencer);
	virtual_sequencer `DUT_TOP_NAME(virtual_sequencer);
	data_driver `DUT_TOP_NAME(data_driver);
	in_monitor `DUT_TOP_NAME(in_monitor);
	function new(string name = "in_agent",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("in_agent","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(in_agent)
endclass

function void in_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("in_agent","build_phase is called",UVM_LOW)
	`DUT_TOP_NAME(virtual_sequencer) = virtual_sequencer::type_id::create(`DUT_TOP_NAME_STR(virtual_sequencer),this);
	`DUT_TOP_NAME(data_sequencer) = data_sequencer::type_id::create(`DUT_TOP_NAME_STR(data_sequencer),this);
	`DUT_TOP_NAME(data_driver) = data_driver::type_id::create(`DUT_TOP_NAME_STR(data_driver),this);
	`DUT_TOP_NAME(in_monitor) = in_monitor::type_id::create(`DUT_TOP_NAME_STR(in_monitor),this);
endfunction

function void in_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("in_agent","connect_phase is called",UVM_LOW)
	`DUT_TOP_NAME(virtual_sequencer).`DUT_TOP_NAME(data_sequencer) = `DUT_TOP_NAME(data_sequencer);
	`DUT_TOP_NAME(data_driver).seq_item_port.connect(`DUT_TOP_NAME(data_sequencer).seq_item_export);
endfunction

task in_agent::main_phase(uvm_phase phase);
	super.main_phase(phase);
	`uvm_info("in_agent","main_phase is called",UVM_LOW)
endtask
/*************************************************************************
    # File Name: in_monitor.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:55:47 AM EDT
*************************************************************************/
class in_monitor extends uvm_monitor;
	virtual clk_rst_if clk_if;
	virtual input_data_if in_if;
	semaphore sem;
	function new(string name = "in_monitor",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("in_monitor","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(in_monitor)
endclass

function void in_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("in_monitor","build_phase is called",UVM_LOW)
	sem = new(1);
endfunction

function void in_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("in_monitor","connect_phase is called",UVM_LOW)
	if(!uvm_config_db#(virtual clk_rst_if)::get(this,"","vif_clk_rst",clk_if))
		`uvm_fatal("in_monitor","virtual interface must be set for clk_if");
	if(!uvm_config_db#(virtual input_data_if)::get(this,"","vif_input_data",in_if))
		`uvm_fatal("in_monitor","virtual interface must be set for in_if");
endfunction

task in_monitor::main_phase(uvm_phase phase);
	integer fp;
	int run_times = 0;
	bit [`PASSWD_LEN*8-1:0]passwd;
	verify_ctrl vc;
	uvm_event ev_write_finish = uvm_event_pool::get_global("ev_write_finish");
	super.main_phase(phase);
	`uvm_info("in_monitor","main_phase is called",UVM_LOW)
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	fp = $fopen("../ref_c/test_data/passwd.txt","wb");
	while(1)begin
		@(posedge clk_if.clk);
		if(in_if.in_vld & in_if.in_rdy & (~in_if.in_sel))begin
			$display("success monitor password:%0x from DUT input interface",in_if.password);
			passwd[(`PASSWD_LEN/2)*8-1:0]=in_if.password;
		end
		if(in_if.in_vld&in_if.in_rdy&in_if.in_sel)begin
			passwd[`PASSWD_LEN*8-1:(`PASSWD_LEN/2)*8] = in_if.password;
			for(int i = 79; i >= 0; i--)begin
				$fwrite(fp,"%c",passwd[8*i+:8]);
			end
			run_times++;
			if(run_times == vc.data_num)begin
				ev_write_finish.trigger();
				break;
			end
		end
	end
	$fclose(fp);
endtask

/*************************************************************************
    # File Name: out_agent.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:53:56 AM EDT
*************************************************************************/
class out_agent extends uvm_agent;
	out_monitor	`DUT_TOP_NAME(out_monitor);
	function new(string name = "out_agent",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("out_agent","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(out_agent)
endclass

function void out_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("out_agent","build_phase is called",UVM_LOW)
	`DUT_TOP_NAME(out_monitor) = out_monitor::type_id::create(`DUT_TOP_NAME_STR(out_monitor),this);
endfunction

function void out_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("out_agent","connect_phase is called",UVM_LOW)
endfunction

task out_agent::main_phase(uvm_phase phase);
	super.main_phase(phase);
	`uvm_info("out_agent","main_phase is called",UVM_LOW)
endtask
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
	$system("cd ../ref_c/src;gcc jisuan_20220425.c;./a.out | tee -i run.log");
	fp = $fopen("../ref_c/test_data/output.txt","r");
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
/*************************************************************************
    # File Name: score_board.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 09:56:50 AM EDT
*************************************************************************/
class score_board extends uvm_scoreboard;
	uvm_blocking_get_port#(data_transaction) rm_port;
	uvm_blocking_get_port#(data_transaction) out_port;
	function new(string name = "score_board",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("score_board","new is called",UVM_LOW)
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
	phase.raise_objection(this);
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
/*************************************************************************
    # File Name: data_sequencer.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 11:05:58 AM EDT
*************************************************************************/
class data_sequencer extends uvm_sequencer#(data_transaction);
	function new(string name = "data_sequencer",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("data_sequencer","new is called",UVM_LOW)
	endfunction	
	`uvm_component_utils(data_sequencer)
endclass
/*************************************************************************
    # File Name: verify_ctrl.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Fri 22 Apr 2022 09:27:11 PM EDT
*************************************************************************/
class verify_ctrl;
	rand byte data_num;
	//constraint cons0
	//{
	//	data_num inside{[0:100]};
	//}
	constraint cons1
	{
		data_num == 2;
    }
	function void post_randomize();
		$display("run_num is %d",data_num);
	endfunction
endclass

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

/*************************************************************************
    # File Name: virtual_sequence.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 20 Apr 2022 11:06:09 AM EDT
*************************************************************************/
class virtual_sequence extends uvm_sequence;
	data_sequence `DUT_TOP_NAME(data_sequence);
	`uvm_declare_p_sequencer(virtual_sequencer)
	function new(string name = "virtual_sequence");
		super.new(name);
		`uvm_info("virtual_sequence","new is called",UVM_LOW)
	endfunction
	virtual task body();
		`uvm_info("virtual_sequence","body is called",UVM_LOW)
		//if(starting_phase != null)begin
		//	starting_phase.raise_objection(this);
		//	$display("raise_objection");
		//end
		`uvm_create_on(`DUT_TOP_NAME(data_sequence),p_sequencer.`DUT_TOP_NAME(data_sequencer));
		`uvm_send(`DUT_TOP_NAME(data_sequence))
		//if(starting_phase != null)begin
		//	starting_phase.drop_objection(this);
		//	$display("drop_objection");
		//end
	endtask
	`uvm_object_utils(virtual_sequence)
endclass
