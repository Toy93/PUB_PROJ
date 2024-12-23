// +FHDR----------------------------------------------------------------------------
// Project Name  : TRANSFORMER
// Author        : MuChen
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/03/31 17:06
// Last Modified : 2024/04/14 09:59
// File Name     : soft_max.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/03/31   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module SOFT_MAX#(
	parameter DATA_WIDTH = 16,
	parameter DATA_NUM = 4,
	parameter INFO_WIDTH = 20
)(
	input									clk               , 
	input									rst_n             , 
	input                           		sum_clear         , 
	input [INFO_WIDTH-1:0]				    soft_max_info_in  ,
	input                           		denomintor_in_vld , 
	input                           		numerator_in_vld  , 
	input [DATA_NUM*DATA_WIDTH-1:0] 		denomintor_in     , 
	input [DATA_NUM*DATA_WIDTH-1:0] 		numerator_in      , 

	output reg                              denomintor_sum_ok ,
	output									out_vld           , 
	output     [DATA_NUM*DATA_WIDTH-1:0]    data_out          , 
	output reg [INFO_WIDTH-1:0]				soft_max_info_out 
);	

	/*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    reg  [DATA_WIDTH-1:0]       denomintor_sum                  ;
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here
    wire                                 exp_in_vld             ; // WIRE_NEW
    wire                                 exp_out_vld            ; // WIRE_NEW
    wire                                 sum0_vld               ;
    wire [15:0]                          sum0                   ;
    wire                                 sum1_vld               ;
    wire [15:0]                          sum1                   ;
    wire                                 sum2_in_vld            ;
    wire                                 sum2_vld               ;
    wire [15:0]                          sum2                   ;
    wire                                 result_vld0            ;
    //End of automatic wire
    //End of automatic define
    wire [DATA_NUM*DATA_WIDTH-1:0]exp_in;
    wire [DATA_NUM*DATA_WIDTH-1:0]exp;
    wire [DATA_NUM*DATA_WIDTH-1:0]exp_denomintor_in;
    wire [DATA_NUM*DATA_WIDTH-1:0]exp_numerator_in;
	
	assign exp_in_vld = denomintor_in_vld|numerator_in_vld;
	assign exp_in = denomintor_in_vld ? denomintor_in : numerator_in;
	generate 
		genvar I;
		for(I = 0; I < DATA_NUM; I = I+1)begin:U
			EXP_FLOAT16 EXP(
				.clk                    (clk                                 ), //input
        		.rst_n                  (rst_n                               ), //input
        		.in_vld                 (exp_in_vld                          ), //input
        		.data_in                (exp_in[I*DATA_WIDTH+:DATA_WIDTH]    ), //input
        		.out_vld                (exp_out_vld                         ), //output
        		.exp                    (exp[I*DATA_WIDTH+:DATA_WIDTH]       )  //output
		    );
		end
	endgenerate
	assign exp_denomintor_in= exp;
	assign exp_numerator_in = exp;


	ADD U0_ADD(/*autoinst*/
        .info_in                (23'd0                                            ), //input
        .data0                  (exp_denomintor_in[DATA_WIDTH*1-1-:DATA_WIDTH]    ), //input
        .data1                  (exp_denomintor_in[DATA_WIDTH*2-1-:DATA_WIDTH]    ), //input
        .in_vld                 (denomintor_in_vld                                ), //input
        .out_vld                (sum0_vld                                         ), //output
        .info_out               (                                                 ), //output
        .sum                    (sum0                                             )  //output
    );

	ADD U1_ADD(/*autoinst*/
        .info_in                (23'd0                                            ), //input
        .data0                  (exp_denomintor_in[DATA_WIDTH*3-1-:DATA_WIDTH]    ), //input
        .data1                  (exp_denomintor_in[DATA_WIDTH*4-1-:DATA_WIDTH]    ), //input
        .in_vld                 (denomintor_in_vld                                ), //input
        .out_vld                (sum1_vld                                         ), //output
        .info_out               (                                                 ), //output
        .sum                    (sum1                                             )  //output
    );

	assign sum2_in_vld = sum0_vld&sum1_vld;
	ADD U2_ADD(/*autoinst*/
        .info_in                (23'd0                          ), //input
        .data0                  (sum0                           ), //input
        .data1                  (sum1                           ), //input
        .in_vld                 (sum2_in_vld                    ), //input
        .out_vld                (sum2_vld                       ), //output
        .info_out               (                               ), //output
        .sum                    (sum2                           )  //output
    );

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			denomintor_sum <= {DATA_WIDTH{1'b0}};
		end
		else if(sum_clear)begin
			denomintor_sum <= {DATA_WIDTH{1'b0}};
		end
		else if(sum2_vld)begin
			denomintor_sum <= denomintor_sum+sum2;
		end
	end

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			denomintor_sum_ok <= 1'b0;
		end
		else if(sum2_vld&soft_max_info_in[15])begin
			denomintor_sum_ok <= 1'b1;
		end
		else begin
			denomintor_sum_ok <= 1'b0;
		end
	end
	DIVISION_FLOAT16 #(/*autoinstparam*/
        .DATA_WIDTH             (DATA_WIDTH                     ) 
    )
    U0_DIVISION_FLOAT16(/*autoinst*/
        .clk                    (clk                                             ), //input
        .rst_n                  (rst_n                                           ), //input
        .in_vld                 (numerator_in_vld                                ), //input
        .dividend               (exp_numerator_in[1*DATA_WIDTH-1-:DATA_WIDTH]    ), //input
        .divider                (denomintor_sum                                  ), //input
        .out_vld                (result_vld0                                     ), //output
        .result                 (data_out[1*DATA_WIDTH-1-:DATA_WIDTH]            )  //output
    );

	DIVISION_FLOAT16 #(/*autoinstparam*/
        .DATA_WIDTH             (DATA_WIDTH                     ) 
    )
    U1_DIVISION_FLOAT16(/*autoinst*/
        .clk                    (clk                                             ), //input
        .rst_n                  (rst_n                                           ), //input
        .in_vld                 (numerator_in_vld                                ), //input
        .dividend               (exp_numerator_in[2*DATA_WIDTH-1-:DATA_WIDTH]    ), //input
        .divider                (denomintor_sum                                  ), //input
        .out_vld                (                                                ), //output
        .result                 (data_out[2*DATA_WIDTH-1-:DATA_WIDTH]            )  //output
    );

	DIVISION_FLOAT16 #(/*autoinstparam*/
        .DATA_WIDTH             (DATA_WIDTH                     ) 
    )
    U2_DIVISION_FLOAT16(/*autoinst*/
        .clk                    (clk                                             ), //input
        .rst_n                  (rst_n                                           ), //input
        .in_vld                 (numerator_in_vld                                ), //input
        .dividend               (exp_numerator_in[3*DATA_WIDTH-1-:DATA_WIDTH]    ), //input
        .divider                (denomintor_sum                                  ), //input
        .out_vld                (                                                ), //output
        .result                 (data_out[3*DATA_WIDTH-1-:DATA_WIDTH]            )  //output
    );

	DIVISION_FLOAT16 #(/*autoinstparam*/
        .DATA_WIDTH             (DATA_WIDTH                     ) 
    )
    U3_DIVISION_FLOAT16(/*autoinst*/
        .clk                    (clk                                             ), //input
        .rst_n                  (rst_n                                           ), //input
        .in_vld                 (numerator_in_vld                                ), //input
        .dividend               (exp_numerator_in[4*DATA_WIDTH-1-:DATA_WIDTH]    ), //input
        .divider                (denomintor_sum                                  ), //input
        .out_vld                (                                                ), //output
        .result                 (data_out[4*DATA_WIDTH-1-:DATA_WIDTH]            )  //output
    );

	assign out_vld = result_vld0;

	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			soft_max_info_out <= 'd0;
		end
		else if(denomintor_in_vld|numerator_in_vld)begin
			soft_max_info_out <= soft_max_info_in;
		end
	end
	
endmodule
//Local Variables:
//verilog-library-directories:(".",)
//verilog-library-directories-recursive:1
//End:
