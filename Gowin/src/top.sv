`default_nettype none
// Apple IIe Aux Card
// V1.0.2 2026.03.07 80 Colmun Text
// V1.0.3 2026.03.08 Input video signals
// V1.0.4 2026.03.14 Vesa VGA output test

module top (
    inout wire [7:0] d,
    input wire [7:0] ar,
    input wire pras_n,
    input wire q3,
    input wire rw80,
    input wire wndw,
    input wire clrgat,
    input wire serout,
    input wire sync,
    input wire clk14m,
    output wire       dvi_clk_p,
    output wire       dvi_clk_n,
    output wire [2:0] dvi_data_p,
    output wire [2:0] dvi_data_n,
    input wire mclk
);

logic sclk;
logic reset_n;
Gowin_rPLL rpll(
    .clkout(sclk), //output clkout
    .lock(reset_n), //output lock
    .clkin(clk14m) //input clkin
);

logic [7:0] row;
logic [15:0] addr;
logic [7:0] din;
logic [7:0] dout;

assign d = rw80 ? dout : 8'bz;

always_ff@(negedge pras_n) begin
    row <= ar;
end

always_ff@(negedge q3) begin
    addr[0] <= row[0];
    addr[1] <= row[1];
    addr[2] <= row[2];
    addr[3] <= row[3];
    addr[4] <= row[4];
    addr[5] <= row[5];
    addr[6] <= ar[1];
    addr[7] <= row[6];
    addr[8] <= row[7];
    addr[9] <= ar[0];
    addr[10] <= ar[2];
    addr[11] <= ar[3];
    addr[12] <= ar[4];
    addr[13] <= ar[5];
    addr[14] <= ar[6];
    addr[15] <= ar[7];
    din <= d;
end

Gowin_RAM16S sram (
    .dout(dout), //output [7:0] dout
    .wre(~rw80), //input wre
    .ad(addr[9:0]), //input [9:0] ad
    .di(din), //input [7:0] di
    .clk(q3) //input clk
);

//parameter ACTIVE_PIXEL = 560;
//parameter ACTIVE_LINE = 192;
//parameter FPORCH_PIXEL = 107;
parameter APPLE_SYNC = 56;
//parameter SYNC_PIXEL = 56;
//parameter BPORCH_PIXEL = 189;
//parameter FPORCH_LINE = 40;
//parameter SYNC_LINE = 4;
//parameter BPORCH_LINE = 26;

logic [7:0] rgb;
assign rgb = serout ? 8'h00 : 8'hff;

logic [9:0] pixel;
logic [8:0] line;
logic [9:0] count;
logic rgb_vs;
logic rgb_hs;
always_ff@(posedge clk14m) begin
    if (sync) begin
        if (count == APPLE_SYNC) begin
            rgb_vs <= 1;
        end
        pixel <= pixel + 1'b1;
        count <= 0;
        rgb_hs <= 1;
    end else begin
        count <= count + 1'b1;
        rgb_hs <= 0;
        if (pixel) begin
            line <= line + 1'b1;
        end
        pixel <= 0;
        if (count > APPLE_SYNC) begin
            rgb_hs <= 1;
            rgb_vs <= 0;
            line <= 0;
        end
    end
end


//logic [7:0] r;
//logic [7:0] g;
//logic [7:0] b;
//logic vin_vs_req;
//logic vin_de_req;
//logic buf_fstline_rdy;
//Scaler_Lite_Up_Top scaler(
//    .I_reset(reset_n), //input I_reset
//    .I_sysclk(vga_clk), //input I_sysclk
//    .I_vin_ref_vs(~rgb_vs), //input I_vin_ref_vs
//    .I_vin_ref_de(~wndw), //input I_vin_ref_de
//    .O_vin_vs_req(vin_vs_req), //output O_vin_vs_req
//    .O_vin_de_req(vin_de_req), //output O_vin_de_req
//    .I_buf_fstline_rdy(buf_fstline_rdy), //input I_buf_fstline_rdy
//    .I_vin_data0_cpl(rgb), //input [7:0] I_vin_data0_cpl
//    .I_vin_data1_cpl(rgb), //input [7:0] I_vin_data1_cpl
//    .I_vin_data2_cpl(rgb), //input [7:0] I_vin_data2_cpl
//    .O_vout0_data(r), //output [7:0] O_vout0_data
//    .O_vout1_data(g), //output [7:0] O_vout1_data
//    .O_vout2_data(b), //output [7:0] O_vout2_data
//    .O_vout_vs(rgb2_vs), //output O_vout_vs
//    .O_vout_de(rgb2_de) //output O_vout_de
//);

// VESA 640 x 480, 75 fps, 31.5 MHz
parameter ACTIVE_PIXEL = 640;
parameter ACTIVE_LINE = 480;
parameter FPORCH_PIXEL = ACTIVE_PIXEL + 16;
parameter SYNC_PIXEL = FPORCH_PIXEL + 64;
parameter BPORCH_PIXEL = SYNC_PIXEL + 120;
parameter FPORCH_LINE = ACTIVE_LINE + 1;
parameter SYNC_LINE = FPORCH_LINE + 3;
parameter BPORCH_LINE = SYNC_LINE + 16;

logic [9:0] hcount;
logic [9:0] vcount;
logic rgb2_de;
logic rgb2_hs;
logic rgb2_vs;
always_ff@(posedge vga_clk, negedge reset_n) begin
    if (!reset_n) begin
        vcount <= 0;
        hcount <= 0;
    end else begin
        if (hcount == FPORCH_PIXEL) begin
            vga_hs <= 0;
            if (vcount == FPORCH_LINE) begin
                vga_vs <= 0;
            end
            if (vcount == SYNC_LINE) begin
                vga_vs <= 1;
            end
            if (vcount == (BPORCH_LINE - 1)) begin
                vcount <= 0;
            end else begin
                vcount <= vcount + 1'b1;
            end
        end
        if (hcount == SYNC_PIXEL) begin
            vga_hs <= 1;
        end

        if (hcount == (BPORCH_PIXEL - 1)) begin
            hcount <= 0;
        end else begin
            hcount <= hcount + 1'b1;
        end

        if (vcount < ACTIVE_LINE & hcount < ACTIVE_PIXEL) begin
            vga_de <= 1;
        end else begin
            vga_de <= 0;
        end
    end
end

assign rgb24 = vga_de ? 24'h550000 : 24'h0000ff;//{r,g,b}

logic vga_serial;
logic vga_clk;
logic vga_vs;
logic vga_hs;
logic vga_de;
logic [23:0] rgb24;
Gowin_rPLL_VGA u_vga_pll(
    .clkout(vga_serial), //output clkout 157.5 MHz
    .clkin(mclk) //input clkin 27 MHz
);

Gowin_CLKDIV u_clkdiv(
    .clkout(vga_clk), //output clkout 31.5 MHz
    .hclkin(vga_serial), //input hclkin 157.5 MHz
    .resetn(reset_n), //input resetn
    .calib(1'b1) //input calib
);

DVI_TX_Top dvi (
    .I_rst_n(reset_n), //input I_rst_n
    .I_serial_clk(vga_serial), //input I_serial_clk
    .I_rgb_clk(vga_clk), //input I_rgb_clk
    .I_rgb_vs(vga_vs), //input I_rgb_vs
    .I_rgb_hs(vga_hs), //input I_rgb_hs
    .I_rgb_de(vga_de), //input I_rgb_de
    .I_rgb_r(rgb24[23:16]), //input [7:0] I_rgb_r
    .I_rgb_g(rgb24[15:8]), //input [7:0] I_rgb_g
    .I_rgb_b(rgb24[7:0]), //input [7:0] I_rgb_b
    .O_tmds_clk_p(dvi_clk_p), //output O_tmds_clk_p
    .O_tmds_clk_n(dvi_clk_n), //output O_tmds_clk_n
    .O_tmds_data_p(dvi_data_p), //output [2:0] O_tmds_data_p
    .O_tmds_data_n(dvi_data_n) //output [2:0] O_tmds_data_n
);

endmodule

`default_nettype wire