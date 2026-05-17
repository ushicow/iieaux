// ---------------------------------------------------------------------
// File name         : vga_sync.sv
// Module name       : VGA_Sync
// Module Description: make standard VGA sync signals
// Created by        : ushicow
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 2026/03/22  | ushicow |    initial
// --------------------------------------------------------------------
`default_nettype none

module VGA_Sync
(
    input wire I_pxl_clk,   // pixel clock 25.175 MHz
    input wire I_rst_n,     // reset, low active 
    output reg O_vs_n,      // Vertical sync, low active
    output reg O_hs_n,      // Horizontal sync, low active
    output reg O_de         // Data enable
);

// VGA 640 x 480, 60 fps, 25.175 MHz
parameter ACTIVE_PIXEL = 640;
parameter ACTIVE_LINE = 480;
parameter FPORCH_PIXEL = ACTIVE_PIXEL + 16;
parameter SYNC_PIXEL = FPORCH_PIXEL + 96;
parameter BPORCH_PIXEL = SYNC_PIXEL + 48;
parameter FPORCH_LINE = ACTIVE_LINE + 10;
parameter SYNC_LINE = FPORCH_LINE + 2;
parameter BPORCH_LINE = SYNC_LINE + 33;
parameter TOTAL_PIXEL = BPORCH_PIXEL;   // 800
parameter TOTAL_LINE = BPORCH_LINE;     // 525

reg [9:0] hcount; // 0 .. TOTAL_PIXEL - 1
reg [9:0] vcount; // 0 .. TOTAL_LINE - 1
reg vga_vs_n;
reg vga_hs_n;
reg vga_de;
always @(posedge I_pxl_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        vcount <= 0;
        hcount <= 0;
    end else begin
        if (hcount == FPORCH_PIXEL) begin
            vga_hs_n <= 0;
            if (vcount == FPORCH_LINE) begin
                vga_vs_n <= 0;
            end
            if (vcount == SYNC_LINE) begin
                vga_vs_n <= 1;
            end
            if (vcount == (TOTAL_LINE - 1)) begin
                vcount <= 0;
            end else begin
                vcount <= vcount + 1'b1;
            end
        end
        if (hcount == SYNC_PIXEL) begin
            vga_hs_n <= 1;
        end

        if (hcount == (TOTAL_PIXEL - 1)) begin
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

always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if (!I_rst_n) begin
		begin 
			O_vs_n  <= 1;
			O_hs_n  <= 1;
			O_de  <= 0;                       
		end
	end else begin 
		begin   
			O_vs_n  <= vga_vs_n;
			O_hs_n  <= vga_hs_n;
			O_de  <= vga_de;                      
		end
    end
end

endmodule

`default_nettype wire