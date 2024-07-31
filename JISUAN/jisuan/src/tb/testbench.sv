`include "uvm_macros.svh"
`include "uvm_pkg.sv"
//`include "test.sv"
import uvm_pkg::*;
module testbench();
	clk_rst_if clk_if();
	input_data_if in_if();
	output_data_if out_if();
	//instant module
	JISUAN #(
		.PASSWD_LEN(80),
		.OUTPUT_LEN(32)
	)U_JISUAN (
		.clk		(clk_if.clk  ),
		.rst_n		(clk_if.rst_n),
	
		//interface with TB
		.in_vld		(in_if.in_vld	 ),
		.in_rdy		(in_if.in_rdy	 ),
		.in_sel		(in_if.in_sel    ),
		.password	(in_if.password  ),
		
		.out_vld   (out_if.out_vld   ),
		.out_rdy   (out_if.out_rdy   ),
		.password_o(out_if.password_o)
	);
	

	initial begin
		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.jisuan_env.jisuan_in_agent.jisuan_data_driver","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.jisuan_env.jisuan_in_agent.jisuan_data_driver","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.jisuan_env.jisuan_in_agent.jisuan_in_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.jisuan_env.jisuan_in_agent.jisuan_in_monitor","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.jisuan_env.jisuan_out_agent.jisuan_out_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual output_data_if)::set(null,"uvm_test_top.jisuan_env.jisuan_out_agent.jisuan_out_monitor","vif_output_data",out_if);
	end
	
	initial begin
		clk_if.clk = 0;
		forever begin
			#5 clk_if.clk = ~clk_if.clk;
		end
	end
	
	initial begin
		clk_if.rst_n <= 1;
		#3ns;
		clk_if.rst_n <= 0;
		@(posedge clk_if.clk);
		clk_if.rst_n <= 1;
	end
	
	initial begin
		bit dump_fsdb;
		if($test$plusargs("DUMP_FSDB"))begin
			$fsdbDumpfile("tb.fsdb");//waveform name
			$fsdbDumpvars(0,testbench);
			$fsdbDumpMDA();
			$fsdbDumpSVA();
			$fsdbDumpflush();
		end
	end
	
	initial begin
		string tc_name = "";
		$value$plusargs("UVM_TESTNAME=%s",tc_name);
		run_test(tc_name);
	end	
	//test u_test(clk_rst_if.clk,clk_rst_if.rst_n);

	wire sda;
	reg oe0;
	reg oe1;
	assign sda= oe0==1?0:1'b1;
	assign sda= oe1==1?0:1'b1;
	initial begin
		oe0 = 1'b0;
		oe1 = 1'b0;
#5;
		oe0 = 1'b0;
		oe1 = 1'b1;
#5;
		oe0 = 1'b1;
		oe1 = 1'b0;
#5;
		oe0 = 1'b1;
		oe1 = 1'b1;

	end
endmodule
