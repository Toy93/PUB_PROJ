// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/04/14 17:03
// Last Modified : 2024/05/16 21:29
// File Name     : pico_mips.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/04/14   MuChen          1.0                     Original
// -FHDR----------------------------------------------------------------------------
module PICO_MIPS(
	input clk,
	input rst_n,
	input [8:0]sw,

	output [7:0]led 
);
	/*parameter*/
	localparam ADD = 4'd0;
	localparam SUB = 4'd1;
	localparam MUL = 4'd2;
	localparam DIV = 4'd3;
	localparam LDI = 4'd4;
	localparam BNE = 4'd5;
	localparam BEQ = 4'd6;
	localparam MOV = 4'd7;
	localparam NA  = 4'd15;

	/*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    wire [7:0]                  immediate                       ;
    //Define instance wires here
    wire [7:0]                  addr_n                          ;
    wire [7:0]                  cmd_addr                        ;
    wire [23:0]                 cmd                             ;
    wire [3:0]                  alu_flags                       ;
    wire [5:0]                  op_code                         ;
    wire                        pc_ctrl                         ;
    wire                        write                           ;
    wire [2:0]                  alu_bport_sel                   ;
    wire                        src_addr_sel                    ;
    wire                        des_addr_sel                    ;
    wire [3:0]                  func                            ;
    wire [4:0]                  wd                              ;
    wire [4:0]                  des_addr                        ;
    wire [4:0]                  src_addr                        ;
    wire [7:0]                  wdata                           ;
    wire [7:0]                  rd_data                         ;
    wire [7:0]                  rs_data                         ;
    wire [7:0]                  b                               ;
    //End of automatic wire
    //End of automatic define
	
	PC U_PC(/*autoinst*/
        .clk                    (clk                            ), //input
        .rst_n                  (rst_n                          ), //input
        .addr_n                 (addr_n[7:0]                    ), //input
        .addr_c                 (cmd_addr[7:0]                  )  //output
    );
	
	assign addr_n = pc_ctrl == 1'd0 ? cmd_addr+1'b1 :immediate;

	PROGRAM_MEMORY U_PROGRAM_MEMORY(/*autoinst*/
        .clk                    (clk                            ), //input
        .rst_n                  (rst_n                          ), //input
        .cmd_addr               (cmd_addr[7:0]                  ), //input
        .cmd                    (cmd[23:0]                      )  //output
    );

	assign op_code = cmd[23:18];
	assign wd = cmd[17:13];
	assign des_addr= des_addr_sel == 1'b0 ? cmd[17:13] : cmd[12:8];
	assign src_addr= src_addr_sel == 1'b0 ? cmd[12:8]  : cmd[4:0];
	assign immediate = cmd[7:0];
	
	DECODER #(/*autoinstparam*/
        .ADD                    (ADD                            ),
        .SUB                    (SUB                            ),
        .MUL                    (MUL                            ),
        .DIV                    (DIV                            ),
        .LDI                    (LDI                            ),
        .BNE                    (BNE                            ),
        .BEQ                    (BEQ                            ),
        .MOV                    (MOV                            ), // PARA_NEW
        .NA                     (NA                             )  // PARA_NEW
    )
    U_DECODER(/*autoinst*/
        .alu_flags              (alu_flags[3:0]                 ), //input
        .cmd                    (op_code                        ), //input
        .pc_ctrl                (pc_ctrl                        ), //output
        .write                  (write                          ), //output
        .alu_bport_sel          (alu_bport_sel[2:0]             ), //output
        .src_addr_sel           (src_addr_sel                   ), //output
        .des_addr_sel           (des_addr_sel                   ), //output
        .func                   (func[3:0]                      )  //output
    );

	REGS U_REGS(/*autoinst*/
        .clk                    (clk                            ), //input
        .rst_n                  (rst_n                          ), //input
        .write                  (write                          ), //input
        .wd                     (wd[4:0]                        ), //input
        .rd                     (des_addr                       ), //input
        .rs                     (src_addr                       ), //input
        .wdata                  (wdata[7:0]                     ), //input
        .rd_data                (rd_data[7:0]                   ), //output
        .rs_data                (rs_data[7:0]                   ), //output
        .led                    (led[7:0]                       )  //output
    );
	
	assign b = alu_bport_sel == 3'd0 ? rs_data :
			alu_bport_sel == 3'd1 ? immediate :
			alu_bport_sel == 3'd2&& immediate == 8'd2 ? {7'd0,sw[8]} :
			alu_bport_sel == 3'd2&& immediate == 8'd1 ? sw[7:0] : rs_data;
	
	ALU #(/*autoinstparam*/
        .ADD                    (ADD                            ),
        .SUB                    (SUB                            ),
        .MUL                    (MUL                            ),
        .DIV                    (DIV                            ),
        .LDI                    (LDI                            ),
        .BNE                    (BNE                            ),
        .BEQ                    (BEQ                            ),
        .MOV                    (MOV                            ), // PARA_NEW
        .NA                     (NA                             )  // PARA_NEW
    )
    U_ALU(/*autoinst*/
        .func                   (func[3:0]                      ), //input
        .a                      (rd_data[7:0]                   ), //input
        .b                      (b[7:0]                         ), //input
        .alu_flags              (alu_flags[3:0]                 ), //output
        .result                 (wdata[7:0]                     )  //output
    );
	
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
