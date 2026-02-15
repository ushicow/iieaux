`default_nettype none
// Apple IIe Aux Card
// 2026.01.12 80 Colmun Text

module top (
    inout wire [7:0] d,
    input wire [7:0] ra,
    input wire [7:0] vid,
    input wire pras_n,
    input wire q3,
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
    input wire pal,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5,
    output wire led6,
    input wire mclk
);

assign led1 = gr;
assign led2 = vid80;
assign led3 = an3;

assign d = (rw80 & ~q3) ? dout : 8'bz;

logic [7:0] dout;
logic [9:0] ad;
logic [7:0] row;

always_ff@(negedge pras_n) begin
    row <= ra;
end

logic [15:0] addr;      // for debug
always_ff@(negedge q3) begin
    ad[9:8] <= ra[1:0];
    ad[7:0] <= row;
    addr <= {ra, row};  // for debug
end

Gowin_RAM16S sram (
    .dout(dout), //output [7:0] dout
    .wre(~rw80), //input wre
    .ad(ad), //input [9:0] ad
    .di(d), //input [7:0] di
    .clk(q3) //input clk
);

logic [9:0] pix;
logic [7:0] line;
logic [9:0] count;
always_ff@(posedge clk14m) begin
    if (sync) begin
        if (count == 0) begin
            line <= line + 1;
        end
        count <= count + 1;
    end else begin
        count <= 0;
    end
end

endmodule

`default_nettype wire