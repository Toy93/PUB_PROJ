// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:05
// Last Modified : 2024/06/26 23:37
// File Name     : rm_model.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
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
	integer fp;
	data_transaction tr;
	uvm_event ev_write_finish = uvm_event_pool::get_global("dout_vld_ev");
	super.main_phase(phase);
	`uvm_info("rm_model","main_phase is called",UVM_LOW)
	fp = $fopen("/home/ICer/work/PROJ_HOME/HW/Design/SHA256/sim/src/rm/sm.txt","r");
	if(fp == 0)begin
		`uvm_error(get_type_name(),"open sm.txt failure!!!")
	end
	while(!$feof(fp))begin
		ev_write_finish.wait_trigger();
		ev_write_finish.reset();
		tr = new("tr");
		$fscanf(fp,"%h",tr.top_out);
		`uvm_info(get_type_name(),$sformatf("rm:tr.top_out = %h",tr.top_out),UVM_DEBUG)
		ap.write(tr);
	end
	$fclose(fp);
endtask
