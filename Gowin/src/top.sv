`default_nettype none
// Apple IIe Aux Card
// 2026.01.12 80 Colmun Text

module top (
    inout wire [7:0] d,
    input wire [7:0] a,
    input wire pras_n,
    input wire ldps,
    input wire q3,
    input wire phi0,
    input wire phi1,
    input wire en80,
    input wire rw80,
    input wire gr,
    input wire vid80,
    input wire an3,
    input wire sync,
    input wire clk14m,
    input wire rw,
    input wire c07x,
    input wire ra9,
    input wire ra10,
    output reg ra_en,
    output reg vid_en,
    output wire d_rw,
    output wire md_en,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5,
    output wire led6,
    input wire mclk
);

logic sclk;
Gowin_rPLL rpll (
    .clkout(sclk), //output clkout
    .clkin(clk14m) //input clkin
);

assign led1 = gr;
assign led2 = c07x;
assign led3 = sync;
assign led4 = d_rw;
assign led5 = vid80;
assign led6 = an3;

assign md_en = en80;
assign d_rw = ~rw80;

assign d = d_rw ? 8'bz : dout;

logic [7:0] dout;
logic [7:0] row;

always_ff@(negedge pras_n) begin
    row <= a;
end

assign ra_en = ~q3;
assign vid_en = q3;
logic [7:0] vid;
always_ff@(negedge ldps) begin
    vid <= a;
end

logic [15:0] addr;
logic [7:0] din;
always_ff@(negedge q3) begin
    addr[0] <= row[0];
    addr[1] <= row[1];
    addr[2] <= row[2];
    addr[3] <= row[3];
    addr[4] <= row[4];
    addr[5] <= row[5];
    addr[6] <= a[1];
    addr[7] <= row[6];
    addr[8] <= row[7];
    addr[9] <= a[0];
    addr[10] <= a[2];
    addr[11] <= a[3];
    addr[12] <= a[4];
    addr[13] <= a[5];
    addr[14] <= a[6];
    addr[15] <= a[7];
    din <= d;
end

Gowin_RAM16S sram (
    .dout(dout), //output [7:0] dout
    .wre(~rw80), //input wre
    .ad(addr[9:0]), //input [9:0] ad
    .di(din), //input [7:0] di
    .clk(q3) //input clk
);

logic [3:0] cycle;
always_ff@(posedge clk14m) begin
    if (phi0) begin
        if (cycle >= 13) begin
            cycle = 0;
        end else begin
            cycle += 1;
        end
    end else begin
        cycle += 1;
    end
end

endmodule

`default_nettype wire