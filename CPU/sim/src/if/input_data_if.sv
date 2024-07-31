/*************************************************************************
    # File Name: input_data_if.sv
    # Author: Mu Chen
    # Mail: yqs_ahut@163.com
    # QQ: 3221153405
    # Created Time: 2024年03月23日 星期六 20时56分39秒
*************************************************************************/
interface input_data_if();
	logic [8:0]sw;
	logic [8:0]imme_data;
	logic [23:0]cmd;

	logic [5:0]op_code;
	logic [4:0]des_addr;
	logic [4:0]src_addr;
	logic [7:0]imme_data;
	
	assign cmd = testbench.PICO_MIPS.cmd[23:0];
	assign {op_code,des_addr,src_addr,imme_data} = cmd;
endinterface

