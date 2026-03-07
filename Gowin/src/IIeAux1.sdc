//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.01 
//Created Time: 2026-01-23 20:19:04
create_clock -name mclk -period 37.037 -waveform {0 18.518} [get_ports {mclk}]
create_clock -name clk14m -period 71.429 -waveform {0 35.715} [get_ports {y[7]}]
