//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.01 
//Created Time: 2026-03-23 15:57:14
create_clock -name clk14m -period 71.429 -waveform {0 35.715} [get_ports {clk14m}]
create_clock -name q3 -period 490 -waveform {0 280} [get_ports {q3}]
create_clock -name pras_n -period 490 -waveform {0 140} [get_ports {pras_n}]
create_clock -name mclk -period 37.037 -waveform {0 18.518} [get_ports {mclk}]
create_clock -name serial_clk -period 7.937 -waveform {0 3.969} [get_nets {serial_clk}]
create_clock -name vga_clk -period 39.683 -waveform {0 19.841} [get_nets {vga_clk}]
create_clock -name memory_clk -period 8.333 -waveform {0 4.167} [get_nets {memory_clk}]
create_clock -name dma_clk -period 16.667 -waveform {0 8.334} [get_nets {dma_clk}]
set_clock_groups -exclusive -group [get_clocks {clk14m}] -group [get_clocks {mclk}] -group [get_clocks {serial_clk}] -group [get_clocks {vga_clk}] -group [get_clocks {memory_clk}] -group [get_clocks {dma_clk}]
