/*************************************************************************
    # File Name: cpu_define.sv
    # Author: Mu Chen
    # Mail: yqs_ahut@163.com
    # QQ: 3221153405
    # Created Time: 2024年03月23日 星期六 20时56分39秒
*************************************************************************/
`define DUT_TOP_NAME(str) cpu_``str
`define DUT_TOP_NAME_STR(str) `"cpu_``str`"
`define DEBUG
`define SIM
`define OP_NOP  6'b000000
`define OP_ADD  6'b000001
`define OP_SUB  6'b000010
`define OP_MUL  6'b000011
`define OP_DIV  6'b111111
`define OP_ADDI 6'b000100
`define OP_LDI  6'b000101
`define OP_LW   6'b000110
`define OP_SW   6'b000111
`define OP_BEQ  6'b001000
`define OP_J    6'b001001
`define OP_BNE  6'b001010
`define OP_MOV  6'b001011
