/*************************************************************************
    # File Name: dblmix.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:31:51 AM EDT
    # Last Modified:2022-04-16 09:58
    # Update Count:11
*************************************************************************/
module DBLMIX#(
	parameter PASSWD_LEN = 80,
	parameter BLOCK_SIZE = 256	
)(
	input clk							,
	input rst_n							,	

//interface with JS_FST_KDF0
	input						in_vld	,
	output						in_rdy	,
	input	[BLOCK_SIZE*8 - 1:0]x_in	,
	input   [PASSWD_LEN*8 - 1:0]password,
	
//interface withJS_XOR
	output	[BLOCK_SIZE*8 - 1:0]x_out	,
	output	[BLOCK_SIZE*8 - 1:0]z_out	,
	output						out_vld	,
	input						out_rdy ,	
	output  [PASSWD_LEN*8 - 1:0]password_o
);

//parameter define
localparam AWIDTH = 7;
localparam NBPIPE = 3;
localparam DWIDTH = BLOCK_SIZE*8;

wire					write_out_vld	;	
wire		    		write_out_rdy	;	
wire[BLOCK_SIZE*8 -1:0]	write_x_out		;		
wire[BLOCK_SIZE*8 -1:0]	write_z_out		;		
wire					write_in_vld	;	
wire	        		write_in_rdy	;	
wire[BLOCK_SIZE*8 -1:0]	write_x_in		;		
wire[BLOCK_SIZE*8 -1:0]	write_z_in		;		

wire					read_out_vld	;	
wire		    		read_out_rdy	;	
wire[BLOCK_SIZE*8 -1:0]	read_x_out		;		
wire[BLOCK_SIZE*8 -1:0]	read_z_out		;		
wire					read_in_vld		;		
wire					read_in_rdy		;		
wire[BLOCK_SIZE*8 -1:0]	read_x_in		;		
wire[BLOCK_SIZE*8 -1:0]	read_z_in		;		

wire					v0_pi_wea		;	
wire            		v0_pi_regceb	;	
wire            		v0_pi_mem_en	;	
wire[DWIDTH -1:0]		v0_pi_dina		;	
wire[AWIDTH -1:0]		v0_pi_addra		;	
wire[AWIDTH -1:0]		v0_pi_addrb		;	
wire[DWIDTH -1:0]		v0_pi_doutb		;	

wire					v1_pi_wea		;	
wire            		v1_pi_regceb	;	
wire            		v1_pi_mem_en	;	
wire[DWIDTH -1:0]		v1_pi_dina		;	
wire[AWIDTH -1:0]		v1_pi_addra		;	
wire[AWIDTH -1:0]		v1_pi_addrb		;	
wire[DWIDTH -1:0]		v1_pi_doutb		;	

wire					v0_pa_wea		;	
wire          			v0_pa_regceb	;	
wire          			v0_pa_mem_en	;	
wire[DWIDTH -1:0]		v0_pa_dina		;	
wire[AWIDTH -1:0]		v0_pa_addra		;	
wire[AWIDTH -1:0]		v0_pa_addrb		;	
wire[DWIDTH -1:0]		v0_pa_doutb		;	

wire					v1_pa_wea		;	
wire       		    	v1_pa_regceb	;	
wire       		    	v1_pa_mem_en	;	
wire[DWIDTH -1:0]		v1_pa_dina		;	
wire[AWIDTH -1:0]		v1_pa_addra		;	
wire[AWIDTH -1:0]		v1_pa_addrb		;	
wire[DWIDTH -1:0]		v1_pa_doutb		;	
//instant module
DBLMIX_CTRL#(
	.BLOCK_SIZE (BLOCK_SIZE),
	.AWIDTH		(AWIDTH	   ),
	.NBPIPE     (NBPIPE    )
)U_DBLMIX_CTRL(
	.clk			(clk  ),		
	.rst_n			(rst_n),	

//interface with JS_FST_KDF	
	.in_vld			(in_vld	),
	.in_rdy			(in_rdy	),
	.x_in			(x_in	),			
	.z_in			(x_in	),
	.password		(password),
                        
//interface with DBLMIX_WRITE	
	.write_out_vld	(write_out_vld	),	
	.write_out_rdy	(write_out_rdy	),	
	.write_x_out	(write_x_out	),		
	.write_z_out	(write_z_out	),		
	.write_in_vld	(write_in_vld	),	
	.write_in_rdy	(write_in_rdy	),	
	.write_x_in		(write_x_in		),		
	.write_z_in		(write_z_in		),		
                        
//interface with DBLMIX_READ 
	.read_out_vld	(read_out_vld	),	
	.read_out_rdy	(read_out_rdy	),	
	.read_x_out		(read_x_out		),		
	.read_z_out		(read_z_out		),		
	.read_in_vld	(read_in_vld	),		
	.read_in_rdy	(read_in_rdy	),		
	.read_x_in		(read_x_in		),		
	.read_z_in		(read_z_in		),		
                        
//interface with SRAM_V0_PING
	.v0_pi_wea		(v0_pi_wea		),	
	.v0_pi_regceb	(v0_pi_regceb	),	
	.v0_pi_mem_en	(v0_pi_mem_en	),	
	.v0_pi_dina		(v0_pi_dina		),	
	.v0_pi_addra	(v0_pi_addra	),	
	.v0_pi_addrb	(v0_pi_addrb	),	
	.v0_pi_doutb	(v0_pi_doutb	),	
                        
//interface with SRAM_V1_PING
	.v1_pi_wea		(v1_pi_wea		),	
	.v1_pi_regceb	(v1_pi_regceb	),	
	.v1_pi_mem_en	(v1_pi_mem_en	),	
	.v1_pi_dina		(v1_pi_dina		),	
	.v1_pi_addra	(v1_pi_addra	),	
	.v1_pi_addrb	(v1_pi_addrb	),	
	.v1_pi_doutb	(v1_pi_doutb	),	
	                    		
//interface with SRAM_V0_PANG 
	.v0_pa_wea		(v0_pa_wea		),	
	.v0_pa_regceb	(v0_pa_regceb	),	
	.v0_pa_mem_en	(v0_pa_mem_en	),	
	.v0_pa_dina		(v0_pa_dina		),	
	.v0_pa_addra	(v0_pa_addra	),	
	.v0_pa_addrb	(v0_pa_addrb	),	
	.v0_pa_doutb	(v0_pa_doutb	),	
	                    		
//interface with SRAM_V1_PANG 
	.v1_pa_wea		(v1_pa_wea		),	
	.v1_pa_regceb	(v1_pa_regceb	),	
	.v1_pa_mem_en	(v1_pa_mem_en	),	
	.v1_pa_dina		(v1_pa_dina		),	
	.v1_pa_addra	(v1_pa_addra	),	
	.v1_pa_addrb	(v1_pa_addrb	),	
	.v1_pa_doutb	(v1_pa_doutb	),	
	                    			
//interface with JS_XOR
	.x_out		(x_out	),	
	.z_out		(z_out	),	
	.out_vld	(out_vld),
	.out_rdy	(out_rdy),
	.password_o	(password_o)
);

DBLMIX_CALC#(
	.BLOCK_SIZE(BLOCK_SIZE)
)DBLMIX_WRITE(
	.clk	(clk  ),		
	.rst_n	(rst_n),	

	//interface with BLK2S_CTRL
	.in_vld	(write_out_vld	),	
	.in_rdy	(write_out_rdy	),	
	.x_in	(write_x_out	),	
	.z_in	(write_z_out	),	
	.out_vld(write_in_vld	),	
	.out_rdy(write_in_rdy	),	
	.x_out	(write_x_in		),	
	.z_out	(write_z_in		)	
);

DBLMIX_CALC#(
	.BLOCK_SIZE(BLOCK_SIZE)
)DBLMIX_READ(
	.clk	(clk  ),		
	.rst_n	(rst_n),	

	//interface with BLK2S_CTRL
	.in_vld	(read_out_vld	),	
	.in_rdy	(read_out_rdy	),	
	.x_in	(read_x_out		),	
	.z_in	(read_z_out		),	
	.out_vld(read_in_vld	),	
	.out_rdy(read_in_rdy	),	
	.x_out	(read_x_in		),	
	.z_out	(read_z_in		)	
);

ULTRA_SRAM#(
	.AWIDTH (AWIDTH),  // Address Width
	.DWIDTH (DWIDTH),  // Data Width
	.NBPIPE (NBPIPE)  // Number of pipeline Registers
)SRAM_V0_PING(
	.clk	(clk         ),// Clock 
	.rstb	(rst_n       ),// Reset
	.wea	(v0_pi_wea	 ),// Write Enable
	.regceb	(v0_pi_regceb),// Output Register Enable
	.mem_en	(v0_pi_mem_en),// Memory Enable
	.dina	(v0_pi_dina	 ),// Data <wire_or_reg>  
	.addra	(v0_pi_addra ),// Write Address
	.addrb	(v0_pi_addrb ),// Read  Address
	.doutb	(v0_pi_doutb ) // Data Output
);

ULTRA_SRAM#(
	.AWIDTH (AWIDTH),  // Address Width
	.DWIDTH (DWIDTH),  // Data Width
	.NBPIPE (NBPIPE)  // Number of pipeline Registers
)SRAM_V1_PING(
	.clk	(clk         ),// Clock 
	.rstb	(rst_n       ),// Reset
	.wea	(v1_pi_wea	 ),// Write Enable
	.regceb	(v1_pi_regceb),// Output Register Enable
	.mem_en	(v1_pi_mem_en),// Memory Enable
	.dina	(v1_pi_dina	 ),// Data <wire_or_reg>  
	.addra	(v1_pi_addra ),// Write Address
	.addrb	(v1_pi_addrb ),// Read  Address
	.doutb	(v1_pi_doutb ) // Data Output
);

ULTRA_SRAM#(
	.AWIDTH (AWIDTH),  // Address Width
	.DWIDTH (DWIDTH),  // Data Width
	.NBPIPE (NBPIPE)  // Number of pipeline Registers
)SRAM_V0_PANG(
	.clk	(clk         ),// Clock 
	.rstb	(rst_n       ),// Reset
	.wea	(v0_pa_wea	 ),// Write Enable
	.regceb	(v0_pa_regceb),// Output Register Enable
	.mem_en	(v0_pa_mem_en),// Memory Enable
	.dina	(v0_pa_dina	 ),// Data <wire_or_reg>  
	.addra	(v0_pa_addra ),// Write Address
	.addrb	(v0_pa_addrb ),// Read  Address
	.doutb	(v0_pa_doutb ) // Data Output
);

ULTRA_SRAM#(
	.AWIDTH (AWIDTH),  // Address Width
	.DWIDTH (DWIDTH),  // Data Width
	.NBPIPE (NBPIPE)  // Number of pipeline Registers
)SRAM_V1_PANG(
	.clk	(clk         ),// Clock 
	.rstb	(rst_n       ),// Reset
	.wea	(v1_pa_wea	 ),// Write Enable
	.regceb	(v1_pa_regceb),// Output Register Enable
	.mem_en	(v1_pa_mem_en),// Memory Enable
	.dina	(v1_pa_dina	 ),// Data <wire_or_reg>  
	.addra	(v1_pa_addra ),// Write Address
	.addrb	(v1_pa_addrb ),// Read  Address
	.doutb	(v1_pa_doutb ) // Data Output
);
endmodule
