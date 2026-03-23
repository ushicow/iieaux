//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.01
//IP Version: 2.3
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Mon Mar 23 14:04:41 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Scaler_Lite_Up_Top your_instance_name(
		.I_reset(I_reset), //input I_reset
		.I_sysclk(I_sysclk), //input I_sysclk
		.I_vin_ref_vs(I_vin_ref_vs), //input I_vin_ref_vs
		.I_vin_ref_de(I_vin_ref_de), //input I_vin_ref_de
		.O_vin_vs_req(O_vin_vs_req), //output O_vin_vs_req
		.O_vin_de_req(O_vin_de_req), //output O_vin_de_req
		.I_buf_fstline_rdy(I_buf_fstline_rdy), //input I_buf_fstline_rdy
		.I_vin_data0_cpl(I_vin_data0_cpl), //input [7:0] I_vin_data0_cpl
		.I_vin_data1_cpl(I_vin_data1_cpl), //input [7:0] I_vin_data1_cpl
		.I_vin_data2_cpl(I_vin_data2_cpl), //input [7:0] I_vin_data2_cpl
		.O_vout0_data(O_vout0_data), //output [7:0] O_vout0_data
		.O_vout1_data(O_vout1_data), //output [7:0] O_vout1_data
		.O_vout2_data(O_vout2_data), //output [7:0] O_vout2_data
		.O_vout_vs(O_vout_vs), //output O_vout_vs
		.O_vout_de(O_vout_de) //output O_vout_de
	);

//--------Copy end-------------------
