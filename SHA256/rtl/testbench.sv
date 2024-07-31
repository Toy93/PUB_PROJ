module testbench();
	reg clk;
	reg rstn;
	reg start;
	wire dout_vld;
	wire [255:0]dout;

	initial begin
		clk <= 1'b0;
		forever begin
			#5 clk <= ~clk;
		end
	end

	initial begin
		rstn <= 1'b0;
		#20;
		rstn <= 1'b1;
	end

	initial begin
		start <= 1'b0;
		repeat(10)@(posedge clk);
		start <= 1'b1;
		@(posedge clk);
		start <= 1'b0;
	end
	crypto_sign u_crypto_sign (/*autoinst*/
        .clk                    (clk                            ), //input
        .rstn                   (rstn                           ), //input
        .start                  (start                          ), //input
        .dout_vld               (dout_vld                       ), //output
        .dout                   (dout[255:0]                    )  //output
        //INST_DEL: Port sys_clk_n has been deleted.
    );

	`include "dump_wave.sv"
endmodule
//Local Variables:
//verilog-library-directories:(".")
//verilog-library-directories-recursive:1
//End:
