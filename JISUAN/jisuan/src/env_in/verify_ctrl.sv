/*************************************************************************
    # File Name: verify_ctrl.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Fri 22 Apr 2022 09:27:11 PM EDT
*************************************************************************/
class verify_ctrl;
	rand byte data_num;
	//constraint cons0
	//{
	//	data_num inside{[0:100]};
	//}
	constraint cons1
	{
		data_num == 2;
    }
	function void post_randomize();
		$display("run_num is %d",data_num);
	endfunction
endclass

