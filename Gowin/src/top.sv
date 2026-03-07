`default_nettype none
// Apple IIe Aux Card
// Test1 2026.01.12 by ushicow

module top (
    input wire [7:0] d,
    input wire [7:0] ra,
    input wire [7:0] x,
    input wire [7:0] y,
    input wire pal,
    input wire mclk
);

logic pras_n;
logic q3;
logic rw80;
logic en80_n;
logic rw;
logic phi0;
logic phi1;
logic clk14m;
logic [15:0] ad;
logic [7:0] ad0;

always_ff@(negedge pras_n) begin
    ad0[7:0] <= ra;
end

always_ff@(negedge q3) begin
    ad[15:8] <= ra;
    ad[7:0] <= ad0;
end

assign pras_n = y[0];
assign q3 = y[1];
assign rw80 = y[2];
assign en80_n = y[3];
assign rw = y[4];
assign phi0 = y[5];
assign phi1 = y[6];
assign clk14m = y[7];

endmodule

`default_nettype wire