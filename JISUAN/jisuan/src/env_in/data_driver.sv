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
			seq_item_port.item_done();
			$display("item_done");
			in_if.in_vld <= 1'b0;
			in_if.in_sel <= 1'b0;
		end
	join
endtask 
