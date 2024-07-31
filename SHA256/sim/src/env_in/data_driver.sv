// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:06
// Last Modified : 2024/06/10 14:10
// File Name     : data_driver.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
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
	extern virtual task drive_one_pkg(data_transaction tr);
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
	`uvm_info(get_type_name(),"reset_phase is called",UVM_LOW)
	phase.raise_objection(this);
	in_if.start <= 0;
	clk_if.rst_n <= 1;
	repeat({$random}%5+1)@(posedge clk_if.clk);
	clk_if.rst_n <= 0;
	repeat({$random}%5+1)@(posedge clk_if.clk);
	clk_if.rst_n<= 1;
	phase.drop_objection(this);
endtask 

task data_driver::main_phase(uvm_phase phase);
	bit get_data = 1'b0;
	int send_data_num = 0;
	super.main_phase(phase);
	`uvm_info(get_type_name(),"main_phase is called",UVM_LOW)
	fork
		while(1)begin
			seq_item_port.get_next_item(req);
			drive_one_pkg(req);
			seq_item_port.item_done();
			`uvm_info(get_type_name(),"send one data package to dut",UVM_LOW)
		end
	join
endtask 

task data_driver::drive_one_pkg(data_transaction tr);
	@(posedge clk_if.clk);
	in_if.start <= 1'b1;
	@(posedge clk_if.clk);
	in_if.start <= 1'b0;
endtask
