//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.01 
//Created Time: 2026-02-14 21:16:13
create_clock -name clk14m -period 71.429 -waveform {0 35.715} [get_ports {clk14m}]
create_clock -name q3 -period 490 -waveform {0 280} [get_ports {q3}]
create_clock -name pras_n -period 490 -waveform {0 140} [get_ports {pras_n}]
