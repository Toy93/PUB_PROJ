// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/06/10 11:27
// Last Modified : 2024/06/15 18:54
// File Name     : output_data_if.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
interface output_data_if#(
	parameter DATA_WIDTH = 16
)();
	logic                           attention_vld; // WIRE_NEW
    logic [64*64*DATA_WIDTH-1:0]    attention0   ;
    logic [64*64*DATA_WIDTH-1:0]    attention1   ;
    logic [64*64*DATA_WIDTH-1:0]    attention2   ;
    logic [64*64*DATA_WIDTH-1:0]    attention3   ;
    logic [64*64*DATA_WIDTH-1:0]    attention4   ;
    logic [64*64*DATA_WIDTH-1:0]    attention5   ;
    logic [64*64*DATA_WIDTH-1:0]    attention6   ;
    logic [64*64*DATA_WIDTH-1:0]    attention7   ;
endinterface

