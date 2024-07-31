/*************************************************************************
    # File Name: input_data_if.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Tue 19 Apr 2022 12:50:19 AM EDT
*************************************************************************/
interface input_data_if();
	logic in_vld;
	logic in_rdy;
	logic in_sel;
	logic [(`PASSWD_LEN/2)*8 -1:0]password;
endinterface

