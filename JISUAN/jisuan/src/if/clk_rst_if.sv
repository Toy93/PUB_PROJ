/*************************************************************************
    # File Name: clk_rst_if.sv
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Tue 19 Apr 2022 12:49:00 AM EDT
*************************************************************************/
interface clk_rst_if();
	logic clk;
	logic rst_n;
	function void test0;
		int a = 0;
		a++;
		$display("yqs==%d",a);
	endfunction
	initial begin
		test0();
		test0();
	end
endinterface
