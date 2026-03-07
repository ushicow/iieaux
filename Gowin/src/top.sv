`default_nettype none
// Apple IIe Aux Card
// V1.0.2 2026.03.07 80 Colmun Text

module top (
    inout wire [7:0] d,
    input wire [7:0] ar,
    input wire pras_n,
    input wire q3,
    input wire rw80,
    input wire clk14m
);

logic sclk; // for debug
Gowin_rPLL rpll (
    .clkout(sclk), //output clkout
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

endmodule

`default_nettype wire