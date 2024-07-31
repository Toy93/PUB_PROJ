// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:05
// Last Modified : 2024/07/18 22:12
// File Name     : score_board.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
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
	verify_ctrl vc;
	data_transaction rm_tr;
	data_transaction out_tr;
	int comp_times = 0;
	super.main_phase(phase);
	`uvm_info("score_board","main_phase is called",UVM_LOW)
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	phase.raise_objection(this);
	fork 
		while(1)begin
			fork
				rm_port.get(rm_tr);
				out_port.get(out_tr);
			join 
			if(out_tr.top_out== rm_tr.top_out)begin
				`uvm_info(get_type_name(),$sformatf("compare success!!!,me_sha256_statebytes_o(dut):%0h\tsha256_statebytes_o(rm):%0h---comp_times=%0d",out_tr.top_out,rm_tr.top_out,rm_tr.comp_times),UVM_LOW)
			end	
			else begin
				`uvm_error(get_type_name(),$sformatf("compare failue!!!,me_sha256_statebytes_o(dut):%0h\tsha256_statebytes_o(rm):%0h---comp_times=%0d",out_tr.top_out,rm_tr.top_out,rm_tr.comp_times))
			end
			//if(out_tr.me_sha256_statebytes_o== out_tr.sha256_statebytes_o)begin
			//	`uvm_info(get_type_name(),$sformatf("compare success!!!,me_sha256_statebytes_o(dut):%0h\tsha256_statebytes_o(rm):%0h",out_tr.me_sha256_statebytes_o,out_tr.sha256_statebytes_o),UVM_LOW)
			//end	
			//else begin
			//	`uvm_error(get_type_name(),$sformatf("compare failue!!!,me_sha256_statebytes_o(dut):%0h\tsha256_statebytes_o(rm):%0h",out_tr.me_sha256_statebytes_o,out_tr.sha256_statebytes_o))
			//end
			//comp_times++;
			//if(comp_times == vc.data_num)
			//	break;
		end
	join_any
	phase.drop_objection(this);
endtask
