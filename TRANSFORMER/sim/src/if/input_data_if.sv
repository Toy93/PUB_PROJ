// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : muchen_fpga@qq.com
// Website       : QQ:2300930602
// Created On    : 2024/06/10 11:28
// Last Modified : 2024/06/15 18:53
// File Name     : input_data_if.sv
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/10   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
interface input_data_if#(
	parameter DATA_WIDTH = 16,
	parameter HEADER_NUM = 8 ,
	parameter DATA_NUM   = 4 
)();
	logic                           x_ren        ;
    logic                           x_cs         ;
    logic [12:0]                    x_rd_addr    ;
    logic [HEADER_NUM-1:0]          wq_ren       ;
    logic [HEADER_NUM-1:0]          wq_cs        ;
    logic [HEADER_NUM*11-1:0]       wq_rd_addr   ;
    logic [HEADER_NUM-1:0]          wk_ren       ;
    logic [HEADER_NUM-1:0]          wk_cs        ;
    logic [HEADER_NUM*11-1:0]       wk_rd_addr   ;
    logic [HEADER_NUM-1:0]          wv_ren       ;
    logic [HEADER_NUM-1:0]          wv_cs        ;
    logic [HEADER_NUM*11-1:0]       wv_rd_addr   ;
	logic							x_ok         ;
	logic [HEADER_NUM-1:0]			wq_ok        ;
	logic [HEADER_NUM-1:0]			wk_ok        ;
	logic [HEADER_NUM-1:0]			wv_ok        ;
	logic [DATA_NUM*DATA_WIDTH-1:0] x      ; 
	logic [HEADER_NUM*8*DATA_WIDTH-1:0] wq ; 
	logic [HEADER_NUM*8*DATA_WIDTH-1:0] wk ; 
	logic [HEADER_NUM*8*DATA_WIDTH-1:0] wv ; 
	logic [HEADER_NUM*16-1:0] wq_bit_map ; 
	logic [HEADER_NUM*16-1:0] wk_bit_map ; 
	logic [HEADER_NUM*16-1:0] wv_bit_map ;
endinterface

