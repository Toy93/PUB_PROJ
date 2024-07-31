// +FHDR----------------------------------------------------------------------------
// Project Name  : TRANSFORMER
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/03/31 17:06
// Last Modified : 2024/06/19 23:29
// File Name     : add.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/03/31   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module ADD#(
	parameter INFO_WIDTH = 23
)(
	input [INFO_WIDTH-1:0]    info_in  , 
	input [15:0]			  data0    , 
	input [15:0]    		  data1    , 
	input           		  in_vld   , 
    
	output					  out_vld  , 
	output [INFO_WIDTH-1:0]   info_out , 
	output [15:0]			  sum      
);
	
	FLOAT16_ADD U_FLOAT16_ADD(/*autoinst*/
        .floatA                 (data0    ), //input
        .floatB                 (data1    ), //input
        .sum                    (sum[15:0])  //output
    );

	assign out_vld = in_vld;
	assign info_out = info_in;
endmodule
