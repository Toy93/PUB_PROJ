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
	string rm_cmd_name;
	string dut_cmd_name;
	int comp_times = 0;
	super.main_phase(phase);
	`uvm_info("score_board","main_phase is called",UVM_LOW)
	uvm_resource_db#(verify_ctrl)::read_by_name("","verify_ctrl",vc);
	phase.raise_objection(this);
	while(1)begin
		fork
			rm_port.get(rm_tr);
			out_port.get(out_tr);
		join 
		case(rm_tr.cmd[23:18])
			`OP_NOP  :rm_cmd_name = "OP_NOP"    ;
			`OP_ADD  :rm_cmd_name = "OP_ADD"    ;
			`OP_SUB  :rm_cmd_name = "OP_SUB"    ;
			`OP_MUL  :rm_cmd_name = "OP_MUL"    ;
			`OP_DIV  :rm_cmd_name = "OP_DIV"    ;
			`OP_ADDI :rm_cmd_name = "OP_ADDI"   ;
			`OP_LDI  :rm_cmd_name = "OP_LDI"    ;
			`OP_LW   :rm_cmd_name = "OP_LW"     ;
			`OP_SW   :rm_cmd_name = "OP_SW"     ;
			`OP_BEQ  :rm_cmd_name = "OP_BEQ"    ;
			`OP_J    :rm_cmd_name = "OP_J"      ;
			`OP_BNE  :rm_cmd_name = "OP_BNE"    ;
			`OP_MOV  :rm_cmd_name = "OP_MOV"    ;
		endcase
		case(out_tr.cmd[23:18])
			`OP_NOP  :dut_cmd_name = "OP_NOP"    ;
			`OP_ADD  :dut_cmd_name = "OP_ADD"    ;
			`OP_SUB  :dut_cmd_name = "OP_SUB"    ;
			`OP_MUL  :dut_cmd_name = "OP_MUL"    ;
			`OP_DIV  :dut_cmd_name = "OP_DIV"    ;
			`OP_ADDI :dut_cmd_name = "OP_ADDI"   ;
			`OP_LDI  :dut_cmd_name = "OP_LDI"    ;
			`OP_LW   :dut_cmd_name = "OP_LW"     ;
			`OP_SW   :dut_cmd_name = "OP_SW"     ;
			`OP_BEQ  :dut_cmd_name = "OP_BEQ"    ;
			`OP_J    :dut_cmd_name = "OP_J"      ;
			`OP_BNE  :dut_cmd_name = "OP_BNE"    ;
			`OP_MOV  :dut_cmd_name = "OP_MOV"    ;
		endcase
		if(rm_tr.cmd != out_tr.cmd || rm_tr.cmd_addr != out_tr.cmd_addr || rm_tr.reg_data != out_tr.reg_data)begin

			`uvm_error(get_type_name(),$sformatf("compare failue\n\
						rm.cmd_name = %s, \t\t\tdut.cmd_name = %s\n\
						rm.op_code  = %b, \t\t\tdut.op_code  = %b\n\
						rm.des_addr = %d, \t\t\tdut.des_addr = %d\n\
						rm.src_addr = %d, \t\t\tdut.src_addr = %d\n\
						rm.imm_data = %d, \t\t\tdut.imm_data = %d\n\
						rm.cmd_addr = %d, \t\t\tdut.cmd_addr = %d\n\
						rm.reg_data = %d, \t\t\tdut.reg_data = %d",
						rm_cmd_name,dut_cmd_name,
						rm_tr.cmd[23:18],out_tr.cmd[23:18],
						rm_tr.cmd[17:13],out_tr.cmd[17:13],
						rm_tr.cmd[12:8],out_tr.cmd[12:8],
						rm_tr.cmd[7:0],out_tr.cmd[7:0],
						rm_tr.cmd_addr,out_tr.cmd_addr,
						rm_tr.reg_data,out_tr.reg_data))
		end
		else begin
			`uvm_info(get_type_name(),$sformatf("compare success\n\
						rm.cmd_name = %s, \t\t\tdut.cmd_name = %s\n\
						rm.op_code  = %b, \t\t\tdut.op_code  = %b\n\
						rm.des_addr = %d, \t\t\tdut.des_addr = %d\n\
						rm.src_addr = %d, \t\t\tdut.src_addr = %d\n\
						rm.imm_data = %d, \t\t\tdut.imm_data = %d\n\
						rm.cmd_addr = %d, \t\t\tdut.cmd_addr = %d\n\
						rm.reg_data = %d, \t\t\tdut.reg_data = %d",
						rm_cmd_name,dut_cmd_name,
						rm_tr.cmd[23:18],out_tr.cmd[23:18],
						rm_tr.cmd[17:13],out_tr.cmd[17:13],
						rm_tr.cmd[12:8],out_tr.cmd[12:8],
						rm_tr.cmd[7:0],out_tr.cmd[7:0],
						rm_tr.cmd_addr,out_tr.cmd_addr,
						rm_tr.reg_data,out_tr.reg_data),UVM_DEBUG)
		end
		//if(rm_tr.send_data == out_tr.mon_data[8:1])begin
		//	`uvm_info(get_type_name(),$sformatf("compare success!!!,send data:%b\trecv data:%b",rm_tr.send_data,out_tr.mon_data[8:1]),UVM_LOW)
		//end	
		//else begin
		//	`uvm_error(get_type_name(),$sformatf("compare  failue!!!,send data:%b\trecv data:%b",rm_tr.send_data,out_tr.mon_data[8:1]))
		//end
		comp_times++;
		if(comp_times == vc.data_num)
			break;
	end
	phase.drop_objection(this);
endtask
