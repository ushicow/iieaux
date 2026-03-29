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
//   1.1.2 | 2026/03/29  | ushicow | color graphics
// --------------------------------------------------------------------
`default_nettype none

module Apple2_Video (
    input wire I_clk14m,            // Apple II system clock
    input wire I_rst_n,             // reset, low active 
    input wire I_sync_n,            // Apple II video sync
    input wire I_serout_n,          // Apple II serial video out
    input wire I_gr,                // Graphic mode
    output wire O_rgb_vs_n,         // RGB vertical sync, negative
    output wire O_rgb_hs_n,         // RGB horizontal sync, negative
    output wire O_rgb_de,           // RGB data enable
    output wire [23:0] O_rgb_data   // 24 bits RGB data
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

parameter WHITE       = 24'hffffff;
parameter DEEP_RED    = 24'hdd0033;
parameter DARK_BLUE   = 24'h000099;
parameter PURPLE      = 24'hdd22dd;
parameter DARK_GREEN  = 24'h007722;
parameter DARK_GRAY   = 24'h555555;
parameter MEDIUM_BLUE = 24'h2222ff;
parameter LIGHT_BLUE  = 24'h66aaff;
parameter BROWN       = 24'h885500;
parameter ORANGE      = 24'hff6600;
parameter LIGHT_GRAY  = 24'haaaaaa;
parameter PINK        = 24'hff9988;
parameter LIGHT_GREEN = 24'h11dd00;
parameter YELLOW      = 24'hffff00;
parameter AQUAMARINE  = 24'h44ff99;
parameter BLACK       = 24'h000000;

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

logic [23:0] bw_data;
always_ff@(posedge I_clk14m) begin
    bw_data <= I_serout_n ? BLACK : WHITE;
end

logic [3:0] code;
always_ff@(posedge I_clk14m) begin
    code <= {code[2:0], ~I_serout_n};
end

logic [3:0] color;
always_comb begin
    case (pixel[1:0])
        2'b11: color = {code[0], code[3:1]};
        2'b00: color = {code[1:0], code[3:2]};
        2'b01: color = {code[2:0], code[3]};
        default: color = code;
    endcase
end

always_comb begin
    case (color) 
        0: rgb_data = BLACK;
        1: rgb_data = DEEP_RED;
        2: rgb_data = BROWN;
        3: rgb_data = ORANGE;
        4: rgb_data = DARK_GREEN;
        5: rgb_data = DARK_GRAY;
        6: rgb_data = LIGHT_GREEN;
        7: rgb_data = YELLOW;
        8: rgb_data = DARK_BLUE;
        9: rgb_data = PURPLE;
        10: rgb_data = LIGHT_GRAY;
        11: rgb_data = PINK;
        12: rgb_data = MEDIUM_BLUE;
        13: rgb_data = LIGHT_BLUE;
        14: rgb_data = AQUAMARINE;
        default: rgb_data = WHITE;
    endcase
end

assign O_rgb_vs_n = rgb_vs_n;
assign O_rgb_hs_n = rgb_hs_n;
assign O_rgb_de = rgb_de;
assign O_rgb_data = I_gr ? rgb_data : bw_data;

endmodule

`default_nettype wire
