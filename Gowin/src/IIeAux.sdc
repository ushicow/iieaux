//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.02_SP2 
//Created Time: 2026-05-23 12:57:31
create_clock -name clk14m -period 69.837 -waveform {0 34.921} [get_ports {clk14m}]
create_clock -name mclk -period 37.037 -waveform {0 18.518} [get_ports {mclk}]
create_clock -name push0_n -period 10000 -waveform {0 5000} [get_nets {push0_n}]
create_generated_clock -name q3 -source [get_ports {clk14m}] -master_clock clk14m -divide_by 7 -duty_cycle 57.143 [get_ports {q3}]
create_generated_clock -name pras_n -source [get_ports {clk14m}] -master_clock clk14m -divide_by 7 -duty_cycle 30 [get_ports {pras_n}]
create_generated_clock -name pcas_n -source [get_ports {clk14m}] -master_clock clk14m -divide_by 7 -offset 414 [get_nets {pcas_n}]
create_generated_clock -name serial_clk -source [get_ports {mclk}] -master_clock mclk -divide_by 9 -multiply_by 42 [get_nets {serial_clk}]
create_generated_clock -name vga_clk -source [get_ports {mclk}] -master_clock mclk -divide_by 45 -multiply_by 42 [get_nets {vga_clk}]
create_generated_clock -name memory_clk -source [get_ports {mclk}] -master_clock mclk -divide_by 3 -multiply_by 8 [get_nets {memory_clk}]
create_generated_clock -name dma_clk -source [get_nets {memory_clk}] -master_clock memory_clk -divide_by 2 [get_nets {dma_clk}]
create_generated_clock -name phi0 -source [get_ports {clk14m}] -master_clock clk14m -divide_by 14 [get_nets {phi0}]
set_clock_groups -asynchronous -group [get_clocks {clk14m}] -group [get_clocks {dma_clk memory_clk}] -group [get_clocks {pras_n}]
set_clock_groups -asynchronous -group [get_clocks {memory_clk}] -group [get_clocks {q3 pras_n pcas_n}]
set_clock_groups -asynchronous -group [get_clocks {vga_clk}] -group [get_clocks {dma_clk}]
set_clock_groups -asynchronous -group [get_clocks {mclk}] -group [get_clocks {memory_clk}]
set_clock_groups -asynchronous -group [get_clocks {memory_clk}] -group [get_clocks {dma_clk}]
set_clock_groups -asynchronous -group [get_clocks {memory_clk}] -group [get_clocks {phi0}]
set_clock_groups -asynchronous -group [get_clocks {push0_n}] -group [get_clocks {phi0}] -group [get_clocks {mclk}] -group [get_clocks {clk14m}]
