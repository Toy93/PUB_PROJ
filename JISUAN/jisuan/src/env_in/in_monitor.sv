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

