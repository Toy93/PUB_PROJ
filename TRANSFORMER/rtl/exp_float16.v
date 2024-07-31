// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 08:05
// Last Modified : 2024/04/14 09:44
// File Name     : exp_float16.v
// Description   :
// y = 1+x/1+(x**2)/2!+(x**3)/3!+(x**4)/4!+(x**5)/5!        
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module EXP_FLOAT16#(
	parameter DATA_WIDTH=16
)(
	input                   clk     , 
	input                   rst_n   , 
	input                   in_vld  , 
	input [DATA_WIDTH-1:0]  data_in , 

	output					out_vld , 
	output [DATA_WIDTH-1:0] exp
);
    parameter ONE   = 16'h3c00;
    parameter FACT2 = 16'b0_10000_0000000000;
    parameter FACT3 = 16'b0_10000_1000000000;
    parameter FACT4 = 16'b0_10011_1000000000;
    parameter FACT5 = 16'b0_10110_1110000000;

    /*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    //Define instance wires here
    wire [15:0]                 x                               ;
    wire [15:0]                 x2                              ;
    wire [15:0]                 x3                              ;
    wire [15:0]                 x4                              ;
    wire [15:0]                 x5                              ;
    wire [15:0]                 fact2                           ;
    wire [15:0]                 x2_div_fact2                    ;
    wire [15:0]                 fact3                           ;
    wire [15:0]                 x3_div_fact3                    ;
    wire [15:0]                 fact4                           ;
    wire [15:0]                 x4_div_fact4                    ;
    wire [15:0]                 fact5                           ;
    wire [15:0]                 x5_div_fact5                    ;
    wire [15:0]                 one                             ; // WIRE_NEW
    wire [15:0]                 add_x1                          ; // WIRE_NEW
    wire [15:0]                 add_x2                          ; // WIRE_NEW
    wire [15:0]                 add_x3                          ; // WIRE_NEW
    wire [15:0]                 add_x4                          ; // WIRE_NEW
    wire [15:0]                 add_x5                          ; // WIRE_NEW
    //End of automatic wire
    //End of automatic define

    assign x=data_in;
    FLOAT16_MUL U_X2(/*autoinst*/
        .floatA                 (x                              ), //input
        .floatB                 (x                              ), //input
        .product                (x2                             )  //output
    );
    
    FLOAT16_MUL U_X3(/*autoinst*/
        .floatA                 (x                              ), //input
        .floatB                 (x2                             ), //input
        .product                (x3                             )  //output
    );

    FLOAT16_MUL U_X4(/*autoinst*/
        .floatA                 (x                              ), //input
        .floatB                 (x3                             ), //input
        .product                (x4                             )  //output
    );

    FLOAT16_MUL U_X5(/*autoinst*/
        .floatA                 (x                              ), //input
        .floatB                 (x4                             ), //input
        .product                (x5                             )  //output
    );

    assign fact2=FACT2;
    FLOAT16_MUL U_X2_DIV_FACT2(/*autoinst*/
        .floatA                 (x2                             ), //input
        .floatB                 (fact2                          ), //input
        .product                (x2_div_fact2                   )  //output
    );

    assign fact3=FACT3;
    FLOAT16_MUL U_X3_DIV_FACT3(/*autoinst*/
        .floatA                 (x3                             ), //input
        .floatB                 (fact3                          ), //input
        .product                (x3_div_fact3                   )  //output
    );

    assign fact4=FACT4;
    FLOAT16_MUL U_X4_DIV_FACT4(/*autoinst*/
        .floatA                 (x4                             ), //input
        .floatB                 (fact4                          ), //input
        .product                (x4_div_fact4                   )  //output
    );

    assign fact5=FACT5;
    FLOAT16_MUL U_X5_DIV_FACT5(/*autoinst*/
        .floatA                 (x5                             ), //input
        .floatB                 (fact5                          ), //input
        .product                (x5_div_fact5                   )  //output
    );
    
    assign one = ONE;
    FLOAT16_ADD U_ADD_X1_FACT1(/*autoinst*/
        .floatA                 (one                            ), //input
        .floatB                 (x                              ), //input
        .sum                    (add_x1                         )  //output
    );

    FLOAT16_ADD U_ADD_X2_FACT1(/*autoinst*/
        .floatA                 (add_x1                         ), //input
        .floatB                 (x2_div_fact2                   ), //input
        .sum                    (add_x2                         )  //output
    );

    FLOAT16_ADD U_ADD_X3_FACT1(/*autoinst*/
        .floatA                 (add_x2                         ), //input
        .floatB                 (x3_div_fact3                   ), //input
        .sum                    (add_x3                         )  //output
    );

    FLOAT16_ADD U_ADD_X4_FACT1(/*autoinst*/
        .floatA                 (add_x3                         ), //input
        .floatB                 (x4_div_fact4                   ), //input
        .sum                    (add_x4                         )  //output
    );

    FLOAT16_ADD U_ADD_X5_FACT1(/*autoinst*/
        .floatA                 (add_x4                         ), //input
        .floatB                 (x5_div_fact5                   ), //input
        .sum                    (add_x5                         )  //output
    );
    
    assign out_vld = in_vld;
    assign exp = add_x5;
endmodule
//Local Variables:
//verilog-library-directories:("../IP/MATH_LIB")
//verilog-library-directories-recursive:1
//End:
