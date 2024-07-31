/*************************************************************************
    # File Name: out_calc.v
    # Author: Qingsong Yang
    # Mail: yqs_ahut@163.com
    # Created Time: Wed 23 Mar 2022 10:31:25 AM EDT
    # Last Modified:2022-04-16 09:56
    # Update Count:30
*************************************************************************/
module OUT_CALC#(
	parameter PASSWD_LEN	= 80,
	parameter KDF_BUF_SIZE	= 256,
	parameter INPUT_SIZE	= 64,
	parameter KEY_SIZE		= 32,
	parameter OUTPUT_LEN	= 256
)(
	input									clk			,
	input									rst_n		,

	//interface with BLK2S_CALC_ALL
	input									in_vld		,
	output									in_rdy		,
	input [(KDF_BUF_SIZE+INPUT_SIZE)*8 -1:0]a_in		,
	input [(KDF_BUF_SIZE+KEY_SIZE)*8 - 1:0]	b_in		,
	input [7:0]								buf_ptr_in  ,
	input [PASSWD_LEN*8 - 1:0]				password  ,

	//interface with DBL_MIX0 and DBL_MIX1
	output reg								out_vld,
	input									out_rdy,
	output reg[OUTPUT_LEN*8 - 1:0]			xo,
	output reg[PASSWD_LEN*8 - 1:0]			password_o
);
generate 
	if(OUTPUT_LEN == 256)begin
		always @(posedge clk)begin
			if(in_vld&in_rdy)begin
				case(buf_ptr_in)
					  0:xo <= a_in[0+:2048]^b_in[0+:2048];
					  1:xo <= {a_in[2040+:8]^b_in[0+:8],a_in[0+:2040]^b_in[8+:2040]};
					  2:xo <= {a_in[2032+:16]^b_in[0+:16],a_in[0+:2032]^b_in[16+:2032]};
					  3:xo <= {a_in[2024+:24]^b_in[0+:24],a_in[0+:2024]^b_in[24+:2024]};
					  4:xo <= {a_in[2016+:32]^b_in[0+:32],a_in[0+:2016]^b_in[32+:2016]};
					  5:xo <= {a_in[2008+:40]^b_in[0+:40],a_in[0+:2008]^b_in[40+:2008]};
					  6:xo <= {a_in[2000+:48]^b_in[0+:48],a_in[0+:2000]^b_in[48+:2000]};
					  7:xo <= {a_in[1992+:56]^b_in[0+:56],a_in[0+:1992]^b_in[56+:1992]};
					  8:xo <= {a_in[1984+:64]^b_in[0+:64],a_in[0+:1984]^b_in[64+:1984]};
					  9:xo <= {a_in[1976+:72]^b_in[0+:72],a_in[0+:1976]^b_in[72+:1976]};
					 10:xo <= {a_in[1968+:80]^b_in[0+:80],a_in[0+:1968]^b_in[80+:1968]};
					 11:xo <= {a_in[1960+:88]^b_in[0+:88],a_in[0+:1960]^b_in[88+:1960]};
					 12:xo <= {a_in[1952+:96]^b_in[0+:96],a_in[0+:1952]^b_in[96+:1952]};
					 13:xo <= {a_in[1944+:104]^b_in[0+:104],a_in[0+:1944]^b_in[104+:1944]};
					 14:xo <= {a_in[1936+:112]^b_in[0+:112],a_in[0+:1936]^b_in[112+:1936]};
					 15:xo <= {a_in[1928+:120]^b_in[0+:120],a_in[0+:1928]^b_in[120+:1928]};
					 16:xo <= {a_in[1920+:128]^b_in[0+:128],a_in[0+:1920]^b_in[128+:1920]};
					 17:xo <= {a_in[1912+:136]^b_in[0+:136],a_in[0+:1912]^b_in[136+:1912]};
					 18:xo <= {a_in[1904+:144]^b_in[0+:144],a_in[0+:1904]^b_in[144+:1904]};
					 19:xo <= {a_in[1896+:152]^b_in[0+:152],a_in[0+:1896]^b_in[152+:1896]};
					 20:xo <= {a_in[1888+:160]^b_in[0+:160],a_in[0+:1888]^b_in[160+:1888]};
					 21:xo <= {a_in[1880+:168]^b_in[0+:168],a_in[0+:1880]^b_in[168+:1880]};
					 22:xo <= {a_in[1872+:176]^b_in[0+:176],a_in[0+:1872]^b_in[176+:1872]};
					 23:xo <= {a_in[1864+:184]^b_in[0+:184],a_in[0+:1864]^b_in[184+:1864]};
					 24:xo <= {a_in[1856+:192]^b_in[0+:192],a_in[0+:1856]^b_in[192+:1856]};
					 25:xo <= {a_in[1848+:200]^b_in[0+:200],a_in[0+:1848]^b_in[200+:1848]};
					 26:xo <= {a_in[1840+:208]^b_in[0+:208],a_in[0+:1840]^b_in[208+:1840]};
					 27:xo <= {a_in[1832+:216]^b_in[0+:216],a_in[0+:1832]^b_in[216+:1832]};
					 28:xo <= {a_in[1824+:224]^b_in[0+:224],a_in[0+:1824]^b_in[224+:1824]};
					 29:xo <= {a_in[1816+:232]^b_in[0+:232],a_in[0+:1816]^b_in[232+:1816]};
					 30:xo <= {a_in[1808+:240]^b_in[0+:240],a_in[0+:1808]^b_in[240+:1808]};
					 31:xo <= {a_in[1800+:248]^b_in[0+:248],a_in[0+:1800]^b_in[248+:1800]};
					 32:xo <= {a_in[1792+:256]^b_in[0+:256],a_in[0+:1792]^b_in[256+:1792]};
					 33:xo <= {a_in[1784+:264]^b_in[0+:264],a_in[0+:1784]^b_in[264+:1784]};
					 34:xo <= {a_in[1776+:272]^b_in[0+:272],a_in[0+:1776]^b_in[272+:1776]};
					 35:xo <= {a_in[1768+:280]^b_in[0+:280],a_in[0+:1768]^b_in[280+:1768]};
					 36:xo <= {a_in[1760+:288]^b_in[0+:288],a_in[0+:1760]^b_in[288+:1760]};
					 37:xo <= {a_in[1752+:296]^b_in[0+:296],a_in[0+:1752]^b_in[296+:1752]};
					 38:xo <= {a_in[1744+:304]^b_in[0+:304],a_in[0+:1744]^b_in[304+:1744]};
					 39:xo <= {a_in[1736+:312]^b_in[0+:312],a_in[0+:1736]^b_in[312+:1736]};
					 40:xo <= {a_in[1728+:320]^b_in[0+:320],a_in[0+:1728]^b_in[320+:1728]};
					 41:xo <= {a_in[1720+:328]^b_in[0+:328],a_in[0+:1720]^b_in[328+:1720]};
					 42:xo <= {a_in[1712+:336]^b_in[0+:336],a_in[0+:1712]^b_in[336+:1712]};
					 43:xo <= {a_in[1704+:344]^b_in[0+:344],a_in[0+:1704]^b_in[344+:1704]};
					 44:xo <= {a_in[1696+:352]^b_in[0+:352],a_in[0+:1696]^b_in[352+:1696]};
					 45:xo <= {a_in[1688+:360]^b_in[0+:360],a_in[0+:1688]^b_in[360+:1688]};
					 46:xo <= {a_in[1680+:368]^b_in[0+:368],a_in[0+:1680]^b_in[368+:1680]};
					 47:xo <= {a_in[1672+:376]^b_in[0+:376],a_in[0+:1672]^b_in[376+:1672]};
					 48:xo <= {a_in[1664+:384]^b_in[0+:384],a_in[0+:1664]^b_in[384+:1664]};
					 49:xo <= {a_in[1656+:392]^b_in[0+:392],a_in[0+:1656]^b_in[392+:1656]};
					 50:xo <= {a_in[1648+:400]^b_in[0+:400],a_in[0+:1648]^b_in[400+:1648]};
					 51:xo <= {a_in[1640+:408]^b_in[0+:408],a_in[0+:1640]^b_in[408+:1640]};
					 52:xo <= {a_in[1632+:416]^b_in[0+:416],a_in[0+:1632]^b_in[416+:1632]};
					 53:xo <= {a_in[1624+:424]^b_in[0+:424],a_in[0+:1624]^b_in[424+:1624]};
					 54:xo <= {a_in[1616+:432]^b_in[0+:432],a_in[0+:1616]^b_in[432+:1616]};
					 55:xo <= {a_in[1608+:440]^b_in[0+:440],a_in[0+:1608]^b_in[440+:1608]};
					 56:xo <= {a_in[1600+:448]^b_in[0+:448],a_in[0+:1600]^b_in[448+:1600]};
					 57:xo <= {a_in[1592+:456]^b_in[0+:456],a_in[0+:1592]^b_in[456+:1592]};
					 58:xo <= {a_in[1584+:464]^b_in[0+:464],a_in[0+:1584]^b_in[464+:1584]};
					 59:xo <= {a_in[1576+:472]^b_in[0+:472],a_in[0+:1576]^b_in[472+:1576]};
					 60:xo <= {a_in[1568+:480]^b_in[0+:480],a_in[0+:1568]^b_in[480+:1568]};
					 61:xo <= {a_in[1560+:488]^b_in[0+:488],a_in[0+:1560]^b_in[488+:1560]};
					 62:xo <= {a_in[1552+:496]^b_in[0+:496],a_in[0+:1552]^b_in[496+:1552]};
					 63:xo <= {a_in[1544+:504]^b_in[0+:504],a_in[0+:1544]^b_in[504+:1544]};
					 64:xo <= {a_in[1536+:512]^b_in[0+:512],a_in[0+:1536]^b_in[512+:1536]};
					 65:xo <= {a_in[1528+:520]^b_in[0+:520],a_in[0+:1528]^b_in[520+:1528]};
					 66:xo <= {a_in[1520+:528]^b_in[0+:528],a_in[0+:1520]^b_in[528+:1520]};
					 67:xo <= {a_in[1512+:536]^b_in[0+:536],a_in[0+:1512]^b_in[536+:1512]};
					 68:xo <= {a_in[1504+:544]^b_in[0+:544],a_in[0+:1504]^b_in[544+:1504]};
					 69:xo <= {a_in[1496+:552]^b_in[0+:552],a_in[0+:1496]^b_in[552+:1496]};
					 70:xo <= {a_in[1488+:560]^b_in[0+:560],a_in[0+:1488]^b_in[560+:1488]};
					 71:xo <= {a_in[1480+:568]^b_in[0+:568],a_in[0+:1480]^b_in[568+:1480]};
					 72:xo <= {a_in[1472+:576]^b_in[0+:576],a_in[0+:1472]^b_in[576+:1472]};
					 73:xo <= {a_in[1464+:584]^b_in[0+:584],a_in[0+:1464]^b_in[584+:1464]};
					 74:xo <= {a_in[1456+:592]^b_in[0+:592],a_in[0+:1456]^b_in[592+:1456]};
					 75:xo <= {a_in[1448+:600]^b_in[0+:600],a_in[0+:1448]^b_in[600+:1448]};
					 76:xo <= {a_in[1440+:608]^b_in[0+:608],a_in[0+:1440]^b_in[608+:1440]};
					 77:xo <= {a_in[1432+:616]^b_in[0+:616],a_in[0+:1432]^b_in[616+:1432]};
					 78:xo <= {a_in[1424+:624]^b_in[0+:624],a_in[0+:1424]^b_in[624+:1424]};
					 79:xo <= {a_in[1416+:632]^b_in[0+:632],a_in[0+:1416]^b_in[632+:1416]};
					 80:xo <= {a_in[1408+:640]^b_in[0+:640],a_in[0+:1408]^b_in[640+:1408]};
					 81:xo <= {a_in[1400+:648]^b_in[0+:648],a_in[0+:1400]^b_in[648+:1400]};
					 82:xo <= {a_in[1392+:656]^b_in[0+:656],a_in[0+:1392]^b_in[656+:1392]};
					 83:xo <= {a_in[1384+:664]^b_in[0+:664],a_in[0+:1384]^b_in[664+:1384]};
					 84:xo <= {a_in[1376+:672]^b_in[0+:672],a_in[0+:1376]^b_in[672+:1376]};
					 85:xo <= {a_in[1368+:680]^b_in[0+:680],a_in[0+:1368]^b_in[680+:1368]};
					 86:xo <= {a_in[1360+:688]^b_in[0+:688],a_in[0+:1360]^b_in[688+:1360]};
					 87:xo <= {a_in[1352+:696]^b_in[0+:696],a_in[0+:1352]^b_in[696+:1352]};
					 88:xo <= {a_in[1344+:704]^b_in[0+:704],a_in[0+:1344]^b_in[704+:1344]};
					 89:xo <= {a_in[1336+:712]^b_in[0+:712],a_in[0+:1336]^b_in[712+:1336]};
					 90:xo <= {a_in[1328+:720]^b_in[0+:720],a_in[0+:1328]^b_in[720+:1328]};
					 91:xo <= {a_in[1320+:728]^b_in[0+:728],a_in[0+:1320]^b_in[728+:1320]};
					 92:xo <= {a_in[1312+:736]^b_in[0+:736],a_in[0+:1312]^b_in[736+:1312]};
					 93:xo <= {a_in[1304+:744]^b_in[0+:744],a_in[0+:1304]^b_in[744+:1304]};
					 94:xo <= {a_in[1296+:752]^b_in[0+:752],a_in[0+:1296]^b_in[752+:1296]};
					 95:xo <= {a_in[1288+:760]^b_in[0+:760],a_in[0+:1288]^b_in[760+:1288]};
					 96:xo <= {a_in[1280+:768]^b_in[0+:768],a_in[0+:1280]^b_in[768+:1280]};
					 97:xo <= {a_in[1272+:776]^b_in[0+:776],a_in[0+:1272]^b_in[776+:1272]};
					 98:xo <= {a_in[1264+:784]^b_in[0+:784],a_in[0+:1264]^b_in[784+:1264]};
					 99:xo <= {a_in[1256+:792]^b_in[0+:792],a_in[0+:1256]^b_in[792+:1256]};
					100:xo <= {a_in[1248+:800]^b_in[0+:800],a_in[0+:1248]^b_in[800+:1248]};
					101:xo <= {a_in[1240+:808]^b_in[0+:808],a_in[0+:1240]^b_in[808+:1240]};
					102:xo <= {a_in[1232+:816]^b_in[0+:816],a_in[0+:1232]^b_in[816+:1232]};
					103:xo <= {a_in[1224+:824]^b_in[0+:824],a_in[0+:1224]^b_in[824+:1224]};
					104:xo <= {a_in[1216+:832]^b_in[0+:832],a_in[0+:1216]^b_in[832+:1216]};
					105:xo <= {a_in[1208+:840]^b_in[0+:840],a_in[0+:1208]^b_in[840+:1208]};
					106:xo <= {a_in[1200+:848]^b_in[0+:848],a_in[0+:1200]^b_in[848+:1200]};
					107:xo <= {a_in[1192+:856]^b_in[0+:856],a_in[0+:1192]^b_in[856+:1192]};
					108:xo <= {a_in[1184+:864]^b_in[0+:864],a_in[0+:1184]^b_in[864+:1184]};
					109:xo <= {a_in[1176+:872]^b_in[0+:872],a_in[0+:1176]^b_in[872+:1176]};
					110:xo <= {a_in[1168+:880]^b_in[0+:880],a_in[0+:1168]^b_in[880+:1168]};
					111:xo <= {a_in[1160+:888]^b_in[0+:888],a_in[0+:1160]^b_in[888+:1160]};
					112:xo <= {a_in[1152+:896]^b_in[0+:896],a_in[0+:1152]^b_in[896+:1152]};
					113:xo <= {a_in[1144+:904]^b_in[0+:904],a_in[0+:1144]^b_in[904+:1144]};
					114:xo <= {a_in[1136+:912]^b_in[0+:912],a_in[0+:1136]^b_in[912+:1136]};
					115:xo <= {a_in[1128+:920]^b_in[0+:920],a_in[0+:1128]^b_in[920+:1128]};
					116:xo <= {a_in[1120+:928]^b_in[0+:928],a_in[0+:1120]^b_in[928+:1120]};
					117:xo <= {a_in[1112+:936]^b_in[0+:936],a_in[0+:1112]^b_in[936+:1112]};
					118:xo <= {a_in[1104+:944]^b_in[0+:944],a_in[0+:1104]^b_in[944+:1104]};
					119:xo <= {a_in[1096+:952]^b_in[0+:952],a_in[0+:1096]^b_in[952+:1096]};
					120:xo <= {a_in[1088+:960]^b_in[0+:960],a_in[0+:1088]^b_in[960+:1088]};
					121:xo <= {a_in[1080+:968]^b_in[0+:968],a_in[0+:1080]^b_in[968+:1080]};
					122:xo <= {a_in[1072+:976]^b_in[0+:976],a_in[0+:1072]^b_in[976+:1072]};
					123:xo <= {a_in[1064+:984]^b_in[0+:984],a_in[0+:1064]^b_in[984+:1064]};
					124:xo <= {a_in[1056+:992]^b_in[0+:992],a_in[0+:1056]^b_in[992+:1056]};
					125:xo <= {a_in[1048+:1000]^b_in[0+:1000],a_in[0+:1048]^b_in[1000+:1048]};
					126:xo <= {a_in[1040+:1008]^b_in[0+:1008],a_in[0+:1040]^b_in[1008+:1040]};
					127:xo <= {a_in[1032+:1016]^b_in[0+:1016],a_in[0+:1032]^b_in[1016+:1032]};
					128:xo <= {a_in[1024+:1024]^b_in[0+:1024],a_in[0+:1024]^b_in[1024+:1024]};
					129:xo <= {a_in[1016+:1032]^b_in[0+:1032],a_in[0+:1016]^b_in[1032+:1016]};
					130:xo <= {a_in[1008+:1040]^b_in[0+:1040],a_in[0+:1008]^b_in[1040+:1008]};
					131:xo <= {a_in[1000+:1048]^b_in[0+:1048],a_in[0+:1000]^b_in[1048+:1000]};
					132:xo <= {a_in[992+:1056]^b_in[0+:1056],a_in[0+:992]^b_in[1056+:992]};
					133:xo <= {a_in[984+:1064]^b_in[0+:1064],a_in[0+:984]^b_in[1064+:984]};
					134:xo <= {a_in[976+:1072]^b_in[0+:1072],a_in[0+:976]^b_in[1072+:976]};
					135:xo <= {a_in[968+:1080]^b_in[0+:1080],a_in[0+:968]^b_in[1080+:968]};
					136:xo <= {a_in[960+:1088]^b_in[0+:1088],a_in[0+:960]^b_in[1088+:960]};
					137:xo <= {a_in[952+:1096]^b_in[0+:1096],a_in[0+:952]^b_in[1096+:952]};
					138:xo <= {a_in[944+:1104]^b_in[0+:1104],a_in[0+:944]^b_in[1104+:944]};
					139:xo <= {a_in[936+:1112]^b_in[0+:1112],a_in[0+:936]^b_in[1112+:936]};
					140:xo <= {a_in[928+:1120]^b_in[0+:1120],a_in[0+:928]^b_in[1120+:928]};
					141:xo <= {a_in[920+:1128]^b_in[0+:1128],a_in[0+:920]^b_in[1128+:920]};
					142:xo <= {a_in[912+:1136]^b_in[0+:1136],a_in[0+:912]^b_in[1136+:912]};
					143:xo <= {a_in[904+:1144]^b_in[0+:1144],a_in[0+:904]^b_in[1144+:904]};
					144:xo <= {a_in[896+:1152]^b_in[0+:1152],a_in[0+:896]^b_in[1152+:896]};
					145:xo <= {a_in[888+:1160]^b_in[0+:1160],a_in[0+:888]^b_in[1160+:888]};
					146:xo <= {a_in[880+:1168]^b_in[0+:1168],a_in[0+:880]^b_in[1168+:880]};
					147:xo <= {a_in[872+:1176]^b_in[0+:1176],a_in[0+:872]^b_in[1176+:872]};
					148:xo <= {a_in[864+:1184]^b_in[0+:1184],a_in[0+:864]^b_in[1184+:864]};
					149:xo <= {a_in[856+:1192]^b_in[0+:1192],a_in[0+:856]^b_in[1192+:856]};
					150:xo <= {a_in[848+:1200]^b_in[0+:1200],a_in[0+:848]^b_in[1200+:848]};
					151:xo <= {a_in[840+:1208]^b_in[0+:1208],a_in[0+:840]^b_in[1208+:840]};
					152:xo <= {a_in[832+:1216]^b_in[0+:1216],a_in[0+:832]^b_in[1216+:832]};
					153:xo <= {a_in[824+:1224]^b_in[0+:1224],a_in[0+:824]^b_in[1224+:824]};
					154:xo <= {a_in[816+:1232]^b_in[0+:1232],a_in[0+:816]^b_in[1232+:816]};
					155:xo <= {a_in[808+:1240]^b_in[0+:1240],a_in[0+:808]^b_in[1240+:808]};
					156:xo <= {a_in[800+:1248]^b_in[0+:1248],a_in[0+:800]^b_in[1248+:800]};
					157:xo <= {a_in[792+:1256]^b_in[0+:1256],a_in[0+:792]^b_in[1256+:792]};
					158:xo <= {a_in[784+:1264]^b_in[0+:1264],a_in[0+:784]^b_in[1264+:784]};
					159:xo <= {a_in[776+:1272]^b_in[0+:1272],a_in[0+:776]^b_in[1272+:776]};
					160:xo <= {a_in[768+:1280]^b_in[0+:1280],a_in[0+:768]^b_in[1280+:768]};
					161:xo <= {a_in[760+:1288]^b_in[0+:1288],a_in[0+:760]^b_in[1288+:760]};
					162:xo <= {a_in[752+:1296]^b_in[0+:1296],a_in[0+:752]^b_in[1296+:752]};
					163:xo <= {a_in[744+:1304]^b_in[0+:1304],a_in[0+:744]^b_in[1304+:744]};
					164:xo <= {a_in[736+:1312]^b_in[0+:1312],a_in[0+:736]^b_in[1312+:736]};
					165:xo <= {a_in[728+:1320]^b_in[0+:1320],a_in[0+:728]^b_in[1320+:728]};
					166:xo <= {a_in[720+:1328]^b_in[0+:1328],a_in[0+:720]^b_in[1328+:720]};
					167:xo <= {a_in[712+:1336]^b_in[0+:1336],a_in[0+:712]^b_in[1336+:712]};
					168:xo <= {a_in[704+:1344]^b_in[0+:1344],a_in[0+:704]^b_in[1344+:704]};
					169:xo <= {a_in[696+:1352]^b_in[0+:1352],a_in[0+:696]^b_in[1352+:696]};
					170:xo <= {a_in[688+:1360]^b_in[0+:1360],a_in[0+:688]^b_in[1360+:688]};
					171:xo <= {a_in[680+:1368]^b_in[0+:1368],a_in[0+:680]^b_in[1368+:680]};
					172:xo <= {a_in[672+:1376]^b_in[0+:1376],a_in[0+:672]^b_in[1376+:672]};
					173:xo <= {a_in[664+:1384]^b_in[0+:1384],a_in[0+:664]^b_in[1384+:664]};
					174:xo <= {a_in[656+:1392]^b_in[0+:1392],a_in[0+:656]^b_in[1392+:656]};
					175:xo <= {a_in[648+:1400]^b_in[0+:1400],a_in[0+:648]^b_in[1400+:648]};
					176:xo <= {a_in[640+:1408]^b_in[0+:1408],a_in[0+:640]^b_in[1408+:640]};
					177:xo <= {a_in[632+:1416]^b_in[0+:1416],a_in[0+:632]^b_in[1416+:632]};
					178:xo <= {a_in[624+:1424]^b_in[0+:1424],a_in[0+:624]^b_in[1424+:624]};
					179:xo <= {a_in[616+:1432]^b_in[0+:1432],a_in[0+:616]^b_in[1432+:616]};
					180:xo <= {a_in[608+:1440]^b_in[0+:1440],a_in[0+:608]^b_in[1440+:608]};
					181:xo <= {a_in[600+:1448]^b_in[0+:1448],a_in[0+:600]^b_in[1448+:600]};
					182:xo <= {a_in[592+:1456]^b_in[0+:1456],a_in[0+:592]^b_in[1456+:592]};
					183:xo <= {a_in[584+:1464]^b_in[0+:1464],a_in[0+:584]^b_in[1464+:584]};
					184:xo <= {a_in[576+:1472]^b_in[0+:1472],a_in[0+:576]^b_in[1472+:576]};
					185:xo <= {a_in[568+:1480]^b_in[0+:1480],a_in[0+:568]^b_in[1480+:568]};
					186:xo <= {a_in[560+:1488]^b_in[0+:1488],a_in[0+:560]^b_in[1488+:560]};
					187:xo <= {a_in[552+:1496]^b_in[0+:1496],a_in[0+:552]^b_in[1496+:552]};
					188:xo <= {a_in[544+:1504]^b_in[0+:1504],a_in[0+:544]^b_in[1504+:544]};
					189:xo <= {a_in[536+:1512]^b_in[0+:1512],a_in[0+:536]^b_in[1512+:536]};
					190:xo <= {a_in[528+:1520]^b_in[0+:1520],a_in[0+:528]^b_in[1520+:528]};
					191:xo <= {a_in[520+:1528]^b_in[0+:1528],a_in[0+:520]^b_in[1528+:520]};
					192:xo <= {a_in[512+:1536]^b_in[0+:1536],a_in[0+:512]^b_in[1536+:512]};
					193:xo <= {a_in[504+:1544]^b_in[0+:1544],a_in[0+:504]^b_in[1544+:504]};
					194:xo <= {a_in[496+:1552]^b_in[0+:1552],a_in[0+:496]^b_in[1552+:496]};
					195:xo <= {a_in[488+:1560]^b_in[0+:1560],a_in[0+:488]^b_in[1560+:488]};
					196:xo <= {a_in[480+:1568]^b_in[0+:1568],a_in[0+:480]^b_in[1568+:480]};
					197:xo <= {a_in[472+:1576]^b_in[0+:1576],a_in[0+:472]^b_in[1576+:472]};
					198:xo <= {a_in[464+:1584]^b_in[0+:1584],a_in[0+:464]^b_in[1584+:464]};
					199:xo <= {a_in[456+:1592]^b_in[0+:1592],a_in[0+:456]^b_in[1592+:456]};
					200:xo <= {a_in[448+:1600]^b_in[0+:1600],a_in[0+:448]^b_in[1600+:448]};
					201:xo <= {a_in[440+:1608]^b_in[0+:1608],a_in[0+:440]^b_in[1608+:440]};
					202:xo <= {a_in[432+:1616]^b_in[0+:1616],a_in[0+:432]^b_in[1616+:432]};
					203:xo <= {a_in[424+:1624]^b_in[0+:1624],a_in[0+:424]^b_in[1624+:424]};
					204:xo <= {a_in[416+:1632]^b_in[0+:1632],a_in[0+:416]^b_in[1632+:416]};
					205:xo <= {a_in[408+:1640]^b_in[0+:1640],a_in[0+:408]^b_in[1640+:408]};
					206:xo <= {a_in[400+:1648]^b_in[0+:1648],a_in[0+:400]^b_in[1648+:400]};
					207:xo <= {a_in[392+:1656]^b_in[0+:1656],a_in[0+:392]^b_in[1656+:392]};
					208:xo <= {a_in[384+:1664]^b_in[0+:1664],a_in[0+:384]^b_in[1664+:384]};
					209:xo <= {a_in[376+:1672]^b_in[0+:1672],a_in[0+:376]^b_in[1672+:376]};
					210:xo <= {a_in[368+:1680]^b_in[0+:1680],a_in[0+:368]^b_in[1680+:368]};
					211:xo <= {a_in[360+:1688]^b_in[0+:1688],a_in[0+:360]^b_in[1688+:360]};
					212:xo <= {a_in[352+:1696]^b_in[0+:1696],a_in[0+:352]^b_in[1696+:352]};
					213:xo <= {a_in[344+:1704]^b_in[0+:1704],a_in[0+:344]^b_in[1704+:344]};
					214:xo <= {a_in[336+:1712]^b_in[0+:1712],a_in[0+:336]^b_in[1712+:336]};
					215:xo <= {a_in[328+:1720]^b_in[0+:1720],a_in[0+:328]^b_in[1720+:328]};
					216:xo <= {a_in[320+:1728]^b_in[0+:1728],a_in[0+:320]^b_in[1728+:320]};
					217:xo <= {a_in[312+:1736]^b_in[0+:1736],a_in[0+:312]^b_in[1736+:312]};
					218:xo <= {a_in[304+:1744]^b_in[0+:1744],a_in[0+:304]^b_in[1744+:304]};
					219:xo <= {a_in[296+:1752]^b_in[0+:1752],a_in[0+:296]^b_in[1752+:296]};
					220:xo <= {a_in[288+:1760]^b_in[0+:1760],a_in[0+:288]^b_in[1760+:288]};
					221:xo <= {a_in[280+:1768]^b_in[0+:1768],a_in[0+:280]^b_in[1768+:280]};
					222:xo <= {a_in[272+:1776]^b_in[0+:1776],a_in[0+:272]^b_in[1776+:272]};
					223:xo <= {a_in[264+:1784]^b_in[0+:1784],a_in[0+:264]^b_in[1784+:264]};
					224:xo <= {a_in[256+:1792]^b_in[0+:1792],a_in[0+:256]^b_in[1792+:256]};
					225:xo <= {a_in[248+:1800]^b_in[0+:1800],a_in[0+:248]^b_in[1800+:248]};
					226:xo <= {a_in[240+:1808]^b_in[0+:1808],a_in[0+:240]^b_in[1808+:240]};
					227:xo <= {a_in[232+:1816]^b_in[0+:1816],a_in[0+:232]^b_in[1816+:232]};
					228:xo <= {a_in[224+:1824]^b_in[0+:1824],a_in[0+:224]^b_in[1824+:224]};
					229:xo <= {a_in[216+:1832]^b_in[0+:1832],a_in[0+:216]^b_in[1832+:216]};
					230:xo <= {a_in[208+:1840]^b_in[0+:1840],a_in[0+:208]^b_in[1840+:208]};
					231:xo <= {a_in[200+:1848]^b_in[0+:1848],a_in[0+:200]^b_in[1848+:200]};
					232:xo <= {a_in[192+:1856]^b_in[0+:1856],a_in[0+:192]^b_in[1856+:192]};
					233:xo <= {a_in[184+:1864]^b_in[0+:1864],a_in[0+:184]^b_in[1864+:184]};
					234:xo <= {a_in[176+:1872]^b_in[0+:1872],a_in[0+:176]^b_in[1872+:176]};
					235:xo <= {a_in[168+:1880]^b_in[0+:1880],a_in[0+:168]^b_in[1880+:168]};
					236:xo <= {a_in[160+:1888]^b_in[0+:1888],a_in[0+:160]^b_in[1888+:160]};
					237:xo <= {a_in[152+:1896]^b_in[0+:1896],a_in[0+:152]^b_in[1896+:152]};
					238:xo <= {a_in[144+:1904]^b_in[0+:1904],a_in[0+:144]^b_in[1904+:144]};
					239:xo <= {a_in[136+:1912]^b_in[0+:1912],a_in[0+:136]^b_in[1912+:136]};
					240:xo <= {a_in[128+:1920]^b_in[0+:1920],a_in[0+:128]^b_in[1920+:128]};
					241:xo <= {a_in[120+:1928]^b_in[0+:1928],a_in[0+:120]^b_in[1928+:120]};
					242:xo <= {a_in[112+:1936]^b_in[0+:1936],a_in[0+:112]^b_in[1936+:112]};
					243:xo <= {a_in[104+:1944]^b_in[0+:1944],a_in[0+:104]^b_in[1944+:104]};
					244:xo <= {a_in[96+:1952]^b_in[0+:1952],a_in[0+:96]^b_in[1952+:96]};
					245:xo <= {a_in[88+:1960]^b_in[0+:1960],a_in[0+:88]^b_in[1960+:88]};
					246:xo <= {a_in[80+:1968]^b_in[0+:1968],a_in[0+:80]^b_in[1968+:80]};
					247:xo <= {a_in[72+:1976]^b_in[0+:1976],a_in[0+:72]^b_in[1976+:72]};
					248:xo <= {a_in[64+:1984]^b_in[0+:1984],a_in[0+:64]^b_in[1984+:64]};
					249:xo <= {a_in[56+:1992]^b_in[0+:1992],a_in[0+:56]^b_in[1992+:56]};
					250:xo <= {a_in[48+:2000]^b_in[0+:2000],a_in[0+:48]^b_in[2000+:48]};
					251:xo <= {a_in[40+:2008]^b_in[0+:2008],a_in[0+:40]^b_in[2008+:40]};
					252:xo <= {a_in[32+:2016]^b_in[0+:2016],a_in[0+:32]^b_in[2016+:32]};
					253:xo <= {a_in[24+:2024]^b_in[0+:2024],a_in[0+:24]^b_in[2024+:24]};
					254:xo <= {a_in[16+:2032]^b_in[0+:2032],a_in[0+:16]^b_in[2032+:16]};
					255:xo <= {a_in[8+:2040]^b_in[0+:2040],a_in[0+:8]^b_in[2040+:8]};	
				endcase
			end
		end
	end
	else begin
		always @(posedge clk)begin
			if(in_vld&in_rdy)begin
				case(buf_ptr_in)
					  0:xo <= a_in[0+:256]^b_in[0+:256];
				  	  1:xo <= a_in[0+:256]^b_in[8+:256];
				  	  2:xo <= a_in[0+:256]^b_in[16+:256];
				  	  3:xo <= a_in[0+:256]^b_in[24+:256];
				  	  4:xo <= a_in[0+:256]^b_in[32+:256];
				  	  5:xo <= a_in[0+:256]^b_in[40+:256];
				  	  6:xo <= a_in[0+:256]^b_in[48+:256];
				  	  7:xo <= a_in[0+:256]^b_in[56+:256];
				  	  8:xo <= a_in[0+:256]^b_in[64+:256];
				  	  9:xo <= a_in[0+:256]^b_in[72+:256];
				  	 10:xo <= a_in[0+:256]^b_in[80+:256];
				  	 11:xo <= a_in[0+:256]^b_in[88+:256];
				  	 12:xo <= a_in[0+:256]^b_in[96+:256];
				  	 13:xo <= a_in[0+:256]^b_in[104+:256];
				  	 14:xo <= a_in[0+:256]^b_in[112+:256];
				  	 15:xo <= a_in[0+:256]^b_in[120+:256];
				  	 16:xo <= a_in[0+:256]^b_in[128+:256];
				  	 17:xo <= a_in[0+:256]^b_in[136+:256];
				  	 18:xo <= a_in[0+:256]^b_in[144+:256];
				  	 19:xo <= a_in[0+:256]^b_in[152+:256];
				  	 20:xo <= a_in[0+:256]^b_in[160+:256];
				  	 21:xo <= a_in[0+:256]^b_in[168+:256];
				  	 22:xo <= a_in[0+:256]^b_in[176+:256];
				  	 23:xo <= a_in[0+:256]^b_in[184+:256];
				  	 24:xo <= a_in[0+:256]^b_in[192+:256];
				  	 25:xo <= a_in[0+:256]^b_in[200+:256];
				  	 26:xo <= a_in[0+:256]^b_in[208+:256];
				  	 27:xo <= a_in[0+:256]^b_in[216+:256];
				  	 28:xo <= a_in[0+:256]^b_in[224+:256];
				  	 29:xo <= a_in[0+:256]^b_in[232+:256];
				  	 30:xo <= a_in[0+:256]^b_in[240+:256];
				  	 31:xo <= a_in[0+:256]^b_in[248+:256];
				  	 32:xo <= a_in[0+:256]^b_in[256+:256];
				  	 33:xo <= a_in[0+:256]^b_in[264+:256];
				  	 34:xo <= a_in[0+:256]^b_in[272+:256];
				  	 35:xo <= a_in[0+:256]^b_in[280+:256];
				  	 36:xo <= a_in[0+:256]^b_in[288+:256];
				  	 37:xo <= a_in[0+:256]^b_in[296+:256];
				  	 38:xo <= a_in[0+:256]^b_in[304+:256];
				  	 39:xo <= a_in[0+:256]^b_in[312+:256];
				  	 40:xo <= a_in[0+:256]^b_in[320+:256];
				  	 41:xo <= a_in[0+:256]^b_in[328+:256];
				  	 42:xo <= a_in[0+:256]^b_in[336+:256];
				  	 43:xo <= a_in[0+:256]^b_in[344+:256];
				  	 44:xo <= a_in[0+:256]^b_in[352+:256];
				  	 45:xo <= a_in[0+:256]^b_in[360+:256];
				  	 46:xo <= a_in[0+:256]^b_in[368+:256];
				  	 47:xo <= a_in[0+:256]^b_in[376+:256];
				  	 48:xo <= a_in[0+:256]^b_in[384+:256];
				  	 49:xo <= a_in[0+:256]^b_in[392+:256];
				  	 50:xo <= a_in[0+:256]^b_in[400+:256];
				  	 51:xo <= a_in[0+:256]^b_in[408+:256];
				  	 52:xo <= a_in[0+:256]^b_in[416+:256];
				  	 53:xo <= a_in[0+:256]^b_in[424+:256];
				  	 54:xo <= a_in[0+:256]^b_in[432+:256];
				  	 55:xo <= a_in[0+:256]^b_in[440+:256];
				  	 56:xo <= a_in[0+:256]^b_in[448+:256];
				  	 57:xo <= a_in[0+:256]^b_in[456+:256];
				  	 58:xo <= a_in[0+:256]^b_in[464+:256];
				  	 59:xo <= a_in[0+:256]^b_in[472+:256];
				  	 60:xo <= a_in[0+:256]^b_in[480+:256];
				  	 61:xo <= a_in[0+:256]^b_in[488+:256];
				  	 62:xo <= a_in[0+:256]^b_in[496+:256];
				  	 63:xo <= a_in[0+:256]^b_in[504+:256];
				  	 64:xo <= a_in[0+:256]^b_in[512+:256];
				  	 65:xo <= a_in[0+:256]^b_in[520+:256];
				  	 66:xo <= a_in[0+:256]^b_in[528+:256];
				  	 67:xo <= a_in[0+:256]^b_in[536+:256];
				  	 68:xo <= a_in[0+:256]^b_in[544+:256];
				  	 69:xo <= a_in[0+:256]^b_in[552+:256];
				  	 70:xo <= a_in[0+:256]^b_in[560+:256];
				  	 71:xo <= a_in[0+:256]^b_in[568+:256];
				  	 72:xo <= a_in[0+:256]^b_in[576+:256];
				  	 73:xo <= a_in[0+:256]^b_in[584+:256];
				  	 74:xo <= a_in[0+:256]^b_in[592+:256];
				  	 75:xo <= a_in[0+:256]^b_in[600+:256];
				  	 76:xo <= a_in[0+:256]^b_in[608+:256];
				  	 77:xo <= a_in[0+:256]^b_in[616+:256];
				  	 78:xo <= a_in[0+:256]^b_in[624+:256];
				  	 79:xo <= a_in[0+:256]^b_in[632+:256];
				  	 80:xo <= a_in[0+:256]^b_in[640+:256];
				  	 81:xo <= a_in[0+:256]^b_in[648+:256];
				  	 82:xo <= a_in[0+:256]^b_in[656+:256];
				  	 83:xo <= a_in[0+:256]^b_in[664+:256];
				  	 84:xo <= a_in[0+:256]^b_in[672+:256];
				  	 85:xo <= a_in[0+:256]^b_in[680+:256];
				  	 86:xo <= a_in[0+:256]^b_in[688+:256];
				  	 87:xo <= a_in[0+:256]^b_in[696+:256];
				  	 88:xo <= a_in[0+:256]^b_in[704+:256];
				  	 89:xo <= a_in[0+:256]^b_in[712+:256];
				  	 90:xo <= a_in[0+:256]^b_in[720+:256];
				  	 91:xo <= a_in[0+:256]^b_in[728+:256];
				  	 92:xo <= a_in[0+:256]^b_in[736+:256];
				  	 93:xo <= a_in[0+:256]^b_in[744+:256];
				  	 94:xo <= a_in[0+:256]^b_in[752+:256];
				  	 95:xo <= a_in[0+:256]^b_in[760+:256];
				  	 96:xo <= a_in[0+:256]^b_in[768+:256];
				  	 97:xo <= a_in[0+:256]^b_in[776+:256];
				  	 98:xo <= a_in[0+:256]^b_in[784+:256];
				  	 99:xo <= a_in[0+:256]^b_in[792+:256];
				  	100:xo <= a_in[0+:256]^b_in[800+:256];
				  	101:xo <= a_in[0+:256]^b_in[808+:256];
				  	102:xo <= a_in[0+:256]^b_in[816+:256];
				  	103:xo <= a_in[0+:256]^b_in[824+:256];
				  	104:xo <= a_in[0+:256]^b_in[832+:256];
				  	105:xo <= a_in[0+:256]^b_in[840+:256];
				  	106:xo <= a_in[0+:256]^b_in[848+:256];
				  	107:xo <= a_in[0+:256]^b_in[856+:256];
				  	108:xo <= a_in[0+:256]^b_in[864+:256];
				  	109:xo <= a_in[0+:256]^b_in[872+:256];
				  	110:xo <= a_in[0+:256]^b_in[880+:256];
				  	111:xo <= a_in[0+:256]^b_in[888+:256];
				  	112:xo <= a_in[0+:256]^b_in[896+:256];
				  	113:xo <= a_in[0+:256]^b_in[904+:256];
				  	114:xo <= a_in[0+:256]^b_in[912+:256];
				  	115:xo <= a_in[0+:256]^b_in[920+:256];
				  	116:xo <= a_in[0+:256]^b_in[928+:256];
				  	117:xo <= a_in[0+:256]^b_in[936+:256];
				  	118:xo <= a_in[0+:256]^b_in[944+:256];
				  	119:xo <= a_in[0+:256]^b_in[952+:256];
				  	120:xo <= a_in[0+:256]^b_in[960+:256];
				  	121:xo <= a_in[0+:256]^b_in[968+:256];
				  	122:xo <= a_in[0+:256]^b_in[976+:256];
				  	123:xo <= a_in[0+:256]^b_in[984+:256];
				  	124:xo <= a_in[0+:256]^b_in[992+:256];
				  	125:xo <= a_in[0+:256]^b_in[1000+:256];
				  	126:xo <= a_in[0+:256]^b_in[1008+:256];
				  	127:xo <= a_in[0+:256]^b_in[1016+:256];
				  	128:xo <= a_in[0+:256]^b_in[1024+:256];
				  	129:xo <= a_in[0+:256]^b_in[1032+:256];
				  	130:xo <= a_in[0+:256]^b_in[1040+:256];
				  	131:xo <= a_in[0+:256]^b_in[1048+:256];
				  	132:xo <= a_in[0+:256]^b_in[1056+:256];
				  	133:xo <= a_in[0+:256]^b_in[1064+:256];
				  	134:xo <= a_in[0+:256]^b_in[1072+:256];
				  	135:xo <= a_in[0+:256]^b_in[1080+:256];
				  	136:xo <= a_in[0+:256]^b_in[1088+:256];
				  	137:xo <= a_in[0+:256]^b_in[1096+:256];
				  	138:xo <= a_in[0+:256]^b_in[1104+:256];
				  	139:xo <= a_in[0+:256]^b_in[1112+:256];
				  	140:xo <= a_in[0+:256]^b_in[1120+:256];
				  	141:xo <= a_in[0+:256]^b_in[1128+:256];
				  	142:xo <= a_in[0+:256]^b_in[1136+:256];
				  	143:xo <= a_in[0+:256]^b_in[1144+:256];
				  	144:xo <= a_in[0+:256]^b_in[1152+:256];
				  	145:xo <= a_in[0+:256]^b_in[1160+:256];
				  	146:xo <= a_in[0+:256]^b_in[1168+:256];
				  	147:xo <= a_in[0+:256]^b_in[1176+:256];
				  	148:xo <= a_in[0+:256]^b_in[1184+:256];
				  	149:xo <= a_in[0+:256]^b_in[1192+:256];
				  	150:xo <= a_in[0+:256]^b_in[1200+:256];
				  	151:xo <= a_in[0+:256]^b_in[1208+:256];
				  	152:xo <= a_in[0+:256]^b_in[1216+:256];
				  	153:xo <= a_in[0+:256]^b_in[1224+:256];
				  	154:xo <= a_in[0+:256]^b_in[1232+:256];
				  	155:xo <= a_in[0+:256]^b_in[1240+:256];
				  	156:xo <= a_in[0+:256]^b_in[1248+:256];
				  	157:xo <= a_in[0+:256]^b_in[1256+:256];
				  	158:xo <= a_in[0+:256]^b_in[1264+:256];
				  	159:xo <= a_in[0+:256]^b_in[1272+:256];
				  	160:xo <= a_in[0+:256]^b_in[1280+:256];
				  	161:xo <= a_in[0+:256]^b_in[1288+:256];
				  	162:xo <= a_in[0+:256]^b_in[1296+:256];
				  	163:xo <= a_in[0+:256]^b_in[1304+:256];
				  	164:xo <= a_in[0+:256]^b_in[1312+:256];
				  	165:xo <= a_in[0+:256]^b_in[1320+:256];
				  	166:xo <= a_in[0+:256]^b_in[1328+:256];
				  	167:xo <= a_in[0+:256]^b_in[1336+:256];
				  	168:xo <= a_in[0+:256]^b_in[1344+:256];
				  	169:xo <= a_in[0+:256]^b_in[1352+:256];
				  	170:xo <= a_in[0+:256]^b_in[1360+:256];
				  	171:xo <= a_in[0+:256]^b_in[1368+:256];
				  	172:xo <= a_in[0+:256]^b_in[1376+:256];
				  	173:xo <= a_in[0+:256]^b_in[1384+:256];
				  	174:xo <= a_in[0+:256]^b_in[1392+:256];
				  	175:xo <= a_in[0+:256]^b_in[1400+:256];
				  	176:xo <= a_in[0+:256]^b_in[1408+:256];
				  	177:xo <= a_in[0+:256]^b_in[1416+:256];
				  	178:xo <= a_in[0+:256]^b_in[1424+:256];
				  	179:xo <= a_in[0+:256]^b_in[1432+:256];
				  	180:xo <= a_in[0+:256]^b_in[1440+:256];
				  	181:xo <= a_in[0+:256]^b_in[1448+:256];
				  	182:xo <= a_in[0+:256]^b_in[1456+:256];
				  	183:xo <= a_in[0+:256]^b_in[1464+:256];
				  	184:xo <= a_in[0+:256]^b_in[1472+:256];
				  	185:xo <= a_in[0+:256]^b_in[1480+:256];
				  	186:xo <= a_in[0+:256]^b_in[1488+:256];
				  	187:xo <= a_in[0+:256]^b_in[1496+:256];
				  	188:xo <= a_in[0+:256]^b_in[1504+:256];
				  	189:xo <= a_in[0+:256]^b_in[1512+:256];
				  	190:xo <= a_in[0+:256]^b_in[1520+:256];
				  	191:xo <= a_in[0+:256]^b_in[1528+:256];
				  	192:xo <= a_in[0+:256]^b_in[1536+:256];
				  	193:xo <= a_in[0+:256]^b_in[1544+:256];
				  	194:xo <= a_in[0+:256]^b_in[1552+:256];
				  	195:xo <= a_in[0+:256]^b_in[1560+:256];
				  	196:xo <= a_in[0+:256]^b_in[1568+:256];
				  	197:xo <= a_in[0+:256]^b_in[1576+:256];
				  	198:xo <= a_in[0+:256]^b_in[1584+:256];
				  	199:xo <= a_in[0+:256]^b_in[1592+:256];
				  	200:xo <= a_in[0+:256]^b_in[1600+:256];
				  	201:xo <= a_in[0+:256]^b_in[1608+:256];
				  	202:xo <= a_in[0+:256]^b_in[1616+:256];
				  	203:xo <= a_in[0+:256]^b_in[1624+:256];
				  	204:xo <= a_in[0+:256]^b_in[1632+:256];
				  	205:xo <= a_in[0+:256]^b_in[1640+:256];
				  	206:xo <= a_in[0+:256]^b_in[1648+:256];
				  	207:xo <= a_in[0+:256]^b_in[1656+:256];
				  	208:xo <= a_in[0+:256]^b_in[1664+:256];
				  	209:xo <= a_in[0+:256]^b_in[1672+:256];
				  	210:xo <= a_in[0+:256]^b_in[1680+:256];
				  	211:xo <= a_in[0+:256]^b_in[1688+:256];
				  	212:xo <= a_in[0+:256]^b_in[1696+:256];
				  	213:xo <= a_in[0+:256]^b_in[1704+:256];
				  	214:xo <= a_in[0+:256]^b_in[1712+:256];
				  	215:xo <= a_in[0+:256]^b_in[1720+:256];
				  	216:xo <= a_in[0+:256]^b_in[1728+:256];
				  	217:xo <= a_in[0+:256]^b_in[1736+:256];
				  	218:xo <= a_in[0+:256]^b_in[1744+:256];
				  	219:xo <= a_in[0+:256]^b_in[1752+:256];
				  	220:xo <= a_in[0+:256]^b_in[1760+:256];
				  	221:xo <= a_in[0+:256]^b_in[1768+:256];
				  	222:xo <= a_in[0+:256]^b_in[1776+:256];
				  	223:xo <= a_in[0+:256]^b_in[1784+:256];
				  	224:xo <= a_in[0+:256]^b_in[1792+:256];
				  	225:xo <= {a_in[248+:8]^b_in[0+:8],a_in[0+:248]^b_in[1800+:248]};
				  	226:xo <= {a_in[240+:16]^b_in[0+:16],a_in[0+:240]^b_in[1808+:240]};
				  	227:xo <= {a_in[232+:24]^b_in[0+:24],a_in[0+:232]^b_in[1816+:232]};
				  	228:xo <= {a_in[224+:32]^b_in[0+:32],a_in[0+:224]^b_in[1824+:224]};
				  	229:xo <= {a_in[216+:40]^b_in[0+:40],a_in[0+:216]^b_in[1832+:216]};
				  	230:xo <= {a_in[208+:48]^b_in[0+:48],a_in[0+:208]^b_in[1840+:208]};
				  	231:xo <= {a_in[200+:56]^b_in[0+:56],a_in[0+:200]^b_in[1848+:200]};
				  	232:xo <= {a_in[192+:64]^b_in[0+:64],a_in[0+:192]^b_in[1856+:192]};
				  	233:xo <= {a_in[184+:72]^b_in[0+:72],a_in[0+:184]^b_in[1864+:184]};
				  	234:xo <= {a_in[176+:80]^b_in[0+:80],a_in[0+:176]^b_in[1872+:176]};
				  	235:xo <= {a_in[168+:88]^b_in[0+:88],a_in[0+:168]^b_in[1880+:168]};
				  	236:xo <= {a_in[160+:96]^b_in[0+:96],a_in[0+:160]^b_in[1888+:160]};
				  	237:xo <= {a_in[152+:104]^b_in[0+:104],a_in[0+:152]^b_in[1896+:152]};
				  	238:xo <= {a_in[144+:112]^b_in[0+:112],a_in[0+:144]^b_in[1904+:144]};
				  	239:xo <= {a_in[136+:120]^b_in[0+:120],a_in[0+:136]^b_in[1912+:136]};
				  	240:xo <= {a_in[128+:128]^b_in[0+:128],a_in[0+:128]^b_in[1920+:128]};
				  	241:xo <= {a_in[120+:136]^b_in[0+:136],a_in[0+:120]^b_in[1928+:120]};
				  	242:xo <= {a_in[112+:144]^b_in[0+:144],a_in[0+:112]^b_in[1936+:112]};
				  	243:xo <= {a_in[104+:152]^b_in[0+:152],a_in[0+:104]^b_in[1944+:104]};
				  	244:xo <= {a_in[96+:160]^b_in[0+:160],a_in[0+:96]^b_in[1952+:96]};
				  	245:xo <= {a_in[88+:168]^b_in[0+:168],a_in[0+:88]^b_in[1960+:88]};
				  	246:xo <= {a_in[80+:176]^b_in[0+:176],a_in[0+:80]^b_in[1968+:80]};
				  	247:xo <= {a_in[72+:184]^b_in[0+:184],a_in[0+:72]^b_in[1976+:72]};
				  	248:xo <= {a_in[64+:192]^b_in[0+:192],a_in[0+:64]^b_in[1984+:64]};
				  	249:xo <= {a_in[56+:200]^b_in[0+:200],a_in[0+:56]^b_in[1992+:56]};
				  	250:xo <= {a_in[48+:208]^b_in[0+:208],a_in[0+:48]^b_in[2000+:48]};
				  	251:xo <= {a_in[40+:216]^b_in[0+:216],a_in[0+:40]^b_in[2008+:40]};
				  	252:xo <= {a_in[32+:224]^b_in[0+:224],a_in[0+:32]^b_in[2016+:32]};
				  	253:xo <= {a_in[24+:232]^b_in[0+:232],a_in[0+:24]^b_in[2024+:24]};
				  	254:xo <= {a_in[16+:240]^b_in[0+:240],a_in[0+:16]^b_in[2032+:16]};
				  	255:xo <= {a_in[8+:248]^b_in[0+:248],a_in[0+:8]^b_in[2040+:8]};
				endcase
			end
		end
	end
endgenerate
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		out_vld <= 1'b0;
	end
	else if(in_rdy)begin
		out_vld <= in_vld;
	end
end

always @(posedge clk)begin
	if(in_vld&in_rdy)begin
		password_o <= password;
	end
end
assign in_rdy = (~out_vld)|(out_vld&out_rdy);
endmodule
