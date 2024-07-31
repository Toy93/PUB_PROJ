`include "uvm_macros.svh"
`include "uvm_pkg.sv"
`include "coverage.sv"
import uvm_pkg::*;
module testbench();
	clk_rst_if clk_if();
	input_data_if in_if();
	output_data_if out_if(clk_if);

	/*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here

    //End of automatic wire
    //End of automatic define

	PICO_MIPS PICO_MIPS(
		.clk(clk_if.clk),
		.rst_n(clk_if.rst_n),
		.sw (in_if.sw), 
	
		.led(out_if.led) 
	);

	initial begin
		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.cpu_env.cpu_in_agent.cpu_data_driver","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.cpu_env.cpu_in_agent.cpu_data_driver","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.cpu_env.cpu_in_agent.cpu_in_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.cpu_env.cpu_in_agent.cpu_in_monitor","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.cpu_env.cpu_out_agent.cpu_out_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual output_data_if)::set(null,"uvm_test_top.cpu_env.cpu_out_agent.cpu_out_monitor","vif_output_data",out_if);
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
	
	coverage u_coverage(clk_if,in_if,out_if);

//Local Variables:
//verilog-library-directories:(".")
//verilog-library-directories:("/home/ICer/work/PROJ_HOME/HW/Design/AMBA_APB4/rtl")
//verilog-library-directories-recursive:1
//End:
endmodule

