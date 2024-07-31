class cmd_transaction extends uvm_sequence_item;
	typedef enum bit[5:0]{
		OP_NOP  = `OP_NOP ,  // 无操作
    	OP_ADD  = `OP_ADD ,  // 加法操作
    	OP_SUB  = `OP_SUB ,  // 减法操作
    	OP_MUL  = `OP_MUL ,  // 乘法操作
		OP_DIV  = `OP_DIV , 
    	OP_ADDI = `OP_ADDI,  // 加立即数
    	OP_LDI  = `OP_LDI ,  // 载入立即数到寄存器
    	OP_LW   = `OP_LW  ,  // 从内存加载到寄存器
    	OP_SW   = `OP_SW  ,  // 从寄存器存储到内存
    	OP_BEQ  = `OP_BEQ ,  // 分支如果等于
    	OP_J    = `OP_J   ,  // 跳转
		OP_BNE  = `OP_BNE ,  //
		OP_MOV  = `OP_MOV 
	}op_code;

	rand byte unsigned cmd_num;
	rand op_code my_op_code[];
	rand bit [4:0]des_addr[];
	rand bit [4:0]src_addr[];
	rand bit [7:0]imme_num[];

	constraint cons_my_op_code{
		foreach(src_addr[i]){
			my_op_code[i] inside {
				OP_NOP ,  
				OP_ADD ,
				OP_SUB ,
				OP_MUL ,
				OP_DIV ,
				OP_ADDI,
				OP_LDI ,
				//OP_LW  ,
				//OP_SW  ,
				//OP_BEQ ,
				OP_J, 
				//OP_BNE ,
				OP_MOV 
			};
		}
		my_op_code[my_op_code.size-1] == OP_J;
	}

	constraint cons_des_addr{
		foreach(src_addr[i]){
			des_addr[i] inside {[0:31]};
		}
	}

	constraint cons_src_addr{
		foreach(src_addr[i]){
			src_addr[i] inside {[0:31]};
		}
	}

	constraint cons_imme_num{
		foreach(src_addr[i]){
			imme_num[i] inside {[0:255]};
		}
		imme_num[imme_num.size-1] == 0;
	}

	constraint cons_cmd_num{
		//cmd_num inside {[1:32]};
		cmd_num == 255;
		my_op_code.size  == cmd_num;
		src_addr.size == cmd_num;
		des_addr.size == cmd_num;
		imme_num.size == cmd_num;
	}

	function new(string name = "cmd_transaction");
		super.new(name);
		`uvm_info(get_type_name(),"new is called",UVM_LOW)
	endfunction

	function void post_randomize();
		`uvm_info(get_type_name(),"post_randomize is called",UVM_LOW)
		this.print();
		write_to_file();
	endfunction

	extern function void write_to_file();
	`uvm_object_utils_begin(cmd_transaction)
		`uvm_field_int(cmd_num,UVM_ALL_ON)
		`uvm_field_array_enum(op_code,my_op_code,UVM_ALL_ON)
		`uvm_field_array_int(src_addr,UVM_ALL_ON)
		`uvm_field_array_int(des_addr,UVM_ALL_ON)
		`uvm_field_array_int(imme_num,UVM_ALL_ON)
	`uvm_object_utils_end
endclass

function void cmd_transaction::write_to_file();
	integer fp;
	bit [23:0]cmd;
	fp = $fopen("program.txt","w");
	if(fp == 0)begin
		`uvm_fatal(get_type_name(),"open program.txt failure!")
	end
	for(int i = 0 ;i <cmd_num; i++)begin
		cmd = {my_op_code[i],des_addr[i],src_addr[i],imme_num[i]};
		$fdisplay(fp,"%b",cmd);
	end
	$fclose(fp);
endfunction
