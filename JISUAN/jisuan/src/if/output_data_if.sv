/*************************************************************************
    # File Name: output_data_if.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Tue 19 Apr 2022 12:50:19 AM EDT
*************************************************************************/
interface output_data_if();
	logic out_vld;
	logic out_rdy;
	logic [`OUTPUT_LEN*8 -1:0]password_o;
endinterface

