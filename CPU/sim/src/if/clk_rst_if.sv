/*************************************************************************
    # File Name: clk_rst_if.sv
    # Author: Mu Chen
    # Mail: yqs_ahut@163.com
    # QQ: 3221153405
    # Created Time: 2024年03月23日 星期六 20时56分39秒
*************************************************************************/
//interface clk_rst_if(input realtime period);
interface clk_rst_if();
	logic clk;
	logic rst_n;
	//logic half_period;

	initial begin
		clk <= 0;
		//half_period = period/2;
		forever begin
			#5 clk <= ~clk;
		end
	end
endinterface
