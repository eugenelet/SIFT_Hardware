module computeDescriptor(
    clk,
    rst_n,
    start,//same as the one into match
    kptRowCol,
    //line_buffer_0,
    //line_buffer_1,
    //line_buffer_2,
    kpt_num,//can't change
    kpt_addr,
    blurred_addr,
    row_col_descpt1,//FF，send into match using wire
    row_col_descpt2,
    row_col_descpt3,
    row_col_descpt4,
    descriptor_request,//match is requesting
    descriptor_valid,//tell match, 4 descpts are ready
    readFrom,
    blurred_dout
);

    input               clk,
                        rst_n,
                        start;
                         
    input               descriptor_request;
    
    input       [19:0]  kptRowCol;//kptMEM output wire
                    
    //input       [5119:0]line_buffer_0,//drag 3 output of LB in
    //                    line_buffer_1,
    //                    line_buffer_2;
    
    input       [5119:0]blurred_dout;
    
    
    output  reg [10:0]  kpt_addr;
    input       [10:0]  kpt_num;
    
    output      [8:0]   blurred_addr;
    
    output  reg [402:0] row_col_descpt1,
                        row_col_descpt2,
                        row_col_descpt3,
                        row_col_descpt4;
                    
    output              descriptor_valid;
    
    output  reg         readFrom;//readFrom layer 1 or layer 2 
    
    //////////////////////////////
    
    parameter   ST_IDLE             = 'd0,
                ST_WAITING_KPT      = 'd1,
                ST_GET_KPT          = 'd2,
                ST_GET_BLUR_ADDR    = 'd3,
                ST_WAITING_BLUR     = 'd4,
                ST_WAITING_BLUR     = 'd5,
                ST_LB_GET           = 'd6,//line buffer
                ST_FINISH_ONE       = 'd7,
                ST_DESCPT_VALID     = 'd8;
                
    reg[3:0]    cs,
                ns;
    
    //////////////////////////////
    
    wire[10:0]  new_kpt_num;
    wire[95:0]  row_accu_result1,//from combination(8 x 12 = 96)
                row_accu_result2;
    
    reg [8:0]   blurred_addr;
    
    reg [402:0] inner_row_col_descpt1,
                inner_row_col_descpt2,
                inner_row_col_descpt3,
                inner_row_col_descpt4;
                
    reg [135:0] wantedPart;
    
    reg [18:0]  kptRowCol_FF;//catch from memory out

    reg [4:0]   cycle_count;//cycle_count of ST_LB_GET
    
    reg [2:0]   descpt_ready_num;//how many descpts are ready in inner_FF
    
    //reg [95:0]  accu_8_dim_1,//8 int x 12 = 96
    //            accu_8_dim_2;
                
    reg [11:0]  dim1_bin_0,
                dim1_bin_1,
                dim1_bin_2,
                dim1_bin_3,
                dim1_bin_4,
                dim1_bin_5,
                dim1_bin_6,
                dim1_bin_7;
                
    reg [11:0]  dim2_bin_0,
                dim2_bin_1,
                dim2_bin_2,
                dim2_bin_3,
                dim2_bin_4,
                dim2_bin_5,
                dim2_bin_6,
                dim2_bin_7;
                
    reg [135:0] buffer_0,
                buffer_1,
                buffer_2;
                
    reg [5119:0]blurred_dout_FF;
                
    //////////////////////////////
    
    assign new_kpt_num              = kpt_num - kpt_num[1:0];
    assign descriptor_valid         = (cs == ST_DESCPT_VALID)? 1'b1 : 1'b0;
    
    //////////////////////////////
    
    accumulateOrientation u_accumulateOrientation(
        .buffer_0           (buffer_0),
        .buffer_1           (buffer_1),
        .buffer_2           (buffer_2),
        .row                (kptRowCol_FF[18:10]),
        .col                (kptRowCol_FF[9:0]),
        .row_accu_result1   (row_accu_result1),
        .row_accu_result2   (row_accu_result2)
    );
    
    //////////////////////////////
    
    always @(posedge clk) begin
    
        if(!rst_n)
            blurred_dout_FF <= 'd0;
        else if(cs == ST_WAITING_BLUR_1)
            blurred_dout_FF <= blurred_dout;
        else
            blurred_dout_FF <= blurred_dout_FF;
    
    end
    
    always @(*) begin //wantedPart
    
        case(kptRowCol[9:0])//col
            
            'd8:
                wantedPart = blurred_dout_FF[135:0];
            'd9:
                wantedPart = blurred_dout_FF[143:8];
            'd10:
                wantedPart = blurred_dout_FF[151:16];
            'd11:
                wantedPart = blurred_dout_FF[159:24];
            'd12:
                wantedPart = blurred_dout_FF[167:32];
            'd13:
                wantedPart = blurred_dout_FF[175:40];
            'd14:
                wantedPart = blurred_dout_FF[183:48];
            'd15:
                wantedPart = blurred_dout_FF[191:56];
            'd16:
                wantedPart = blurred_dout_FF[199:64];
            'd17:
                wantedPart = blurred_dout_FF[207:72];
            'd18:
                wantedPart = blurred_dout_FF[215:80];
            'd19:
                wantedPart = blurred_dout_FF[223:88];
            'd20:
                wantedPart = blurred_dout_FF[231:96];
            'd21:
                wantedPart = blurred_dout_FF[239:104];
            'd22:
                wantedPart = blurred_dout_FF[247:112];
            'd23:
                wantedPart = blurred_dout_FF[255:120];
            'd24:
                wantedPart = blurred_dout_FF[263:128];
            'd25:
                wantedPart = blurred_dout_FF[271:136];
            'd26:
                wantedPart = blurred_dout_FF[279:144];
            'd27:
                wantedPart = blurred_dout_FF[287:152];
            'd28:
                wantedPart = blurred_dout_FF[295:160];
            'd29:
                wantedPart = blurred_dout_FF[303:168];
            'd30:
                wantedPart = blurred_dout_FF[311:176];
            'd31:
                wantedPart = blurred_dout_FF[319:184];
            'd32:
                wantedPart = blurred_dout_FF[327:192];
            'd33:
                wantedPart = blurred_dout_FF[335:200];
            'd34:
                wantedPart = blurred_dout_FF[343:208];
            'd35:
                wantedPart = blurred_dout_FF[351:216];
            'd36:
                wantedPart = blurred_dout_FF[359:224];
            'd37:
                wantedPart = blurred_dout_FF[367:232];
            'd38:
                wantedPart = blurred_dout_FF[375:240];
            'd39:
                wantedPart = blurred_dout_FF[383:248];
            'd40:
                wantedPart = blurred_dout_FF[391:256];
            'd41:
                wantedPart = blurred_dout_FF[399:264];
            'd42:
                wantedPart = blurred_dout_FF[407:272];
            'd43:
                wantedPart = blurred_dout_FF[415:280];
            'd44:
                wantedPart = blurred_dout_FF[423:288];
            'd45:
                wantedPart = blurred_dout_FF[431:296];
            'd46:
                wantedPart = blurred_dout_FF[439:304];
            'd47:
                wantedPart = blurred_dout_FF[447:312];
            'd48:
                wantedPart = blurred_dout_FF[455:320];
            'd49:
                wantedPart = blurred_dout_FF[463:328];
            'd50:
                wantedPart = blurred_dout_FF[471:336];
            'd51:
                wantedPart = blurred_dout_FF[479:344];
            'd52:
                wantedPart = blurred_dout_FF[487:352];
            'd53:
                wantedPart = blurred_dout_FF[495:360];
            'd54:
                wantedPart = blurred_dout_FF[503:368];
            'd55:
                wantedPart = blurred_dout_FF[511:376];
            'd56:
                wantedPart = blurred_dout_FF[519:384];
            'd57:
                wantedPart = blurred_dout_FF[527:392];
            'd58:
                wantedPart = blurred_dout_FF[535:400];
            'd59:
                wantedPart = blurred_dout_FF[543:408];
            'd60:
                wantedPart = blurred_dout_FF[551:416];
            'd61:
                wantedPart = blurred_dout_FF[559:424];
            'd62:
                wantedPart = blurred_dout_FF[567:432];
            'd63:
                wantedPart = blurred_dout_FF[575:440];
            'd64:
                wantedPart = blurred_dout_FF[583:448];
            'd65:
                wantedPart = blurred_dout_FF[591:456];
            'd66:
                wantedPart = blurred_dout_FF[599:464];
            'd67:
                wantedPart = blurred_dout_FF[607:472];
            'd68:
                wantedPart = blurred_dout_FF[615:480];
            'd69:
                wantedPart = blurred_dout_FF[623:488];
            'd70:
                wantedPart = blurred_dout_FF[631:496];
            'd71:
                wantedPart = blurred_dout_FF[639:504];
            'd72:
                wantedPart = blurred_dout_FF[647:512];
            'd73:
                wantedPart = blurred_dout_FF[655:520];
            'd74:
                wantedPart = blurred_dout_FF[663:528];
            'd75:
                wantedPart = blurred_dout_FF[671:536];
            'd76:
                wantedPart = blurred_dout_FF[679:544];
            'd77:
                wantedPart = blurred_dout_FF[687:552];
            'd78:
                wantedPart = blurred_dout_FF[695:560];
            'd79:
                wantedPart = blurred_dout_FF[703:568];
            'd80:
                wantedPart = blurred_dout_FF[711:576];
            'd81:
                wantedPart = blurred_dout_FF[719:584];
            'd82:
                wantedPart = blurred_dout_FF[727:592];
            'd83:
                wantedPart = blurred_dout_FF[735:600];
            'd84:
                wantedPart = blurred_dout_FF[743:608];
            'd85:
                wantedPart = blurred_dout_FF[751:616];
            'd86:
                wantedPart = blurred_dout_FF[759:624];
            'd87:
                wantedPart = blurred_dout_FF[767:632];
            'd88:
                wantedPart = blurred_dout_FF[775:640];
            'd89:
                wantedPart = blurred_dout_FF[783:648];
            'd90:
                wantedPart = blurred_dout_FF[791:656];
            'd91:
                wantedPart = blurred_dout_FF[799:664];
            'd92:
                wantedPart = blurred_dout_FF[807:672];
            'd93:
                wantedPart = blurred_dout_FF[815:680];
            'd94:
                wantedPart = blurred_dout_FF[823:688];
            'd95:
                wantedPart = blurred_dout_FF[831:696];
            'd96:
                wantedPart = blurred_dout_FF[839:704];
            'd97:
                wantedPart = blurred_dout_FF[847:712];
            'd98:
                wantedPart = blurred_dout_FF[855:720];
            'd99:
                wantedPart = blurred_dout_FF[863:728];
            'd100:
                wantedPart = blurred_dout_FF[871:736];
            'd101:
                wantedPart = blurred_dout_FF[879:744];
            'd102:
                wantedPart = blurred_dout_FF[887:752];
            'd103:
                wantedPart = blurred_dout_FF[895:760];
            'd104:
                wantedPart = blurred_dout_FF[903:768];
            'd105:
                wantedPart = blurred_dout_FF[911:776];
            'd106:
                wantedPart = blurred_dout_FF[919:784];
            'd107:
                wantedPart = blurred_dout_FF[927:792];
            'd108:
                wantedPart = blurred_dout_FF[935:800];
            'd109:
                wantedPart = blurred_dout_FF[943:808];
            'd110:
                wantedPart = blurred_dout_FF[951:816];
            'd111:
                wantedPart = blurred_dout_FF[959:824];
            'd112:
                wantedPart = blurred_dout_FF[967:832];
            'd113:
                wantedPart = blurred_dout_FF[975:840];
            'd114:
                wantedPart = blurred_dout_FF[983:848];
            'd115:
                wantedPart = blurred_dout_FF[991:856];
            'd116:
                wantedPart = blurred_dout_FF[999:864];
            'd117:
                wantedPart = blurred_dout_FF[1007:872];
            'd118:
                wantedPart = blurred_dout_FF[1015:880];
            'd119:
                wantedPart = blurred_dout_FF[1023:888];
            'd120:
                wantedPart = blurred_dout_FF[1031:896];
            'd121:
                wantedPart = blurred_dout_FF[1039:904];
            'd122:
                wantedPart = blurred_dout_FF[1047:912];
            'd123:
                wantedPart = blurred_dout_FF[1055:920];
            'd124:
                wantedPart = blurred_dout_FF[1063:928];
            'd125:
                wantedPart = blurred_dout_FF[1071:936];
            'd126:
                wantedPart = blurred_dout_FF[1079:944];
            'd127:
                wantedPart = blurred_dout_FF[1087:952];
            'd128:
                wantedPart = blurred_dout_FF[1095:960];
            'd129:
                wantedPart = blurred_dout_FF[1103:968];
            'd130:
                wantedPart = blurred_dout_FF[1111:976];
            'd131:
                wantedPart = blurred_dout_FF[1119:984];
            'd132:
                wantedPart = blurred_dout_FF[1127:992];
            'd133:
                wantedPart = blurred_dout_FF[1135:1000];
            'd134:
                wantedPart = blurred_dout_FF[1143:1008];
            'd135:
                wantedPart = blurred_dout_FF[1151:1016];
            'd136:
                wantedPart = blurred_dout_FF[1159:1024];
            'd137:
                wantedPart = blurred_dout_FF[1167:1032];
            'd138:
                wantedPart = blurred_dout_FF[1175:1040];
            'd139:
                wantedPart = blurred_dout_FF[1183:1048];
            'd140:
                wantedPart = blurred_dout_FF[1191:1056];
            'd141:
                wantedPart = blurred_dout_FF[1199:1064];
            'd142:
                wantedPart = blurred_dout_FF[1207:1072];
            'd143:
                wantedPart = blurred_dout_FF[1215:1080];
            'd144:
                wantedPart = blurred_dout_FF[1223:1088];
            'd145:
                wantedPart = blurred_dout_FF[1231:1096];
            'd146:
                wantedPart = blurred_dout_FF[1239:1104];
            'd147:
                wantedPart = blurred_dout_FF[1247:1112];
            'd148:
                wantedPart = blurred_dout_FF[1255:1120];
            'd149:
                wantedPart = blurred_dout_FF[1263:1128];
            'd150:
                wantedPart = blurred_dout_FF[1271:1136];
            'd151:
                wantedPart = blurred_dout_FF[1279:1144];
            'd152:
                wantedPart = blurred_dout_FF[1287:1152];
            'd153:
                wantedPart = blurred_dout_FF[1295:1160];
            'd154:
                wantedPart = blurred_dout_FF[1303:1168];
            'd155:
                wantedPart = blurred_dout_FF[1311:1176];
            'd156:
                wantedPart = blurred_dout_FF[1319:1184];
            'd157:
                wantedPart = blurred_dout_FF[1327:1192];
            'd158:
                wantedPart = blurred_dout_FF[1335:1200];
            'd159:
                wantedPart = blurred_dout_FF[1343:1208];
            'd160:
                wantedPart = blurred_dout_FF[1351:1216];
            'd161:
                wantedPart = blurred_dout_FF[1359:1224];
            'd162:
                wantedPart = blurred_dout_FF[1367:1232];
            'd163:
                wantedPart = blurred_dout_FF[1375:1240];
            'd164:
                wantedPart = blurred_dout_FF[1383:1248];
            'd165:
                wantedPart = blurred_dout_FF[1391:1256];
            'd166:
                wantedPart = blurred_dout_FF[1399:1264];
            'd167:
                wantedPart = blurred_dout_FF[1407:1272];
            'd168:
                wantedPart = blurred_dout_FF[1415:1280];
            'd169:
                wantedPart = blurred_dout_FF[1423:1288];
            'd170:
                wantedPart = blurred_dout_FF[1431:1296];
            'd171:
                wantedPart = blurred_dout_FF[1439:1304];
            'd172:
                wantedPart = blurred_dout_FF[1447:1312];
            'd173:
                wantedPart = blurred_dout_FF[1455:1320];
            'd174:
                wantedPart = blurred_dout_FF[1463:1328];
            'd175:
                wantedPart = blurred_dout_FF[1471:1336];
            'd176:
                wantedPart = blurred_dout_FF[1479:1344];
            'd177:
                wantedPart = blurred_dout_FF[1487:1352];
            'd178:
                wantedPart = blurred_dout_FF[1495:1360];
            'd179:
                wantedPart = blurred_dout_FF[1503:1368];
            'd180:
                wantedPart = blurred_dout_FF[1511:1376];
            'd181:
                wantedPart = blurred_dout_FF[1519:1384];
            'd182:
                wantedPart = blurred_dout_FF[1527:1392];
            'd183:
                wantedPart = blurred_dout_FF[1535:1400];
            'd184:
                wantedPart = blurred_dout_FF[1543:1408];
            'd185:
                wantedPart = blurred_dout_FF[1551:1416];
            'd186:
                wantedPart = blurred_dout_FF[1559:1424];
            'd187:
                wantedPart = blurred_dout_FF[1567:1432];
            'd188:
                wantedPart = blurred_dout_FF[1575:1440];
            'd189:
                wantedPart = blurred_dout_FF[1583:1448];
            'd190:
                wantedPart = blurred_dout_FF[1591:1456];
            'd191:
                wantedPart = blurred_dout_FF[1599:1464];
            'd192:
                wantedPart = blurred_dout_FF[1607:1472];
            'd193:
                wantedPart = blurred_dout_FF[1615:1480];
            'd194:
                wantedPart = blurred_dout_FF[1623:1488];
            'd195:
                wantedPart = blurred_dout_FF[1631:1496];
            'd196:
                wantedPart = blurred_dout_FF[1639:1504];
            'd197:
                wantedPart = blurred_dout_FF[1647:1512];
            'd198:
                wantedPart = blurred_dout_FF[1655:1520];
            'd199:
                wantedPart = blurred_dout_FF[1663:1528];
            'd200:
                wantedPart = blurred_dout_FF[1671:1536];
            'd201:
                wantedPart = blurred_dout_FF[1679:1544];
            'd202:
                wantedPart = blurred_dout_FF[1687:1552];
            'd203:
                wantedPart = blurred_dout_FF[1695:1560];
            'd204:
                wantedPart = blurred_dout_FF[1703:1568];
            'd205:
                wantedPart = blurred_dout_FF[1711:1576];
            'd206:
                wantedPart = blurred_dout_FF[1719:1584];
            'd207:
                wantedPart = blurred_dout_FF[1727:1592];
            'd208:
                wantedPart = blurred_dout_FF[1735:1600];
            'd209:
                wantedPart = blurred_dout_FF[1743:1608];
            'd210:
                wantedPart = blurred_dout_FF[1751:1616];
            'd211:
                wantedPart = blurred_dout_FF[1759:1624];
            'd212:
                wantedPart = blurred_dout_FF[1767:1632];
            'd213:
                wantedPart = blurred_dout_FF[1775:1640];
            'd214:
                wantedPart = blurred_dout_FF[1783:1648];
            'd215:
                wantedPart = blurred_dout_FF[1791:1656];
            'd216:
                wantedPart = blurred_dout_FF[1799:1664];
            'd217:
                wantedPart = blurred_dout_FF[1807:1672];
            'd218:
                wantedPart = blurred_dout_FF[1815:1680];
            'd219:
                wantedPart = blurred_dout_FF[1823:1688];
            'd220:
                wantedPart = blurred_dout_FF[1831:1696];
            'd221:
                wantedPart = blurred_dout_FF[1839:1704];
            'd222:
                wantedPart = blurred_dout_FF[1847:1712];
            'd223:
                wantedPart = blurred_dout_FF[1855:1720];
            'd224:
                wantedPart = blurred_dout_FF[1863:1728];
            'd225:
                wantedPart = blurred_dout_FF[1871:1736];
            'd226:
                wantedPart = blurred_dout_FF[1879:1744];
            'd227:
                wantedPart = blurred_dout_FF[1887:1752];
            'd228:
                wantedPart = blurred_dout_FF[1895:1760];
            'd229:
                wantedPart = blurred_dout_FF[1903:1768];
            'd230:
                wantedPart = blurred_dout_FF[1911:1776];
            'd231:
                wantedPart = blurred_dout_FF[1919:1784];
            'd232:
                wantedPart = blurred_dout_FF[1927:1792];
            'd233:
                wantedPart = blurred_dout_FF[1935:1800];
            'd234:
                wantedPart = blurred_dout_FF[1943:1808];
            'd235:
                wantedPart = blurred_dout_FF[1951:1816];
            'd236:
                wantedPart = blurred_dout_FF[1959:1824];
            'd237:
                wantedPart = blurred_dout_FF[1967:1832];
            'd238:
                wantedPart = blurred_dout_FF[1975:1840];
            'd239:
                wantedPart = blurred_dout_FF[1983:1848];
            'd240:
                wantedPart = blurred_dout_FF[1991:1856];
            'd241:
                wantedPart = blurred_dout_FF[1999:1864];
            'd242:
                wantedPart = blurred_dout_FF[2007:1872];
            'd243:
                wantedPart = blurred_dout_FF[2015:1880];
            'd244:
                wantedPart = blurred_dout_FF[2023:1888];
            'd245:
                wantedPart = blurred_dout_FF[2031:1896];
            'd246:
                wantedPart = blurred_dout_FF[2039:1904];
            'd247:
                wantedPart = blurred_dout_FF[2047:1912];
            'd248:
                wantedPart = blurred_dout_FF[2055:1920];
            'd249:
                wantedPart = blurred_dout_FF[2063:1928];
            'd250:
                wantedPart = blurred_dout_FF[2071:1936];
            'd251:
                wantedPart = blurred_dout_FF[2079:1944];
            'd252:
                wantedPart = blurred_dout_FF[2087:1952];
            'd253:
                wantedPart = blurred_dout_FF[2095:1960];
            'd254:
                wantedPart = blurred_dout_FF[2103:1968];
            'd255:
                wantedPart = blurred_dout_FF[2111:1976];
            'd256:
                wantedPart = blurred_dout_FF[2119:1984];
            'd257:
                wantedPart = blurred_dout_FF[2127:1992];
            'd258:
                wantedPart = blurred_dout_FF[2135:2000];
            'd259:
                wantedPart = blurred_dout_FF[2143:2008];
            'd260:
                wantedPart = blurred_dout_FF[2151:2016];
            'd261:
                wantedPart = blurred_dout_FF[2159:2024];
            'd262:
                wantedPart = blurred_dout_FF[2167:2032];
            'd263:
                wantedPart = blurred_dout_FF[2175:2040];
            'd264:
                wantedPart = blurred_dout_FF[2183:2048];
            'd265:
                wantedPart = blurred_dout_FF[2191:2056];
            'd266:
                wantedPart = blurred_dout_FF[2199:2064];
            'd267:
                wantedPart = blurred_dout_FF[2207:2072];
            'd268:
                wantedPart = blurred_dout_FF[2215:2080];
            'd269:
                wantedPart = blurred_dout_FF[2223:2088];
            'd270:
                wantedPart = blurred_dout_FF[2231:2096];
            'd271:
                wantedPart = blurred_dout_FF[2239:2104];
            'd272:
                wantedPart = blurred_dout_FF[2247:2112];
            'd273:
                wantedPart = blurred_dout_FF[2255:2120];
            'd274:
                wantedPart = blurred_dout_FF[2263:2128];
            'd275:
                wantedPart = blurred_dout_FF[2271:2136];
            'd276:
                wantedPart = blurred_dout_FF[2279:2144];
            'd277:
                wantedPart = blurred_dout_FF[2287:2152];
            'd278:
                wantedPart = blurred_dout_FF[2295:2160];
            'd279:
                wantedPart = blurred_dout_FF[2303:2168];
            'd280:
                wantedPart = blurred_dout_FF[2311:2176];
            'd281:
                wantedPart = blurred_dout_FF[2319:2184];
            'd282:
                wantedPart = blurred_dout_FF[2327:2192];
            'd283:
                wantedPart = blurred_dout_FF[2335:2200];
            'd284:
                wantedPart = blurred_dout_FF[2343:2208];
            'd285:
                wantedPart = blurred_dout_FF[2351:2216];
            'd286:
                wantedPart = blurred_dout_FF[2359:2224];
            'd287:
                wantedPart = blurred_dout_FF[2367:2232];
            'd288:
                wantedPart = blurred_dout_FF[2375:2240];
            'd289:
                wantedPart = blurred_dout_FF[2383:2248];
            'd290:
                wantedPart = blurred_dout_FF[2391:2256];
            'd291:
                wantedPart = blurred_dout_FF[2399:2264];
            'd292:
                wantedPart = blurred_dout_FF[2407:2272];
            'd293:
                wantedPart = blurred_dout_FF[2415:2280];
            'd294:
                wantedPart = blurred_dout_FF[2423:2288];
            'd295:
                wantedPart = blurred_dout_FF[2431:2296];
            'd296:
                wantedPart = blurred_dout_FF[2439:2304];
            'd297:
                wantedPart = blurred_dout_FF[2447:2312];
            'd298:
                wantedPart = blurred_dout_FF[2455:2320];
            'd299:
                wantedPart = blurred_dout_FF[2463:2328];
            'd300:
                wantedPart = blurred_dout_FF[2471:2336];
            'd301:
                wantedPart = blurred_dout_FF[2479:2344];
            'd302:
                wantedPart = blurred_dout_FF[2487:2352];
            'd303:
                wantedPart = blurred_dout_FF[2495:2360];
            'd304:
                wantedPart = blurred_dout_FF[2503:2368];
            'd305:
                wantedPart = blurred_dout_FF[2511:2376];
            'd306:
                wantedPart = blurred_dout_FF[2519:2384];
            'd307:
                wantedPart = blurred_dout_FF[2527:2392];
            'd308:
                wantedPart = blurred_dout_FF[2535:2400];
            'd309:
                wantedPart = blurred_dout_FF[2543:2408];
            'd310:
                wantedPart = blurred_dout_FF[2551:2416];
            'd311:
                wantedPart = blurred_dout_FF[2559:2424];
            'd312:
                wantedPart = blurred_dout_FF[2567:2432];
            'd313:
                wantedPart = blurred_dout_FF[2575:2440];
            'd314:
                wantedPart = blurred_dout_FF[2583:2448];
            'd315:
                wantedPart = blurred_dout_FF[2591:2456];
            'd316:
                wantedPart = blurred_dout_FF[2599:2464];
            'd317:
                wantedPart = blurred_dout_FF[2607:2472];
            'd318:
                wantedPart = blurred_dout_FF[2615:2480];
            'd319:
                wantedPart = blurred_dout_FF[2623:2488];
            'd320:
                wantedPart = blurred_dout_FF[2631:2496];
            'd321:
                wantedPart = blurred_dout_FF[2639:2504];
            'd322:
                wantedPart = blurred_dout_FF[2647:2512];
            'd323:
                wantedPart = blurred_dout_FF[2655:2520];
            'd324:
                wantedPart = blurred_dout_FF[2663:2528];
            'd325:
                wantedPart = blurred_dout_FF[2671:2536];
            'd326:
                wantedPart = blurred_dout_FF[2679:2544];
            'd327:
                wantedPart = blurred_dout_FF[2687:2552];
            'd328:
                wantedPart = blurred_dout_FF[2695:2560];
            'd329:
                wantedPart = blurred_dout_FF[2703:2568];
            'd330:
                wantedPart = blurred_dout_FF[2711:2576];
            'd331:
                wantedPart = blurred_dout_FF[2719:2584];
            'd332:
                wantedPart = blurred_dout_FF[2727:2592];
            'd333:
                wantedPart = blurred_dout_FF[2735:2600];
            'd334:
                wantedPart = blurred_dout_FF[2743:2608];
            'd335:
                wantedPart = blurred_dout_FF[2751:2616];
            'd336:
                wantedPart = blurred_dout_FF[2759:2624];
            'd337:
                wantedPart = blurred_dout_FF[2767:2632];
            'd338:
                wantedPart = blurred_dout_FF[2775:2640];
            'd339:
                wantedPart = blurred_dout_FF[2783:2648];
            'd340:
                wantedPart = blurred_dout_FF[2791:2656];
            'd341:
                wantedPart = blurred_dout_FF[2799:2664];
            'd342:
                wantedPart = blurred_dout_FF[2807:2672];
            'd343:
                wantedPart = blurred_dout_FF[2815:2680];
            'd344:
                wantedPart = blurred_dout_FF[2823:2688];
            'd345:
                wantedPart = blurred_dout_FF[2831:2696];
            'd346:
                wantedPart = blurred_dout_FF[2839:2704];
            'd347:
                wantedPart = blurred_dout_FF[2847:2712];
            'd348:
                wantedPart = blurred_dout_FF[2855:2720];
            'd349:
                wantedPart = blurred_dout_FF[2863:2728];
            'd350:
                wantedPart = blurred_dout_FF[2871:2736];
            'd351:
                wantedPart = blurred_dout_FF[2879:2744];
            'd352:
                wantedPart = blurred_dout_FF[2887:2752];
            'd353:
                wantedPart = blurred_dout_FF[2895:2760];
            'd354:
                wantedPart = blurred_dout_FF[2903:2768];
            'd355:
                wantedPart = blurred_dout_FF[2911:2776];
            'd356:
                wantedPart = blurred_dout_FF[2919:2784];
            'd357:
                wantedPart = blurred_dout_FF[2927:2792];
            'd358:
                wantedPart = blurred_dout_FF[2935:2800];
            'd359:
                wantedPart = blurred_dout_FF[2943:2808];
            'd360:
                wantedPart = blurred_dout_FF[2951:2816];
            'd361:
                wantedPart = blurred_dout_FF[2959:2824];
            'd362:
                wantedPart = blurred_dout_FF[2967:2832];
            'd363:
                wantedPart = blurred_dout_FF[2975:2840];
            'd364:
                wantedPart = blurred_dout_FF[2983:2848];
            'd365:
                wantedPart = blurred_dout_FF[2991:2856];
            'd366:
                wantedPart = blurred_dout_FF[2999:2864];
            'd367:
                wantedPart = blurred_dout_FF[3007:2872];
            'd368:
                wantedPart = blurred_dout_FF[3015:2880];
            'd369:
                wantedPart = blurred_dout_FF[3023:2888];
            'd370:
                wantedPart = blurred_dout_FF[3031:2896];
            'd371:
                wantedPart = blurred_dout_FF[3039:2904];
            'd372:
                wantedPart = blurred_dout_FF[3047:2912];
            'd373:
                wantedPart = blurred_dout_FF[3055:2920];
            'd374:
                wantedPart = blurred_dout_FF[3063:2928];
            'd375:
                wantedPart = blurred_dout_FF[3071:2936];
            'd376:
                wantedPart = blurred_dout_FF[3079:2944];
            'd377:
                wantedPart = blurred_dout_FF[3087:2952];
            'd378:
                wantedPart = blurred_dout_FF[3095:2960];
            'd379:
                wantedPart = blurred_dout_FF[3103:2968];
            'd380:
                wantedPart = blurred_dout_FF[3111:2976];
            'd381:
                wantedPart = blurred_dout_FF[3119:2984];
            'd382:
                wantedPart = blurred_dout_FF[3127:2992];
            'd383:
                wantedPart = blurred_dout_FF[3135:3000];
            'd384:
                wantedPart = blurred_dout_FF[3143:3008];
            'd385:
                wantedPart = blurred_dout_FF[3151:3016];
            'd386:
                wantedPart = blurred_dout_FF[3159:3024];
            'd387:
                wantedPart = blurred_dout_FF[3167:3032];
            'd388:
                wantedPart = blurred_dout_FF[3175:3040];
            'd389:
                wantedPart = blurred_dout_FF[3183:3048];
            'd390:
                wantedPart = blurred_dout_FF[3191:3056];
            'd391:
                wantedPart = blurred_dout_FF[3199:3064];
            'd392:
                wantedPart = blurred_dout_FF[3207:3072];
            'd393:
                wantedPart = blurred_dout_FF[3215:3080];
            'd394:
                wantedPart = blurred_dout_FF[3223:3088];
            'd395:
                wantedPart = blurred_dout_FF[3231:3096];
            'd396:
                wantedPart = blurred_dout_FF[3239:3104];
            'd397:
                wantedPart = blurred_dout_FF[3247:3112];
            'd398:
                wantedPart = blurred_dout_FF[3255:3120];
            'd399:
                wantedPart = blurred_dout_FF[3263:3128];
            'd400:
                wantedPart = blurred_dout_FF[3271:3136];
            'd401:
                wantedPart = blurred_dout_FF[3279:3144];
            'd402:
                wantedPart = blurred_dout_FF[3287:3152];
            'd403:
                wantedPart = blurred_dout_FF[3295:3160];
            'd404:
                wantedPart = blurred_dout_FF[3303:3168];
            'd405:
                wantedPart = blurred_dout_FF[3311:3176];
            'd406:
                wantedPart = blurred_dout_FF[3319:3184];
            'd407:
                wantedPart = blurred_dout_FF[3327:3192];
            'd408:
                wantedPart = blurred_dout_FF[3335:3200];
            'd409:
                wantedPart = blurred_dout_FF[3343:3208];
            'd410:
                wantedPart = blurred_dout_FF[3351:3216];
            'd411:
                wantedPart = blurred_dout_FF[3359:3224];
            'd412:
                wantedPart = blurred_dout_FF[3367:3232];
            'd413:
                wantedPart = blurred_dout_FF[3375:3240];
            'd414:
                wantedPart = blurred_dout_FF[3383:3248];
            'd415:
                wantedPart = blurred_dout_FF[3391:3256];
            'd416:
                wantedPart = blurred_dout_FF[3399:3264];
            'd417:
                wantedPart = blurred_dout_FF[3407:3272];
            'd418:
                wantedPart = blurred_dout_FF[3415:3280];
            'd419:
                wantedPart = blurred_dout_FF[3423:3288];
            'd420:
                wantedPart = blurred_dout_FF[3431:3296];
            'd421:
                wantedPart = blurred_dout_FF[3439:3304];
            'd422:
                wantedPart = blurred_dout_FF[3447:3312];
            'd423:
                wantedPart = blurred_dout_FF[3455:3320];
            'd424:
                wantedPart = blurred_dout_FF[3463:3328];
            'd425:
                wantedPart = blurred_dout_FF[3471:3336];
            'd426:
                wantedPart = blurred_dout_FF[3479:3344];
            'd427:
                wantedPart = blurred_dout_FF[3487:3352];
            'd428:
                wantedPart = blurred_dout_FF[3495:3360];
            'd429:
                wantedPart = blurred_dout_FF[3503:3368];
            'd430:
                wantedPart = blurred_dout_FF[3511:3376];
            'd431:
                wantedPart = blurred_dout_FF[3519:3384];
            'd432:
                wantedPart = blurred_dout_FF[3527:3392];
            'd433:
                wantedPart = blurred_dout_FF[3535:3400];
            'd434:
                wantedPart = blurred_dout_FF[3543:3408];
            'd435:
                wantedPart = blurred_dout_FF[3551:3416];
            'd436:
                wantedPart = blurred_dout_FF[3559:3424];
            'd437:
                wantedPart = blurred_dout_FF[3567:3432];
            'd438:
                wantedPart = blurred_dout_FF[3575:3440];
            'd439:
                wantedPart = blurred_dout_FF[3583:3448];
            'd440:
                wantedPart = blurred_dout_FF[3591:3456];
            'd441:
                wantedPart = blurred_dout_FF[3599:3464];
            'd442:
                wantedPart = blurred_dout_FF[3607:3472];
            'd443:
                wantedPart = blurred_dout_FF[3615:3480];
            'd444:
                wantedPart = blurred_dout_FF[3623:3488];
            'd445:
                wantedPart = blurred_dout_FF[3631:3496];
            'd446:
                wantedPart = blurred_dout_FF[3639:3504];
            'd447:
                wantedPart = blurred_dout_FF[3647:3512];
            'd448:
                wantedPart = blurred_dout_FF[3655:3520];
            'd449:
                wantedPart = blurred_dout_FF[3663:3528];
            'd450:
                wantedPart = blurred_dout_FF[3671:3536];
            'd451:
                wantedPart = blurred_dout_FF[3679:3544];
            'd452:
                wantedPart = blurred_dout_FF[3687:3552];
            'd453:
                wantedPart = blurred_dout_FF[3695:3560];
            'd454:
                wantedPart = blurred_dout_FF[3703:3568];
            'd455:
                wantedPart = blurred_dout_FF[3711:3576];
            'd456:
                wantedPart = blurred_dout_FF[3719:3584];
            'd457:
                wantedPart = blurred_dout_FF[3727:3592];
            'd458:
                wantedPart = blurred_dout_FF[3735:3600];
            'd459:
                wantedPart = blurred_dout_FF[3743:3608];
            'd460:
                wantedPart = blurred_dout_FF[3751:3616];
            'd461:
                wantedPart = blurred_dout_FF[3759:3624];
            'd462:
                wantedPart = blurred_dout_FF[3767:3632];
            'd463:
                wantedPart = blurred_dout_FF[3775:3640];
            'd464:
                wantedPart = blurred_dout_FF[3783:3648];
            'd465:
                wantedPart = blurred_dout_FF[3791:3656];
            'd466:
                wantedPart = blurred_dout_FF[3799:3664];
            'd467:
                wantedPart = blurred_dout_FF[3807:3672];
            'd468:
                wantedPart = blurred_dout_FF[3815:3680];
            'd469:
                wantedPart = blurred_dout_FF[3823:3688];
            'd470:
                wantedPart = blurred_dout_FF[3831:3696];
            'd471:
                wantedPart = blurred_dout_FF[3839:3704];
            'd472:
                wantedPart = blurred_dout_FF[3847:3712];
            'd473:
                wantedPart = blurred_dout_FF[3855:3720];
            'd474:
                wantedPart = blurred_dout_FF[3863:3728];
            'd475:
                wantedPart = blurred_dout_FF[3871:3736];
            'd476:
                wantedPart = blurred_dout_FF[3879:3744];
            'd477:
                wantedPart = blurred_dout_FF[3887:3752];
            'd478:
                wantedPart = blurred_dout_FF[3895:3760];
            'd479:
                wantedPart = blurred_dout_FF[3903:3768];
            'd480:
                wantedPart = blurred_dout_FF[3911:3776];
            'd481:
                wantedPart = blurred_dout_FF[3919:3784];
            'd482:
                wantedPart = blurred_dout_FF[3927:3792];
            'd483:
                wantedPart = blurred_dout_FF[3935:3800];
            'd484:
                wantedPart = blurred_dout_FF[3943:3808];
            'd485:
                wantedPart = blurred_dout_FF[3951:3816];
            'd486:
                wantedPart = blurred_dout_FF[3959:3824];
            'd487:
                wantedPart = blurred_dout_FF[3967:3832];
            'd488:
                wantedPart = blurred_dout_FF[3975:3840];
            'd489:
                wantedPart = blurred_dout_FF[3983:3848];
            'd490:
                wantedPart = blurred_dout_FF[3991:3856];
            'd491:
                wantedPart = blurred_dout_FF[3999:3864];
            'd492:
                wantedPart = blurred_dout_FF[4007:3872];
            'd493:
                wantedPart = blurred_dout_FF[4015:3880];
            'd494:
                wantedPart = blurred_dout_FF[4023:3888];
            'd495:
                wantedPart = blurred_dout_FF[4031:3896];
            'd496:
                wantedPart = blurred_dout_FF[4039:3904];
            'd497:
                wantedPart = blurred_dout_FF[4047:3912];
            'd498:
                wantedPart = blurred_dout_FF[4055:3920];
            'd499:
                wantedPart = blurred_dout_FF[4063:3928];
            'd500:
                wantedPart = blurred_dout_FF[4071:3936];
            'd501:
                wantedPart = blurred_dout_FF[4079:3944];
            'd502:
                wantedPart = blurred_dout_FF[4087:3952];
            'd503:
                wantedPart = blurred_dout_FF[4095:3960];
            'd504:
                wantedPart = blurred_dout_FF[4103:3968];
            'd505:
                wantedPart = blurred_dout_FF[4111:3976];
            'd506:
                wantedPart = blurred_dout_FF[4119:3984];
            'd507:
                wantedPart = blurred_dout_FF[4127:3992];
            'd508:
                wantedPart = blurred_dout_FF[4135:4000];
            'd509:
                wantedPart = blurred_dout_FF[4143:4008];
            'd510:
                wantedPart = blurred_dout_FF[4151:4016];
            'd511:
                wantedPart = blurred_dout_FF[4159:4024];
            'd512:
                wantedPart = blurred_dout_FF[4167:4032];
            'd513:
                wantedPart = blurred_dout_FF[4175:4040];
            'd514:
                wantedPart = blurred_dout_FF[4183:4048];
            'd515:
                wantedPart = blurred_dout_FF[4191:4056];
            'd516:
                wantedPart = blurred_dout_FF[4199:4064];
            'd517:
                wantedPart = blurred_dout_FF[4207:4072];
            'd518:
                wantedPart = blurred_dout_FF[4215:4080];
            'd519:
                wantedPart = blurred_dout_FF[4223:4088];
            'd520:
                wantedPart = blurred_dout_FF[4231:4096];
            'd521:
                wantedPart = blurred_dout_FF[4239:4104];
            'd522:
                wantedPart = blurred_dout_FF[4247:4112];
            'd523:
                wantedPart = blurred_dout_FF[4255:4120];
            'd524:
                wantedPart = blurred_dout_FF[4263:4128];
            'd525:
                wantedPart = blurred_dout_FF[4271:4136];
            'd526:
                wantedPart = blurred_dout_FF[4279:4144];
            'd527:
                wantedPart = blurred_dout_FF[4287:4152];
            'd528:
                wantedPart = blurred_dout_FF[4295:4160];
            'd529:
                wantedPart = blurred_dout_FF[4303:4168];
            'd530:
                wantedPart = blurred_dout_FF[4311:4176];
            'd531:
                wantedPart = blurred_dout_FF[4319:4184];
            'd532:
                wantedPart = blurred_dout_FF[4327:4192];
            'd533:
                wantedPart = blurred_dout_FF[4335:4200];
            'd534:
                wantedPart = blurred_dout_FF[4343:4208];
            'd535:
                wantedPart = blurred_dout_FF[4351:4216];
            'd536:
                wantedPart = blurred_dout_FF[4359:4224];
            'd537:
                wantedPart = blurred_dout_FF[4367:4232];
            'd538:
                wantedPart = blurred_dout_FF[4375:4240];
            'd539:
                wantedPart = blurred_dout_FF[4383:4248];
            'd540:
                wantedPart = blurred_dout_FF[4391:4256];
            'd541:
                wantedPart = blurred_dout_FF[4399:4264];
            'd542:
                wantedPart = blurred_dout_FF[4407:4272];
            'd543:
                wantedPart = blurred_dout_FF[4415:4280];
            'd544:
                wantedPart = blurred_dout_FF[4423:4288];
            'd545:
                wantedPart = blurred_dout_FF[4431:4296];
            'd546:
                wantedPart = blurred_dout_FF[4439:4304];
            'd547:
                wantedPart = blurred_dout_FF[4447:4312];
            'd548:
                wantedPart = blurred_dout_FF[4455:4320];
            'd549:
                wantedPart = blurred_dout_FF[4463:4328];
            'd550:
                wantedPart = blurred_dout_FF[4471:4336];
            'd551:
                wantedPart = blurred_dout_FF[4479:4344];
            'd552:
                wantedPart = blurred_dout_FF[4487:4352];
            'd553:
                wantedPart = blurred_dout_FF[4495:4360];
            'd554:
                wantedPart = blurred_dout_FF[4503:4368];
            'd555:
                wantedPart = blurred_dout_FF[4511:4376];
            'd556:
                wantedPart = blurred_dout_FF[4519:4384];
            'd557:
                wantedPart = blurred_dout_FF[4527:4392];
            'd558:
                wantedPart = blurred_dout_FF[4535:4400];
            'd559:
                wantedPart = blurred_dout_FF[4543:4408];
            'd560:
                wantedPart = blurred_dout_FF[4551:4416];
            'd561:
                wantedPart = blurred_dout_FF[4559:4424];
            'd562:
                wantedPart = blurred_dout_FF[4567:4432];
            'd563:
                wantedPart = blurred_dout_FF[4575:4440];
            'd564:
                wantedPart = blurred_dout_FF[4583:4448];
            'd565:
                wantedPart = blurred_dout_FF[4591:4456];
            'd566:
                wantedPart = blurred_dout_FF[4599:4464];
            'd567:
                wantedPart = blurred_dout_FF[4607:4472];
            'd568:
                wantedPart = blurred_dout_FF[4615:4480];
            'd569:
                wantedPart = blurred_dout_FF[4623:4488];
            'd570:
                wantedPart = blurred_dout_FF[4631:4496];
            'd571:
                wantedPart = blurred_dout_FF[4639:4504];
            'd572:
                wantedPart = blurred_dout_FF[4647:4512];
            'd573:
                wantedPart = blurred_dout_FF[4655:4520];
            'd574:
                wantedPart = blurred_dout_FF[4663:4528];
            'd575:
                wantedPart = blurred_dout_FF[4671:4536];
            'd576:
                wantedPart = blurred_dout_FF[4679:4544];
            'd577:
                wantedPart = blurred_dout_FF[4687:4552];
            'd578:
                wantedPart = blurred_dout_FF[4695:4560];
            'd579:
                wantedPart = blurred_dout_FF[4703:4568];
            'd580:
                wantedPart = blurred_dout_FF[4711:4576];
            'd581:
                wantedPart = blurred_dout_FF[4719:4584];
            'd582:
                wantedPart = blurred_dout_FF[4727:4592];
            'd583:
                wantedPart = blurred_dout_FF[4735:4600];
            'd584:
                wantedPart = blurred_dout_FF[4743:4608];
            'd585:
                wantedPart = blurred_dout_FF[4751:4616];
            'd586:
                wantedPart = blurred_dout_FF[4759:4624];
            'd587:
                wantedPart = blurred_dout_FF[4767:4632];
            'd588:
                wantedPart = blurred_dout_FF[4775:4640];
            'd589:
                wantedPart = blurred_dout_FF[4783:4648];
            'd590:
                wantedPart = blurred_dout_FF[4791:4656];
            'd591:
                wantedPart = blurred_dout_FF[4799:4664];
            'd592:
                wantedPart = blurred_dout_FF[4807:4672];
            'd593:
                wantedPart = blurred_dout_FF[4815:4680];
            'd594:
                wantedPart = blurred_dout_FF[4823:4688];
            'd595:
                wantedPart = blurred_dout_FF[4831:4696];
            'd596:
                wantedPart = blurred_dout_FF[4839:4704];
            'd597:
                wantedPart = blurred_dout_FF[4847:4712];
            'd598:
                wantedPart = blurred_dout_FF[4855:4720];
            'd599:
                wantedPart = blurred_dout_FF[4863:4728];
            'd600:
                wantedPart = blurred_dout_FF[4871:4736];
            'd601:
                wantedPart = blurred_dout_FF[4879:4744];
            'd602:
                wantedPart = blurred_dout_FF[4887:4752];
            'd603:
                wantedPart = blurred_dout_FF[4895:4760];
            'd604:
                wantedPart = blurred_dout_FF[4903:4768];
            'd605:
                wantedPart = blurred_dout_FF[4911:4776];
            'd606:
                wantedPart = blurred_dout_FF[4919:4784];
            'd607:
                wantedPart = blurred_dout_FF[4927:4792];
            'd608:
                wantedPart = blurred_dout_FF[4935:4800];
            'd609:
                wantedPart = blurred_dout_FF[4943:4808];
            'd610:
                wantedPart = blurred_dout_FF[4951:4816];
            'd611:
                wantedPart = blurred_dout_FF[4959:4824];
            'd612:
                wantedPart = blurred_dout_FF[4967:4832];
            'd613:
                wantedPart = blurred_dout_FF[4975:4840];
            'd614:
                wantedPart = blurred_dout_FF[4983:4848];
            'd615:
                wantedPart = blurred_dout_FF[4991:4856];
            'd616:
                wantedPart = blurred_dout_FF[4999:4864];
            'd617:
                wantedPart = blurred_dout_FF[5007:4872];
            'd618:
                wantedPart = blurred_dout_FF[5015:4880];
            'd619:
                wantedPart = blurred_dout_FF[5023:4888];
            'd620:
                wantedPart = blurred_dout_FF[5031:4896];
            'd621:
                wantedPart = blurred_dout_FF[5039:4904];
            'd622:
                wantedPart = blurred_dout_FF[5047:4912];
            'd623:
                wantedPart = blurred_dout_FF[5055:4920];
            'd624:
                wantedPart = blurred_dout_FF[5063:4928];
            'd625:
                wantedPart = blurred_dout_FF[5071:4936];
            'd626:
                wantedPart = blurred_dout_FF[5079:4944];
            'd627:
                wantedPart = blurred_dout_FF[5087:4952];
            'd628:
                wantedPart = blurred_dout_FF[5095:4960];
            'd629:
                wantedPart = blurred_dout_FF[5103:4968];
            'd630:
                wantedPart = blurred_dout_FF[5111:4976];
            'd631:
                wantedPart = blurred_dout_FF[5119:4984];
            default:
                wantedPart = {136{1'b0}};
        
        endcase
    
    end
    
    always @(posedge clk) begin //buffer_0, buffer_1, buffer_2
                                  
        if(!rst_n) begin          
            buffer_0 <= 'd0;
            buffer_1 <= 'd0;
            buffer_2 <= 'd0;
        end
        else begin
            buffer_0 <= wantedPart;
            buffer_1 <= buffer_0;
            buffer_2 <= buffer_1;
        end
        
    end
    
    always @(posedge clk) begin //inner_row_col_descpt1
    
        if(!rst_n)
            inner_row_col_descpt1 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d0)
            inner_row_col_descpt1 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d0 && cycle_count=='d10)
            inner_row_col_descpt1 <= { inner_row_col_descpt1[402:384], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72],
                                                                       dim1_bin_2 + row_accu_result1[71:60],
                                                                       dim1_bin_3 + row_accu_result1[59:48],
                                                                       dim1_bin_4 + row_accu_result1[47:36],
                                                                       dim1_bin_5 + row_accu_result1[35:24],
                                                                       dim1_bin_6 + row_accu_result1[23:12],
                                                                       dim1_bin_7 + row_accu_result1[11:0 ],
                                                                       dim2_bin_0 + row_accu_result2[95:84],
                                                                       dim2_bin_1 + row_accu_result2[83:72],
                                                                       dim2_bin_2 + row_accu_result2[71:60],
                                                                       dim2_bin_3 + row_accu_result2[59:48],
                                                                       dim2_bin_4 + row_accu_result2[47:36],
                                                                       dim2_bin_5 + row_accu_result2[35:24],
                                                                       dim2_bin_6 + row_accu_result2[23:12],
                                                                       dim2_bin_7 + row_accu_result2[11:0 ],
                                                                       {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d0 && cycle_count=='d17)
            inner_row_col_descpt1 <= { inner_row_col_descpt1[402:192], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72],
                                                                       dim1_bin_2 + row_accu_result1[71:60],
                                                                       dim1_bin_3 + row_accu_result1[59:48],
                                                                       dim1_bin_4 + row_accu_result1[47:36],
                                                                       dim1_bin_5 + row_accu_result1[35:24],
                                                                       dim1_bin_6 + row_accu_result1[23:12],
                                                                       dim1_bin_7 + row_accu_result1[11:0 ],
                                                                       dim2_bin_0 + row_accu_result2[95:84],
                                                                       dim2_bin_1 + row_accu_result2[83:72],
                                                                       dim2_bin_2 + row_accu_result2[71:60],
                                                                       dim2_bin_3 + row_accu_result2[59:48],
                                                                       dim2_bin_4 + row_accu_result2[47:36],
                                                                       dim2_bin_5 + row_accu_result2[35:24],
                                                                       dim2_bin_6 + row_accu_result2[23:12],
                                                                       dim2_bin_7 + row_accu_result2[11:0 ]
                                                                       };//write last 16 dims
        else
            inner_row_col_descpt1 <= inner_row_col_descpt1;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt2
    
        if(!rst_n)
            inner_row_col_descpt2 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d1)
            inner_row_col_descpt2 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d1 && cycle_count=='d10)
            inner_row_col_descpt2 <= { inner_row_col_descpt2[402:384], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72], 
                                                                       dim1_bin_2 + row_accu_result1[71:60], 
                                                                       dim1_bin_3 + row_accu_result1[59:48], 
                                                                       dim1_bin_4 + row_accu_result1[47:36], 
                                                                       dim1_bin_5 + row_accu_result1[35:24], 
                                                                       dim1_bin_6 + row_accu_result1[23:12], 
                                                                       dim1_bin_7 + row_accu_result1[11:0 ], 
                                                                       dim2_bin_0 + row_accu_result2[95:84], 
                                                                       dim2_bin_1 + row_accu_result2[83:72], 
                                                                       dim2_bin_2 + row_accu_result2[71:60], 
                                                                       dim2_bin_3 + row_accu_result2[59:48], 
                                                                       dim2_bin_4 + row_accu_result2[47:36], 
                                                                       dim2_bin_5 + row_accu_result2[35:24], 
                                                                       dim2_bin_6 + row_accu_result2[23:12], 
                                                                       dim2_bin_7 + row_accu_result2[11:0 ], 
                                                                       {192{1'b0}} };//write first row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d1 && cycle_count=='d17)
            inner_row_col_descpt2 <= { inner_row_col_descpt2[402:192], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72],
                                                                       dim1_bin_2 + row_accu_result1[71:60],
                                                                       dim1_bin_3 + row_accu_result1[59:48],
                                                                       dim1_bin_4 + row_accu_result1[47:36],
                                                                       dim1_bin_5 + row_accu_result1[35:24],
                                                                       dim1_bin_6 + row_accu_result1[23:12],
                                                                       dim1_bin_7 + row_accu_result1[11:0 ],
                                                                       dim2_bin_0 + row_accu_result2[95:84],
                                                                       dim2_bin_1 + row_accu_result2[83:72],
                                                                       dim2_bin_2 + row_accu_result2[71:60],
                                                                       dim2_bin_3 + row_accu_result2[59:48],
                                                                       dim2_bin_4 + row_accu_result2[47:36],
                                                                       dim2_bin_5 + row_accu_result2[35:24],
                                                                       dim2_bin_6 + row_accu_result2[23:12],
                                                                       dim2_bin_7 + row_accu_result2[11:0 ]
                                                                       };//write last row col
        else
            inner_row_col_descpt2 <= inner_row_col_descpt2;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt3
    
        if(!rst_n)
            inner_row_col_descpt3 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d2)
            inner_row_col_descpt3 <= { kptRowCol_FF, {384{1'b0}} };//wirte row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d2 && cycle_count=='d10)
            inner_row_col_descpt3 <= { inner_row_col_descpt3[402:384], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72], 
                                                                       dim1_bin_2 + row_accu_result1[71:60], 
                                                                       dim1_bin_3 + row_accu_result1[59:48], 
                                                                       dim1_bin_4 + row_accu_result1[47:36], 
                                                                       dim1_bin_5 + row_accu_result1[35:24], 
                                                                       dim1_bin_6 + row_accu_result1[23:12], 
                                                                       dim1_bin_7 + row_accu_result1[11:0 ], 
                                                                       dim2_bin_0 + row_accu_result2[95:84], 
                                                                       dim2_bin_1 + row_accu_result2[83:72], 
                                                                       dim2_bin_2 + row_accu_result2[71:60], 
                                                                       dim2_bin_3 + row_accu_result2[59:48], 
                                                                       dim2_bin_4 + row_accu_result2[47:36], 
                                                                       dim2_bin_5 + row_accu_result2[35:24], 
                                                                       dim2_bin_6 + row_accu_result2[23:12], 
                                                                       dim2_bin_7 + row_accu_result2[11:0 ], 
                                                                       {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d2 && cycle_count=='d17)
            inner_row_col_descpt3 <= { inner_row_col_descpt3[402:192], dim1_bin_0 + row_accu_result1[95:84], 
                                                                       dim1_bin_1 + row_accu_result1[83:72], 
                                                                       dim1_bin_2 + row_accu_result1[71:60], 
                                                                       dim1_bin_3 + row_accu_result1[59:48], 
                                                                       dim1_bin_4 + row_accu_result1[47:36], 
                                                                       dim1_bin_5 + row_accu_result1[35:24], 
                                                                       dim1_bin_6 + row_accu_result1[23:12], 
                                                                       dim1_bin_7 + row_accu_result1[11:0 ], 
                                                                       dim2_bin_0 + row_accu_result2[95:84], 
                                                                       dim2_bin_1 + row_accu_result2[83:72], 
                                                                       dim2_bin_2 + row_accu_result2[71:60], 
                                                                       dim2_bin_3 + row_accu_result2[59:48], 
                                                                       dim2_bin_4 + row_accu_result2[47:36], 
                                                                       dim2_bin_5 + row_accu_result2[35:24], 
                                                                       dim2_bin_6 + row_accu_result2[23:12], 
                                                                       dim2_bin_7 + row_accu_result2[11:0 ]
                                                                       };//write last 16 dims
        else
            inner_row_col_descpt3 <= inner_row_col_descpt3;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt4
    
        if(!rst_n)
            inner_row_col_descpt4 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d3)
            inner_row_col_descpt4 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d3 && cycle_count=='d10)
            inner_row_col_descpt4 <= { inner_row_col_descpt4[402:384], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72], 
                                                                       dim1_bin_2 + row_accu_result1[71:60], 
                                                                       dim1_bin_3 + row_accu_result1[59:48], 
                                                                       dim1_bin_4 + row_accu_result1[47:36], 
                                                                       dim1_bin_5 + row_accu_result1[35:24], 
                                                                       dim1_bin_6 + row_accu_result1[23:12], 
                                                                       dim1_bin_7 + row_accu_result1[11:0 ], 
                                                                       dim2_bin_0 + row_accu_result2[95:84], 
                                                                       dim2_bin_1 + row_accu_result2[83:72], 
                                                                       dim2_bin_2 + row_accu_result2[71:60], 
                                                                       dim2_bin_3 + row_accu_result2[59:48], 
                                                                       dim2_bin_4 + row_accu_result2[47:36], 
                                                                       dim2_bin_5 + row_accu_result2[35:24], 
                                                                       dim2_bin_6 + row_accu_result2[23:12], 
                                                                       dim2_bin_7 + row_accu_result2[11:0 ], 
                                                                       {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d3 && cycle_count=='d17)
            inner_row_col_descpt4 <= { inner_row_col_descpt4[402:192], dim1_bin_0 + row_accu_result1[95:84],
                                                                       dim1_bin_1 + row_accu_result1[83:72],
                                                                       dim1_bin_2 + row_accu_result1[71:60],
                                                                       dim1_bin_3 + row_accu_result1[59:48],
                                                                       dim1_bin_4 + row_accu_result1[47:36],
                                                                       dim1_bin_5 + row_accu_result1[35:24],
                                                                       dim1_bin_6 + row_accu_result1[23:12],
                                                                       dim1_bin_7 + row_accu_result1[11:0 ],
                                                                       dim2_bin_0 + row_accu_result2[95:84],
                                                                       dim2_bin_1 + row_accu_result2[83:72],
                                                                       dim2_bin_2 + row_accu_result2[71:60],
                                                                       dim2_bin_3 + row_accu_result2[59:48],
                                                                       dim2_bin_4 + row_accu_result2[47:36],
                                                                       dim2_bin_5 + row_accu_result2[35:24],
                                                                       dim2_bin_6 + row_accu_result2[23:12],
                                                                       dim2_bin_7 + row_accu_result2[11:0 ]
                                                                       };//write last 16 dims
        else
            inner_row_col_descpt4 <= inner_row_col_descpt4;
    
    end
    
    //always @(posedge clk) begin //accu_8_dim_1, accu_8_dim_2
    //
    //    if(!rst_n) begin
    //        accu_8_dim_1 <= 'd0;
    //        accu_8_dim_2 <= 'd0;
    //    end
    //    else if(cs == ST_WAITING_BLUR) begin
    //        accu_8_dim_1 <= 'd0;
    //        accu_8_dim_2 <= 'd0;
    //    end
    //    else if(cycle_count == 'd10) begin
    //        accu_8_dim_1 <= row_accu_result1;
    //        accu_8_dim_2 <= row_accu_result2;
    //    end
    //    else if(cycle_count>='d3 && cycle_count<='d17) begin
    //        accu_8_dim_1 <= accu_8_dim_1 + row_accu_result1;
    //        accu_8_dim_2 <= accu_8_dim_2 + row_accu_result2;
    //    end
    //    else begin
    //        accu_8_dim_1 <= accu_8_dim_1;
    //        accu_8_dim_2 <= accu_8_dim_2;
    //    end
    //    
    //end
    
    always @(posedge clk) begin 
    
        if(!rst_n) begin
            dim1_bin_0 <= 'd0;
            dim1_bin_1 <= 'd0;
            dim1_bin_2 <= 'd0;
            dim1_bin_3 <= 'd0;
            dim1_bin_4 <= 'd0;
            dim1_bin_5 <= 'd0;
            dim1_bin_6 <= 'd0;
            dim1_bin_7 <= 'd0;
            dim2_bin_0 <= 'd0;
            dim2_bin_1 <= 'd0;
            dim2_bin_2 <= 'd0;
            dim2_bin_3 <= 'd0;
            dim2_bin_4 <= 'd0;
            dim2_bin_5 <= 'd0;
            dim2_bin_6 <= 'd0;
            dim2_bin_7 <= 'd0;
        end
        else if(cs == ST_WAITING_BLUR) begin
            dim1_bin_0 <= 'd0;
            dim1_bin_1 <= 'd0;
            dim1_bin_2 <= 'd0;
            dim1_bin_3 <= 'd0;
            dim1_bin_4 <= 'd0;
            dim1_bin_5 <= 'd0;
            dim1_bin_6 <= 'd0;
            dim1_bin_7 <= 'd0;
            dim2_bin_0 <= 'd0;
            dim2_bin_1 <= 'd0;
            dim2_bin_2 <= 'd0;
            dim2_bin_3 <= 'd0;
            dim2_bin_4 <= 'd0;
            dim2_bin_5 <= 'd0;
            dim2_bin_6 <= 'd0;
            dim2_bin_7 <= 'd0;
        end
        else if(cycle_count == 'd10) begin
            dim1_bin_0 <= row_accu_result1[95:84];
            dim1_bin_1 <= row_accu_result1[83:72]; 
            dim1_bin_2 <= row_accu_result1[71:60];
            dim1_bin_3 <= row_accu_result1[59:48];
            dim1_bin_4 <= row_accu_result1[47:36];
            dim1_bin_5 <= row_accu_result1[35:24];
            dim1_bin_6 <= row_accu_result1[23:12];
            dim1_bin_7 <= row_accu_result1[11:0 ];
            dim2_bin_0 <= row_accu_result2[95:84];
            dim2_bin_1 <= row_accu_result2[83:72];
            dim2_bin_2 <= row_accu_result2[71:60];
            dim2_bin_3 <= row_accu_result2[59:48];
            dim2_bin_4 <= row_accu_result2[47:36];
            dim2_bin_5 <= row_accu_result2[35:24];
            dim2_bin_6 <= row_accu_result2[23:12];
            dim2_bin_7 <= row_accu_result2[11:0];
        end
        else if(cycle_count>='d3 && cycle_count<='d17) begin
            dim1_bin_0 <= dim1_bin_0 + row_accu_result1[95:84];
            dim1_bin_1 <= dim1_bin_1 + row_accu_result1[83:72]; 
            dim1_bin_2 <= dim1_bin_2 + row_accu_result1[71:60];
            dim1_bin_3 <= dim1_bin_3 + row_accu_result1[59:48];
            dim1_bin_4 <= dim1_bin_4 + row_accu_result1[47:36];
            dim1_bin_5 <= dim1_bin_5 + row_accu_result1[35:24];
            dim1_bin_6 <= dim1_bin_6 + row_accu_result1[23:12];
            dim1_bin_7 <= dim1_bin_7 + row_accu_result1[11:0];
            dim2_bin_0 <= dim2_bin_0 + row_accu_result2[95:84];
            dim2_bin_1 <= dim2_bin_1 + row_accu_result2[83:72];
            dim2_bin_2 <= dim2_bin_2 + row_accu_result2[71:60];
            dim2_bin_3 <= dim2_bin_3 + row_accu_result2[59:48];
            dim2_bin_4 <= dim2_bin_4 + row_accu_result2[47:36];
            dim2_bin_5 <= dim2_bin_5 + row_accu_result2[35:24];
            dim2_bin_6 <= dim2_bin_6 + row_accu_result2[23:12];
            dim2_bin_7 <= dim2_bin_7 + row_accu_result2[11:0];
        end
        else begin
            dim1_bin_0 <= dim1_bin_0;
            dim1_bin_1 <= dim1_bin_1;
            dim1_bin_2 <= dim1_bin_2;
            dim1_bin_3 <= dim1_bin_3;
            dim1_bin_4 <= dim1_bin_4;
            dim1_bin_5 <= dim1_bin_5;
            dim1_bin_6 <= dim1_bin_6;
            dim1_bin_7 <= dim1_bin_7;
            dim2_bin_0 <= dim2_bin_0;
            dim2_bin_1 <= dim2_bin_1;
            dim2_bin_2 <= dim2_bin_2;
            dim2_bin_3 <= dim2_bin_3;
            dim2_bin_4 <= dim2_bin_4;
            dim2_bin_5 <= dim2_bin_5;
            dim2_bin_6 <= dim2_bin_6;
            dim2_bin_7 <= dim2_bin_7;
        end
    
    end
    
    always @(posedge clk) begin //cycle_count
    
        if(!rst_n)
            cycle_count <= 'd0;
        else if(cs == ST_WAITING_BLUR)
            cycle_count <= 'd1;
        else if(cs == ST_LB_GET)
            cycle_count <= cycle_count + 1'b1;
        else
            cycle_count <= cycle_count;
    
    end
    
    always @(posedge clk) begin //descpt_ready_num
    
        if(!rst_n)
            descpt_ready_num <= 'd0;
        else if(cs == ST_IDLE)
            descpt_ready_num <= 'd0;
        else if(cs == ST_DESCPT_VALID)//sent out, so return to 0
            descpt_ready_num <= 'd0;
        else if(cs==ST_LB_GET && ns==ST_FINISH_ONE)//get one done
            descpt_ready_num <= descpt_ready_num + 1'b1;
        else
            descpt_ready_num <= descpt_ready_num;
            
    end
    
    always @(posedge clk) begin //readFrom
    
        if(!rst_n)
            readFrom <= 1'b0;
        else if(cs == ST_WAITING_KPT)
            readFrom <= kptRowCol[19];
        else
            readFrom <= readFrom;
    
    end

    always @(posedge clk) begin //kpt_addr
    
        if(!rst_n)
            kpt_addr <= 'd0;
        else if(cs == ST_IDLE)
            kpt_addr <= 'd0;
        else if(cs==ST_LB_GET && ns==ST_FINISH_ONE)
            kpt_addr <= kpt_addr + 1'b1;
        else
            kpt_addr <= kpt_addr;
            
    end
    
    always @(posedge clk) begin //kptRowCol_FF
    
        if(!rst_n)
            kptRowCol_FF <= 'd0;
        else if(cs == ST_WAITING_KPT)
            kptRowCol_FF <= kptRowCol[18:0];
        else
            kptRowCol_FF <= kptRowCol_FF;
            
    end
    
    always @(posedge clk) begin //blurred_addr
    
        if(!rst_n)
            blurred_addr <= 'd0;
        else if(cs == ST_GET_KPT)
            blurred_addr <= kptRowCol_FF[18:10] - 4'b1000;//從kptRow - 8那列開始讀
        else
            blurred_addr <= blurred_addr + 1'b1;
    
    end
    
    always @(posedge clk) begin //row_col_descpt1, row_col_descpt2, row_col_descpt3, row_col_descpt4
    
        if(!rst_n) begin
            row_col_descpt1 <= 'd0;
            row_col_descpt2 <= 'd0;
            row_col_descpt3 <= 'd0;
            row_col_descpt4 <= 'd0;
        end
        else if(ns == ST_DESCPT_VALID) begin
            row_col_descpt1 <= inner_row_col_descpt1;
            row_col_descpt2 <= inner_row_col_descpt2;
            row_col_descpt3 <= inner_row_col_descpt3;
            row_col_descpt4 <= inner_row_col_descpt4;
        end
        else begin
            row_col_descpt1 <= row_col_descpt1;
            row_col_descpt2 <= row_col_descpt2;
            row_col_descpt3 <= row_col_descpt3;
            row_col_descpt4 <= row_col_descpt4;
        end
    
    end
    
    always @(posedge clk) begin //cs
    
        if(!rst_n)
            cs <= ST_IDLE;
        else
            cs <= ns;
    
    end
    
    always @(*) begin //ns
    
        case(cs)
            ST_IDLE:
                if(start)
                    ns = ST_WAITING_KPT;
                else
                    ns = ST_IDLE;
            ST_WAITING_KPT:
                ns = ST_GET_KPT;
            ST_GET_KPT:
                ns = ST_GET_BLUR_ADDR;
            ST_GET_BLUR_ADDR:
                ns = ST_WAITING_BLUR;
            ST_WAITING_BLUR_1:
                ns = ST_WAITING_BLUR_2;
            ST_WAITING_BLUR_2:
                ns = ST_LB_GET;    
            ST_LB_GET:
                if(cycle_count == 'd17)
                    ns = ST_FINISH_ONE;
                else
                    ns = ST_LB_GET;
            ST_FINISH_ONE:
                if(descpt_ready_num != 3'b100)//not finish 4 yet
                    ns = ST_WAITING_KPT;
                else if(descriptor_request == 1'b1)
                    ns = ST_DESCPT_VALID;
                else
                    ns = ST_FINISH_ONE;
            ST_DESCPT_VALID:
                if(readFrom==1'b1 && kpt_addr==new_kpt_num)
                    ns = ST_IDLE;
                else
                    ns = ST_WAITING_KPT;
        endcase
    
    end
    
endmodule