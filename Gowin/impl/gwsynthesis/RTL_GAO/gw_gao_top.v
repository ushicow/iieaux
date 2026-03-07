module gw_gao(
    \d[7] ,
    \d[6] ,
    \d[5] ,
    \d[4] ,
    \d[3] ,
    \d[2] ,
    \d[1] ,
    \d[0] ,
    \ra[7] ,
    \ra[6] ,
    \ra[5] ,
    \ra[4] ,
    \ra[3] ,
    \ra[2] ,
    \ra[1] ,
    \ra[0] ,
    pras_n,
    q3,
    rw80,
    en80_n,
    rw,
    phi0,
    phi1,
    clk14m,
    \ad[15] ,
    \ad[14] ,
    \ad[13] ,
    \ad[12] ,
    \ad[11] ,
    \ad[10] ,
    \ad[9] ,
    \ad[8] ,
    \ad[7] ,
    \ad[6] ,
    \ad[5] ,
    \ad[4] ,
    \ad[3] ,
    \ad[2] ,
    \ad[1] ,
    \ad[0] ,
    mclk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \d[7] ;
input \d[6] ;
input \d[5] ;
input \d[4] ;
input \d[3] ;
input \d[2] ;
input \d[1] ;
input \d[0] ;
input \ra[7] ;
input \ra[6] ;
input \ra[5] ;
input \ra[4] ;
input \ra[3] ;
input \ra[2] ;
input \ra[1] ;
input \ra[0] ;
input pras_n;
input q3;
input rw80;
input en80_n;
input rw;
input phi0;
input phi1;
input clk14m;
input \ad[15] ;
input \ad[14] ;
input \ad[13] ;
input \ad[12] ;
input \ad[11] ;
input \ad[10] ;
input \ad[9] ;
input \ad[8] ;
input \ad[7] ;
input \ad[6] ;
input \ad[5] ;
input \ad[4] ;
input \ad[3] ;
input \ad[2] ;
input \ad[1] ;
input \ad[0] ;
input mclk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \d[7] ;
wire \d[6] ;
wire \d[5] ;
wire \d[4] ;
wire \d[3] ;
wire \d[2] ;
wire \d[1] ;
wire \d[0] ;
wire \ra[7] ;
wire \ra[6] ;
wire \ra[5] ;
wire \ra[4] ;
wire \ra[3] ;
wire \ra[2] ;
wire \ra[1] ;
wire \ra[0] ;
wire pras_n;
wire q3;
wire rw80;
wire en80_n;
wire rw;
wire phi0;
wire phi1;
wire clk14m;
wire \ad[15] ;
wire \ad[14] ;
wire \ad[13] ;
wire \ad[12] ;
wire \ad[11] ;
wire \ad[10] ;
wire \ad[9] ;
wire \ad[8] ;
wire \ad[7] ;
wire \ad[6] ;
wire \ad[5] ;
wire \ad[4] ;
wire \ad[3] ;
wire \ad[2] ;
wire \ad[1] ;
wire \ad[0] ;
wire mclk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(pras_n),
    .data_i({\d[7] ,\d[6] ,\d[5] ,\d[4] ,\d[3] ,\d[2] ,\d[1] ,\d[0] ,\ra[7] ,\ra[6] ,\ra[5] ,\ra[4] ,\ra[3] ,\ra[2] ,\ra[1] ,\ra[0] ,pras_n,q3,rw80,en80_n,rw,phi0,phi1,clk14m,\ad[15] ,\ad[14] ,\ad[13] ,\ad[12] ,\ad[11] ,\ad[10] ,\ad[9] ,\ad[8] ,\ad[7] ,\ad[6] ,\ad[5] ,\ad[4] ,\ad[3] ,\ad[2] ,\ad[1] ,\ad[0] }),
    .clk_i(mclk)
);

endmodule
