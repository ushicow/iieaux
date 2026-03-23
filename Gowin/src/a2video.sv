// ---------------------------------------------------------------------
// File name         : a2video.sv
// Module name       : Apple2_Video
// Module Description: Make RGB video signals from apple II video signals
// Created by        : ushicow
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 2026/03/23  | ushicow |    initial
// --------------------------------------------------------------------
`default_nettype none

module Apple2_Video (
    input wire I_clk14m,            // Apple II system clock
    input wire I_rst_n,             // reset, low active 
    input wire I_sync_n,            // Apple II video sync
    input wire I_wndw_n,            // Apple II video nonblank window
    input wire I_serout_n,          // Apple II serial video out
    output reg O_rgb_vs_n,          // RGB vertical sync, negative
    output reg O_rgb_hs_n,          // RGB horizontal sync, negative
    output reg O_rgb_de,            // RGB data enable
    output reg [23:0] O_rgb_data    // 24 bits RGB data
);

parameter APPLE_SYNC = 56;
parameter ACTIVE_PIXEL = 640; // 40+560+40
parameter FPORCH_PIXEL = 79;  // 119-40
parameter SYNC_PIXEL = 56;
parameter BPORCH_PIXEL = 137; // 177-40
parameter ACTIVE_LINE = 240;  // 24+192+24
parameter FPORCH_LINE = 7;    // 31-24
parameter SYNC_LINE = 4;
parameter BPORCH_LINE = 11;   // 35-24

parameter WHITE = 24'hffffff;
parameter BLACK = 24'h000000;

logic [8:0] line;
logic [9:0] pixel;
logic [9:0] count;  // sync time
logic rgb_vs_n;
logic rgb_hs_n;
logic rgb_de;
logic [23:0] rgb_data;
always_ff@(posedge I_clk14m) begin
    if (I_sync_n) begin
        count <= 0;
        if (count == APPLE_SYNC) begin
            rgb_vs_n <= 1;
        end
        rgb_hs_n <= 1;
    end else begin
        count <= count + 1'b1;
        if (count >= APPLE_SYNC) begin
            rgb_vs_n <= 0;
            rgb_hs_n <= 1;
        end else begin
            rgb_hs_n <= 0;
        end
    end
end

always_ff@(posedge I_clk14m or negedge I_rst_n) begin
    if (!I_rst_n) begin
        pixel <= 0;
    end else if (rgb_hs_n) begin
        pixel <= pixel + 1'b1;
        if (pixel == 0) begin
            if (rgb_vs_n) begin
                line <= line + 1'b1;
            end else begin
                line <= 0;
            end
        end
    end else begin
        pixel <= 0;
    end
end

always_ff@(posedge I_clk14m) begin
    if ((line > BPORCH_LINE) & (line <= (BPORCH_LINE + ACTIVE_LINE))
            & (pixel >= (BPORCH_PIXEL - 1)) & (pixel < (BPORCH_PIXEL + ACTIVE_PIXEL - 1))) begin
        rgb_de <= 1;
    end else begin
        rgb_de <= 0;
    end
end

always_ff@(posedge I_clk14m) begin
    rgb_data <= I_serout_n ? BLACK : WHITE;
end

assign O_rgb_vs_n = rgb_vs_n;
assign O_rgb_hs_n = rgb_hs_n;
assign O_rgb_de = rgb_de;
assign O_rgb_data = rgb_data;

endmodule

`default_nettype wire
