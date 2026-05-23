// ---------------------------------------------------------------------
// File name         : top.sv
// Module name       : top
// Module Description: DVI video card for Apple IIe Aux Slot
// Created by        : ushicow
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0.0 | 2026/02/15  | ushicow |    initial
//   1.0.1 | 2026/03/01  | ushicow | for 1st batch of PCB
//   1.0.2 | 2026/03/07  | ushicow | 80 Column Text
//   1.0.3 | 2026/03/11  | ushicow | DVI output test
//   1.0.4 | 2026/03/15  | ushicow | VGA signal test
//   1.0.5 | 2026/03/23  | ushicow | Frame Buffer
//   1.1.1 | 2026/03/28  | ushicow | Extended 64KB memory PCB V1.1.1
//   1.1.2 | 2026/03/29  | ushicow | Color graphics
//   1.1.3 | 2026/03/30  | ushicow | modify byte R/W 
//   1.1.4 | 2026/04/05  | ushicow | color/mono switch
//   1.1.5 | 2026/04/06  | ushicow | change the psram clock to 72MHz
//   1.1.6 | 2026/04/26  | ushicow | correct data bus timing
//   2.0.1 | 2026/05/13  | ushicow | PCB V2.0
//   2.0.2 | 2026/05/13  | ushicow | 4MB of RAM
//   2.0.3 | 2026/05/16  | ushicow | text color mode
// --------------------------------------------------------------------
`default_nettype none

module top (
    inout wire [7:0] d,
    input wire [7:0] ar,
    input wire gr,
    input wire q3,
    input wire sync,
    input wire pras_n,
    input wire an3,
    input wire c07x,
    input wire rw,
    input wire phi0,
    input wire vid80,
    input wire en80,
    input wire rw80,
    input wire clk14m,
    input wire serout,
    input wire push_n,
    input wire sw1,
    input wire sw2,
    output wire d_rw,
    output wire       dvi_clk_p,
    output wire       dvi_clk_n,
    output wire [2:0] dvi_data_p,
    output wire [2:0] dvi_data_n,
	output wire [1:0] O_psram_ck,
	output wire [1:0] O_psram_ck_n,
	inout wire [1:0]  IO_psram_rwds,
	inout wire [15:0] IO_psram_dq,
	output wire [1:0] O_psram_reset_n,
	output wire [1:0] O_psram_cs_n,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5,
    output wire led6,
    input wire mclk
);

assign led1 = reset_n;
assign led2 = mono;
assign led3 = gr;
assign led4 = vid80;
assign led5 = an3;
assign led6 = hgr;

logic hgr;
always_ff@(posedge phi0) begin
    if ((addr[15:12] >= 4'h2) & (addr[15:12] < 4'h6)) begin
        hgr <= 1;
    end else begin
        hgr <= 0;
    end
end

assign d_rw = ~rw80 | (!c07x & !rw);

logic memory_clk;
logic pll_lock;

logic [7:0] row;
logic [15:0] addr;
logic [7:0] din;
logic [7:0] dout;

assign d = d_rw ? 8'bz : dout;

logic [7:0] bank;
logic out_of_bank;
always_ff@(negedge pcas_n or negedge reset_n) begin
    if (!reset_n) begin
        bank <= 0;
        out_of_bank <= 0;
    end else if (!c07x & !rw & (row[3:0] == 4'h3)) begin
        if (d < 8'b11110000) begin
            bank <= d;
            out_of_bank <= 0;
        end else begin
            out_of_bank <= 1;
        end
    end
end

logic [5:0] bs;
assign bs = phi0 ? bank[5:0] : 0;

always_ff@(negedge pras_n) begin
    row <= ar;
end

logic pcas_n;
always_ff@(posedge clk14m) begin
    pcas_n <= pras_n;
end

always_ff@(negedge pcas_n) begin
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
    din <= rw80 ? 8'bz : d;
end

logic read;
logic write;
logic busy;
assign write = !rw80 & ram_en;
assign read = rw80 & ram_en;
logic ram_en;
logic pcas0;
logic pcas1;
logic pcas2;
always_ff@(posedge memory_clk) begin
    pcas0 <= pcas_n;
    pcas1 <= pcas0;
    pcas2 <= pcas1;
end
assign ram_en = (pcas2 & !pcas1) ? 1 : 0;

logic [15:0] doutw;
PsramController #(.FREQ(72_000_000)) u_psc (
    .clk(memory_clk),
    .clk_p(clkoutp),        // phase-shifted clock for driving O_psram_ck
    .resetn(pll_lock),
    .read(read),            // Set to 1 to read from RAM
    .write(write),          // Set to 1 to write to RAM
    .addr({bs, addr}),      // Byte address to read / write
    .din({din, din}),       // Data word to write
    .byte_write(1'b1),      // When writing, only write one byte instead of the whole word. 
                            // addr[0]==1 means we write the upper half of din. lower half otherwise.
    .dout(doutw),           // Last read data. Read is always word-based.
    .busy(busy),            // 1 while an operation is in progress

    .O_psram_ck(O_psram_ck[1]),
    .IO_psram_rwds(IO_psram_rwds[1]),
    .IO_psram_dq(IO_psram_dq[15:8]),
    .O_psram_cs_n(O_psram_cs_n[1]),
    .O_psram_reset_n(O_psram_reset_n[1])
);

logic dout_en;
always_ff@(posedge memory_clk) begin
    if (busy) begin
        dout_en <= 1;
    end else if (dout_en) begin
        if (out_of_bank) begin
            dout <= 8'bz;
        end else begin
            dout <= addr[0] ? doutw[15:8] : doutw[7:0];
        end
        dout_en <= 0;
    end
end

logic mono;
logic mono_sw1;
logic mono_sw2;
logic [2:0] mstat;
logic pre_an3;
always_ff@(posedge phi0 or negedge reset_n) begin
    if (!reset_n) begin
        mono_sw1 <= 0;
        mstat <= 3'b000;
    end else begin
        pre_an3 <= an3;
        if (hgr & (an3 != pre_an3)) begin
            if (vid80) begin        // 80COL OFF
                case (mstat)
                    0: mstat <= an3 ? 1 : 0;
                    1: mstat <= !an3 ? 2 : 0;
                    2: mstat <= an3 ? 3 : 0; 
                    default: mstat <= 0;
                endcase
            end else begin          // 80COL ON
                case (mstat)
                    3: begin
                        if (!an3) begin
                            mono_sw1 <= mono ? mono_sw1 : ~mono_sw1;
                        end
                        mstat <= 0;
                    end
                    0: mstat <= an3 ? 4 : 0;
                    4: mstat <= !an3 ? 5 : 0;
                    5: mstat <= an3 ? 6 : 0;
                    6: begin
                        if (!an3) begin
                            mono_sw1 <= mono ? ~mono_sw1 : mono_sw1;
                        end
                        mstat <= 0;
                    end
                    default: mstat <= 0;
                endcase
            end
        end
    end
end

logic push0_n;
debouncer dedouncer_u (
    .clk(mclk),
    .rst_n(reset_n),
    .button_in(push_n),
    .button_out(push0_n)
);

always_ff@(negedge push0_n or negedge reset_n) begin
    if (!reset_n) begin
        mono_sw2 <= 0;
    end else begin
        mono_sw2 <= ~mono_sw2;
    end
end

assign mono = mono_sw1 ^ mono_sw2;

// Apple II Video signals
logic rgb_vs_n;         // RGB vertical sync, negative
logic rgb_hs_n;         // RGB horizontal sync, negative
logic rgb_de;           // RGB data enable
logic [23:0] rgb_data;  // 24 bits RGB data
Apple2_Video u_a2video (
    .I_clk14m(clk14m),
    .I_rst_n(reset_n),
    .I_sync_n(sync),
    .I_serout_n(serout),
    .I_gr(gr),
    .I_mono(mono),
    .I_sw({sw1, sw2}),
    .O_rgb_vs_n(rgb_vs_n),
    .O_rgb_hs_n(rgb_hs_n),
    .O_rgb_de(rgb_de),
    .O_rgb_data(rgb_data)
);


// VGA Video signals
logic serial_clk;       // VGA serial clock
logic vga_clk;          // VGA pixel clock
logic vga_vs_n;         // VGA vertical sync, negative
logic vga_hs_n;         // VGA horizontal sync, negative
logic vga_de;           // VGA data enable

logic reset_n;
Gowin_rPLL_VGA u_vga_pll(
    .clkout(serial_clk), //clkout 126 MHz
    .lock(reset_n),      // plllock as reset
    .clkin(mclk)         //clkin 27 MHz
);

CLKDIV u_clkdiv
(.RESETN(reset_n)
,.HCLKIN(serial_clk)    //clk x5, 126 MHz
,.CLKOUT(vga_clk)       //clk x1, 25.2 MHz
,.CALIB (1'b1)
);
defparam u_clkdiv.DIV_MODE="5";
defparam u_clkdiv.GSREN="false";

VGA_Sync u_vga_sync(
    .I_pxl_clk(vga_clk),
    .I_rst_n(reset_n),
    .O_vs_n(vga_vs_n),
    .O_hs_n(vga_hs_n),
    .O_de(vga_de)
);


// Video frame buffer
logic vout_den;
logic [23:0] vout_data;
Video_Frame_Buffer_Top u_vfb(
    .I_rst_n(init_calib), //input I_rst_n
    .I_dma_clk(dma_clk), //input I_dma_clk
    .I_wr_halt(1'b0), //input [0:0] I_wr_halt
    .I_rd_halt(1'b0), //input [0:0] I_rd_halt
    .I_vin0_clk(clk14m), //input I_vin0_clk
    .I_vin0_vs_n(rgb_vs_n), //input I_vin0_vs_n
    .I_vin0_de(rgb_de), //input I_vin0_de
    .I_vin0_data(rgb_data), //input [23:0] I_vin0_data
    .O_vin0_fifo_full(), //output O_vin0_fifo_full
    .I_vout0_clk(vga_clk), //input I_vout0_clk
    .I_vout0_vs_n(~scl_vs_req), //input I_vout0_vs_n
    .I_vout0_de(scl_de_req), //input I_vout0_de
    .O_vout0_den(vout_den), //output O_vout0_den
    .O_vout0_data(vout_data), //output [23:0] O_vout0_data
    .O_vout0_fifo_empty(), //output O_vout0_fifo_empty
    .O_cmd(cmd), //output O_cmd
    .O_cmd_en(cmd_en), //output O_cmd_en
    .O_addr(dma_addr), //output [20:0] O_addr
    .O_wr_data(wr_data), //output [31:0] O_wr_data
    .O_data_mask(data_mask), //output [3:0] O_data_mask
    .I_rd_data_valid(rd_data_valid), //input I_rd_data_valid
    .I_rd_data(rd_data), //input [31:0] I_rd_data
    .I_init_calib(init_calib) //input I_init_calib
);


// PSRAM for Video Frame Buffer
logic [20:0] dma_addr;
logic [31:0] wr_data;
logic [31:0] rd_data;
logic [3:0] data_mask;
logic rd_data_valid;
logic cmd;
logic cmd_en;
logic init_calib;
logic dma_clk;
logic clkoutp;

Gowin_rPLL u_pll(
    .clkout(memory_clk), //output clkout    72 MHz
    .lock(pll_lock), //output lock
    .clkoutp(clkoutp), //output clkoutp     90 deg
    .clkin(mclk) //input clkin              27 MHz
);

PSRAM_Memory_Interface_HS_Top u_psram(
    .clk(mclk), //input clk
    .memory_clk(memory_clk), //input memory_clk
    .pll_lock(reset_n), //input pll_lock
    .rst_n(1'b1), //input rst_n
    .O_psram_ck(O_psram_ck[0]), //output [0:0] O_psram_ck
    .O_psram_ck_n(O_psram_ck_n[0]), //output [0:0] O_psram_ck_n
    .IO_psram_dq(IO_psram_dq[7:0]), //inout [7:0] IO_psram_dq
    .IO_psram_rwds(IO_psram_rwds[0]), //inout [0:0] IO_psram_rwds
    .O_psram_cs_n(O_psram_cs_n[0]), //output [0:0] O_psram_cs_n
    .O_psram_reset_n(O_psram_reset_n[0]), //output [0:0] O_psram_reset_n
    .wr_data(wr_data), //input [31:0] wr_data
    .rd_data(rd_data), //output [31:0] rd_data
    .rd_data_valid(rd_data_valid), //output rd_data_valid
    .addr(dma_addr), //input [20:0] addr
    .cmd(cmd), //input cmd
    .cmd_en(cmd_en), //input cmd_en
    .init_calib(init_calib), //output init_calib
    .clk_out(dma_clk), //output clk_out
    .data_mask(data_mask) //input [3:0] data_mask
);


// Scan doubler
logic scl_vs_req;
logic scl_de_req;
logic [7:0] sclin_r;
logic [7:0] sclin_g;
logic [7:0] sclin_b;
logic [7:0] sclout_r;
logic [7:0] sclout_g;
logic [7:0] sclout_b;
logic sclout_vs;
logic sclout_de;

logic buf_fstline_rdy;
logic [31:0] delay_cnt;
//waiting for every frame buffer first line is ready
always_ff@(posedge vga_clk or negedge reset_n)
begin
    if(!reset_n)
        delay_cnt <= 32'd0;
    else if(scl_vs_req)
        delay_cnt <= 32'd0;
    else if(delay_cnt >= 800*2)
        delay_cnt <= delay_cnt;
    else
        delay_cnt <= delay_cnt + 1'b1;
end

always_ff@(posedge vga_clk or negedge reset_n)
begin
    if(!reset_n)
        buf_fstline_rdy <= 1'd0;
    else if(scl_vs_req)
        buf_fstline_rdy <= 1'd0;
    else if(delay_cnt >= 800*2)
        buf_fstline_rdy <= 1'd1;
    else
        buf_fstline_rdy <= buf_fstline_rdy;
end

Scaler_Lite_Up_Top u_scaler(
    .I_reset(~reset_n), //input I_reset
    .I_sysclk(vga_clk), //input I_sysclk
    .I_vin_ref_vs(~vga_vs_n), //input I_vin_ref_vs positive
    .I_vin_ref_de(vga_de), //input I_vin_ref_de
    .O_vin_vs_req(scl_vs_req), //output O_vin_vs_req positive
    .O_vin_de_req(scl_de_req), //output O_vin_de_req
    .I_buf_fstline_rdy(buf_fstline_rdy), //input I_buf_fstline_rdy
    .I_vin_data0_cpl(sclin_r), //input [7:0] I_vin_data0_cpl
    .I_vin_data1_cpl(sclin_g), //input [7:0] I_vin_data1_cpl
    .I_vin_data2_cpl(sclin_b), //input [7:0] I_vin_data2_cpl
    .O_vout0_data(sclout_r), //output [7:0] O_vout0_data
    .O_vout1_data(sclout_g), //output [7:0] O_vout1_data
    .O_vout2_data(sclout_b), //output [7:0] O_vout2_data
    .O_vout_vs(sclout_vs), //output O_vout_vs
    .O_vout_de(sclout_de) //output O_vout_de
);

assign sclin_r = vout_data[23:16];
assign sclin_g = vout_data[15:8];
assign sclin_b = vout_data[7:0];


// DVI output
logic dvi_hs_n;
logic dvi_vs_n;
logic dvi_de;
logic [23:0] dvi_data;  // VGA RGB data

localparam N = 16; //delay N clocks
                        
logic [N-1:0] Pout_hs_dn;
logic [N-1:0] Pout_vs_dn;
logic [N-1:0] Pout_de_dn;

always_ff@(posedge vga_clk or negedge reset_n) begin
    if (!reset_n) begin                          
        Pout_hs_dn <= {N{1'b1}};
        Pout_vs_dn <= {N{1'b1}}; 
        Pout_de_dn <= {N{1'b0}}; 
    end else begin                          
        Pout_hs_dn <= {Pout_hs_dn[N-2:0],vga_hs_n};
        Pout_vs_dn <= {Pout_vs_dn[N-2:0],vga_vs_n}; 
        Pout_de_dn <= {Pout_de_dn[N-2:0],vga_de}; 
    end
end

assign dvi_data = {sclout_r, sclout_g, sclout_b};
assign dvi_vs_n = Pout_vs_dn[8];
assign dvi_hs_n = Pout_hs_dn[8];
assign dvi_de = Pout_de_dn[8];

DVI_TX_Top u_dvi_tx (
    .I_rst_n(reset_n), //input I_rst_n
    .I_serial_clk(serial_clk), //input I_serial_clk
    .I_rgb_clk(vga_clk), //input I_rgb_clk
    .I_rgb_vs(dvi_vs_n), //input I_rgb_vs
    .I_rgb_hs(dvi_hs_n), //input I_rgb_hs
    .I_rgb_de(dvi_de), //input I_rgb_de
    .I_rgb_r(dvi_data[23:16]), //input [7:0] I_rgb_r
    .I_rgb_g(dvi_data[15:8]), //input [7:0] I_rgb_g
    .I_rgb_b(dvi_data[7:0]), //input [7:0] I_rgb_b
    .O_tmds_clk_p(dvi_clk_p), //output O_tmds_clk_p
    .O_tmds_clk_n(dvi_clk_n), //output O_tmds_clk_n
    .O_tmds_data_p(dvi_data_p), //output [2:0] O_tmds_data_p
    .O_tmds_data_n(dvi_data_n) //output [2:0] O_tmds_data_n
);

endmodule

`default_nettype wire