	
class rm_model extends uvm_component;
	uvm_analysis_port#(data_transaction) ap;
	uvm_blocking_get_port#(data_transaction) r_mon_port;
	
	logic [7:0]register[31:0];
	logic [7:0]led;
	byte unsigned prog_cnt;
	function new(string name = "rm_model",uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("rm_model","new is called",UVM_LOW)
	endfunction	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void cpu_deal(data_transaction tr);
	`uvm_component_utils(rm_model)
endclass

function void rm_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("rm_model","build_phase is called",UVM_LOW)
	ap = new("ap",this);
	r_mon_port = new("r_mon_port",this);
endfunction

function void rm_model::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("rm_model","connect_phase is called",UVM_LOW)
endfunction

task rm_model::main_phase(uvm_phase phase);
	data_transaction tr;
	super.main_phase(phase);
	`uvm_info("rm_model","main_phase is called",UVM_LOW)
	foreach(register[i])begin
		register[i] = 8'd0;
	end
	while(1)begin
		r_mon_port.get(tr);
		cpu_deal(tr);
		ap.write(tr);
	end
endtask

function void rm_model::cpu_deal(data_transaction tr);
	logic [5:0]op_code;
	logic [4:0]des_addr;
	logic [4:0]src_addr;
	logic [7:0]imme_data;
	{op_code,des_addr,src_addr,imme_data} = tr.cmd;
	
	case(op_code)
		`OP_NOP  :begin  // 无操作
			prog_cnt++;
		end
    	`OP_ADD  :begin  // 加法操作
			prog_cnt++;
			register[des_addr] = register[src_addr]+register[imme_data[4:0]];
		end
    	`OP_SUB  :begin  // 减法操作
			prog_cnt++;
			register[des_addr] = register[src_addr]-register[imme_data[4:0]];
		end
    	`OP_MUL  :begin  // 乘法操作
			prog_cnt++;
			register[des_addr] = register[src_addr]*register[imme_data[4:0]];
		end
		`OP_DIV  :begin 
			prog_cnt++;
			if(register[src_addr]==0)begin
				register[des_addr] = 8'd0;
			end
			else begin
				register[des_addr] = register[src_addr]/register[imme_data[4:0]];
			end
		end
    	`OP_ADDI :begin  // 加立即数
			prog_cnt++;
			register[des_addr] = imme_data+register[src_addr];
		end
    	`OP_LDI  :begin  // 载入立即数到寄存器
			prog_cnt++;
			register[des_addr] = imme_data;
		end
    	`OP_LW   :begin  // 从内存加载到寄存器
			prog_cnt++;
			if(imme_data==1)begin
				register[des_addr] = tr.sw[7:0];
			end
			else if(imme_data==2)begin
				register[des_addr] = {7'd0,tr.sw[8]};
			end
		end
    	`OP_SW   :begin  // 从寄存器存储到内存
			prog_cnt++;
			register[des_addr] = register[src_addr];
		end
    	`OP_BEQ  :begin  // 分支如果等于
			if(register[des_addr] == register[src_addr])begin
				prog_cnt=imme_data;
			end
			else begin
				prog_cnt++;
			end
		end
    	`OP_J    :begin  // 跳转
			prog_cnt=imme_data;
		end
		`OP_BNE  :begin  //
			if(register[des_addr] != register[src_addr])begin
				prog_cnt=imme_data;
			end
			else begin
				prog_cnt++;
			end
		end
		`OP_MOV  :begin
			prog_cnt++;
			register[des_addr] = register[src_addr];
		end
	endcase
	$display("prog_cnt=%d",prog_cnt);
	tr.cmd_addr = prog_cnt;
	tr.reg_data = register[des_addr];
endfunction

