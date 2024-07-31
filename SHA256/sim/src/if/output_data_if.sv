// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/10 11:30
// Last Modified : 2024/06/13 23:18
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
interface output_data_if();
	logic			dout_vld;
    logic [255:0]	dout    ;

	//CRYPTO_HASHBLOCKS_SHA256_ME
	logic		 me_sha256_dout_vld;
	logic [255:0]me_sha256_statebytes_o;
	//assign		 me_sha256_dout_vld = testbench.U_CRYPTO_SIGN.CRYPTO_HASHBLOCKS_SHA256_ME.dout_vld;
	//assign       me_sha256_statebytes_o = testbench.U_CRYPTO_SIGN.CRYPTO_HASHBLOCKS_SHA256_ME.statebytes_o[255:0];

	//CRYPTO_HASHBLOCKS_SHA256_ME
	logic		 sha256_dout_vld;
	logic [255:0]sha256_statebytes_o;
	//assign       sha256_dout_vld     = testbench.U_CRYPTO_SIGN.sha256_core.dout_vld;
	//assign		 sha256_statebytes_o = testbench.U_CRYPTO_SIGN.sha256_core.dout[255:0];
endinterface

