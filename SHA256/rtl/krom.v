// +FHDR----------------------------------------------------------------------------
// Project Name  : IC_Design
// Author        : MuChen©
// Email         : yqs_ahut@163.com
// Website       : QQ:3221153405
// Created On    : 2024/06/03 07:40
// Last Modified : 2024/07/18 22:16
// File Name     : krom.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/06/03   MuChen©        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module KROM(
	input [3:0]addr,
	output reg [31:0]k0,
	output reg [31:0]k1,
	output reg [31:0]k2,
	output reg [31:0]k3,
	output reg [31:0]k4,
	output reg [31:0]k5,
	output reg [31:0]k6,
	output reg [31:0]k7
);
//PARAMETER DEFINE
//---------------------------------------------------------------------------------head
	parameter K0  = 32'h428a2f98;
	parameter K1  = 32'h71374491;
	parameter K2  = 32'hb5c0fbcf;
	parameter K3  = 32'he9b5dba5;
	parameter K4  = 32'h3956c25b;
	parameter K5  = 32'h59f111f1;
	parameter K6  = 32'h923f82a4;
	parameter K7  = 32'hab1c5ed5;
	parameter K8  = 32'hd807aa98;
	parameter K9  = 32'h12835b01;
	parameter K10 = 32'h243185be;
	parameter K11 = 32'h550c7dc3;
	parameter K12 = 32'h72be5d74;
	parameter K13 = 32'h80deb1fe;
	parameter K14 = 32'h9bdc06a7;
	parameter K15 = 32'hc19bf174;
	parameter K16 = 32'he49b69c1;
	parameter K17 = 32'hefbe4786;
	parameter K18 = 32'h0fc19dc6;
	parameter K19 = 32'h240ca1cc;
	parameter K20 = 32'h2de92c6f;
	parameter K21 = 32'h4a7484aa;
	parameter K22 = 32'h5cb0a9dc;
	parameter K23 = 32'h76f988da;
	parameter K24 = 32'h983e5152;
	parameter K25 = 32'ha831c66d;
	parameter K26 = 32'hb00327c8;
	parameter K27 = 32'hbf597fc7;
	parameter K28 = 32'hc6e00bf3;
	parameter K29 = 32'hd5a79147;
	parameter K30 = 32'h06ca6351;
	parameter K31 = 32'h14292967;
	parameter K32 = 32'h27b70a85;
	parameter K33 = 32'h2e1b2138;
	parameter K34 = 32'h4d2c6dfc;
	parameter K35 = 32'h53380d13;
	parameter K36 = 32'h650a7354;
	parameter K37 = 32'h766a0abb;
	parameter K38 = 32'h81c2c92e;
	parameter K39 = 32'h92722c85;
	parameter K40 = 32'ha2bfe8a1;
	parameter K41 = 32'ha81a664b;
	parameter K42 = 32'hc24b8b70;
	parameter K43 = 32'hc76c51a3;
	parameter K44 = 32'hd192e819;
	parameter K45 = 32'hd6990624;
	parameter K46 = 32'hf40e3585;
	parameter K47 = 32'h106aa070;
	parameter K48 = 32'h19a4c116;
	parameter K49 = 32'h1e376c08;
	parameter K50 = 32'h2748774c;
	parameter K51 = 32'h34b0bcb5;
	parameter K52 = 32'h391c0cb3;
	parameter K53 = 32'h4ed8aa4a;
	parameter K54 = 32'h5b9cca4f;
	parameter K55 = 32'h682e6ff3;
	parameter K56 = 32'h748f82ee;
	parameter K57 = 32'h78a5636f;
	parameter K58 = 32'h84c87814;
	parameter K59 = 32'h8cc70208;
	parameter K60 = 32'h90befffa;
	parameter K61 = 32'ha4506ceb;
	parameter K62 = 32'hbef9a3f7;
	parameter K63 = 32'hc67178f2;
//---------------------------------------------------------------------------------tail

/*autowire*/
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

/*autoreg*/
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//WIRE DEFINE
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//REG DEFINE
//---------------------------------------------------------------------------------head
//---------------------------------------------------------------------------------tail

//main code
//---------------------------------------------------------------------------------head
	always@(*)begin
		case(addr)
			0       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K7,K6,K5,K4,K3,K2,K1,K0        } ;
			1       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K15,K14,K13,K12,K11,K10,K9,K8  } ;
			2       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K23,K22,K21,K20,K19,K18,K17,K16} ;
			3       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K31,K30,K29,K28,K27,K26,K25,K24} ;
			4       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K39,K38,K37,K36,K35,K34,K33,K32} ;
			5       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K47,K46,K45,K44,K43,K42,K41,K40} ;
			6       : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K55,K54,K53,K52,K51,K50,K49,K48} ;
			default : {k7, k6, k5, k4, k3 , k2 , k1 , k0 } = {K63,K62,K61,K60,K59,K58,K57,K56} ;//7
		endcase
	end
//---------------------------------------------------------------------------------tail
endmodule
//Local Variables:
//verilog-library-directories:()
//verilog-library-directories-recursive:1
//End:
