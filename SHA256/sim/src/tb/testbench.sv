`include "uvm_macros.svh"
`include "uvm_pkg.sv"
`include "coverage.sv"
import uvm_pkg::*;
module testbench();
	clk_rst_if clk_if();
	input_data_if in_if();
	output_data_if out_if();
	
	crypto_sign U_CRYPTO_SIGN (/*autoinst*/
        .clk                    (clk_if.clk                     ), //input
        .rstn                   (clk_if.rst_n                   ), //input
        .start                  (in_if.start                    ), //input
        .dout_vld               (out_if.dout_vld                ), //output
        .dout                   (out_if.dout[255:0]             )  //output
    );

	initial begin
		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.sha256_env.sha256_in_agent.sha256_data_driver","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.sha256_env.sha256_in_agent.sha256_data_driver","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.sha256_env.sha256_in_agent.sha256_in_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual input_data_if)::set(null,"uvm_test_top.sha256_env.sha256_in_agent.sha256_in_monitor","vif_input_data",in_if);

		uvm_config_db#(virtual clk_rst_if)::set(null,"uvm_test_top.sha256_env.sha256_out_agent.sha256_out_monitor","vif_clk_rst",clk_if);
		uvm_config_db#(virtual output_data_if)::set(null,"uvm_test_top.sha256_env.sha256_out_agent.sha256_out_monitor","vif_output_data",out_if);
	end
	
	`include "dump_wave.sv"
	`include "run_test.sv"
	coverage u_coverage(clk_if,in_if,out_if);
endmodule
//Local Variables:
//verilog-library-directories:("../rtl")
//verilog-library-directories-recursive:1
//End:
