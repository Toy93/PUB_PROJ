// +FHDR----------------------------------------------------------------------------
// Project Name  : TRANSFORMER
// Author        : MuChen
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/03/31 17:06
// Last Modified : 2024/04/14 15:53
// File Name     : mul.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/03/31   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module MUL(
	input		clk      , 
	input		rst_n	 ,
	input		vld_in   , 
	input [22:0]info_in  ,
	input [15:0]data0    ,
	input [15:0]data1    ,

	output reg  vld_out  , 
	output reg [23:0]info_out,
	output reg [15:0]mul
);

	wire [15:0]mul_result;
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            vld_out <= 1'd0;
        end
        else begin
            vld_out <= vld_in;
        end
    end
    
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
            info_out <= 'd0;
		end
		else if(vld_in)begin
            info_out <= info_in;
		end
		else begin
            info_out <= 'd0;
		end
	end
	
	FLOAT16_MUL U_X3_DIV_FACT3(/*autoinst*/
        .floatA                 (data0       ),
        .floatB                 (data1       ),
        .product                (mul_result  ) 
    );

    always@(posedge clk)begin
        if(vld_in)begin
            mul <= mul_result;
        end
	end

endmodule
