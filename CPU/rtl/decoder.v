// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:17
// Last Modified : 2024/05/16 23:11
// File Name     : decoder.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module DECODER#(
	parameter ADD = 4'd0,
	parameter SUB = 4'd1,
	parameter MUL = 4'd2,
	parameter DIV = 4'd3,
	parameter LDI = 4'd4,
	parameter BNE = 4'd5,
	parameter BEQ = 4'd6,
	parameter MOV = 4'd7,
	parameter NA  = 4'd15
)(
	input [3:0]         alu_flags     , 
	input [5:0]         cmd           , 

	output reg			pc_ctrl       , 
	output reg          write         , 
	output reg [2:0]    alu_bport_sel , 
	output reg          src_addr_sel  ,
	output reg          des_addr_sel  ,
	output reg [3:0]    func
);
    localparam  OP_NOP  = 6'b000000;  // 无操作
    localparam  OP_ADD  = 6'b000001;  // 加法操作
    localparam  OP_SUB  = 6'b000010;  // 减法操作
    localparam  OP_MUL  = 6'b000011;  // 乘法操作
	localparam  OP_DIV  = 6'b111111; 
    localparam  OP_ADDI = 6'b000100;  // 加立即数
    localparam  OP_LDI  = 6'b000101;  // 载入立即数到寄存器
    localparam  OP_LW   = 6'b000110;  // 从内存加载到寄存器
    localparam  OP_SW   = 6'b000111;  // 从寄存器存储到内存
    localparam  OP_BEQ  = 6'b001000;  // 分支如果等于
    localparam  OP_J    = 6'b001001;  // 跳转
	localparam  OP_BNE  = 6'b001010;  //
	localparam  OP_MOV  = 6'b001011;
	/*autodef*/

	always @(*)begin
		case(cmd)
			OP_ADD,OP_SUB,OP_MUL,OP_DIV,OP_ADDI,OP_LDI,OP_SW,OP_LW,OP_MOV:write = 1'b1;
			default :write = 1'b0;
		endcase
	end

	always @(*)begin
		case(cmd)
			OP_ADD,OP_SUB,OP_MUL,OP_DIV,OP_BEQ,OP_BNE,OP_MOV,OP_SW:alu_bport_sel= 3'd0;
			OP_LDI,OP_ADDI:alu_bport_sel = 3'd1;
			OP_LW :alu_bport_sel = 3'd2;
			default:alu_bport_sel = 3'd0;
		endcase
	end

	always @(*)begin
		case(cmd)
			OP_ADD:func = ADD;
            OP_ADDI:func= ADD;
			OP_SUB:func = SUB;
			OP_MUL:func = MUL;
			OP_DIV:func = DIV;
			OP_LDI:func = LDI;
			OP_BNE:func = BNE;
			OP_BEQ:func = BEQ;
			OP_LW :func = LDI;
			OP_MOV:func = MOV;
			OP_SW :func = LDI;
			default:func= NA;
		endcase
	end

	always @(*)begin
		case(cmd)
			OP_NOP:pc_ctrl = 1'd0;
			OP_J  :pc_ctrl = 1'd1;
			OP_BNE,OP_BEQ:begin
				if(alu_flags == 4'd1)begin
					pc_ctrl = 1'd0;//program address add 1
				end
				else begin
					pc_ctrl = 1'd1;//program address jumped to a address that we refer
				end
			end
			default:pc_ctrl = 1'd0;
		endcase
	end

	always @(*)begin
		case(cmd)
			OP_ADD:src_addr_sel = 1'b1;
			OP_SUB:src_addr_sel = 1'b1;
			OP_MUL:src_addr_sel = 1'b1;
			OP_DIV:src_addr_sel = 1'b1;
			default:src_addr_sel = 1'b0;
		endcase
	end
	
	always @(*)begin
		case(cmd)
			OP_ADD:des_addr_sel = 1'b1;
			OP_SUB:des_addr_sel = 1'b1;
			OP_MUL:des_addr_sel = 1'b1;
			OP_DIV:des_addr_sel = 1'b1;
			OP_ADDI:des_addr_sel= 1'b1;
			default:des_addr_sel = 1'b0;
		endcase
	end
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
