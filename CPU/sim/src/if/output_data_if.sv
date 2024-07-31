/*************************************************************************
    # File Name: output_data_if.sv
    # Author: Mu Chen
    # Mail: yqs_ahut@163.com
    # QQ: 3221153405
    # Created Time: 2024年03月23日 星期六 20时56分39秒
*************************************************************************/
interface output_data_if(clk_rst_if clk_if);
	logic [7:0]led;
	
	logic [7:0]cmd_addr;
	logic [23:0]cmd;
	logic [7:0]register[31:0];

	reg [23:0]cmd_1d;

	assign cmd_addr = testbench.PICO_MIPS.U_PC.addr_c[7:0];
	assign cmd = testbench.PICO_MIPS.cmd[23:0];
	assign register = testbench.PICO_MIPS.U_REGS.register;
	always@(posedge clk_if.clk)begin
		cmd_1d <= cmd;
	end
endinterface

