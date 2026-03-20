//`include "./INPUT_DATA/filter.v"

module filter_io (
	clk, reset, filter_in, filter_out, adc_eocb, adc_convstb,
	adc_rdb, adc_csb, dac_wrb, dac_csb, dac_ldacb, dac_clrb );

	input [7:0] filter_in;
	output [7:0] filter_out;
	
	input clk, reset, adc_eocb;
	output adc_convstb, adc_csb, adc_rdb, dac_wrb, dac_csb, dac_ldacb, dac_clrb;
	
	wire CLK_P, RESET_P, adc_convstb_P, adc_rdb_P, adc_csb_P, dac_wrb_P, dac_csb_P, LDACb_P, CLRB_P;
	wire [7:0] filter_in_P;
	wire [7:0] filter_out_P;


filter t_op (
	.clk(CLK_P), .reset(RESET_P), .filter_in(filter_in_P[7:0]),
	.filter_out(filter_out_P[7:0]), .adc_eocb(adc_eocb_P),
	.adc_convstb(adc_convstb_P), .adc_rdb(adc_rdb_P),
	.adc_csb(adc_csb_P), .dac_wrb(dac_wrb_P), .dac_csb(dac_csb_P),
	.dac_ldacb(LDACb_P), .dac_clrb(CLRB_P)
);


	ITP io_CLK ( .PAD(clk), .Y(CLK_P) );
	
	ITP io_reset ( .PAD(reset), .Y(RESET_P) );	
	

	ITP io_filter_in_7 ( .PAD(filter_in[7]), .Y(filter_in_P[7]) );
	ITP io_filter_in_6 ( .PAD(filter_in[6]), .Y(filter_in_P[6]) );
	ITP io_filter_in_5 ( .PAD(filter_in[5]), .Y(filter_in_P[5]) );
	ITP io_filter_in_4 ( .PAD(filter_in[4]), .Y(filter_in_P[4]) );
	ITP io_filter_in_3 ( .PAD(filter_in[3]), .Y(filter_in_P[3]) );
	ITP io_filter_in_2 ( .PAD(filter_in[2]), .Y(filter_in_P[2]) );
	ITP io_filter_in_1 ( .PAD(filter_in[1]), .Y(filter_in_P[1]) );
	ITP io_filter_in_0 ( .PAD(filter_in[0]), .Y(filter_in_P[0]) );

	BU12SP io_filter_out_7 ( .A(filter_out_P[7]), .PAD(filter_out[7]) );
	BU12SP io_filter_out_6 ( .A(filter_out_P[6]), .PAD(filter_out[6]) );
	BU12SP io_filter_out_5 ( .A(filter_out_P[5]), .PAD(filter_out[5]) );
	BU12SP io_filter_out_4 ( .A(filter_out_P[4]), .PAD(filter_out[4]) );
	BU12SP io_filter_out_3 ( .A(filter_out_P[3]), .PAD(filter_out[3]) );
	BU12SP io_filter_out_2 ( .A(filter_out_P[2]), .PAD(filter_out[2]) );
	BU12SP io_filter_out_1 ( .A(filter_out_P[1]), .PAD(filter_out[1]) );
	BU12SP io_filter_out_0 ( .A(filter_out_P[0]), .PAD(filter_out[0]) );	

	ITP io_adc_eocb ( .PAD(adc_eocb), .Y(adc_eocb_P) );

	BU12SP io_adc_convstb ( .A(adc_convstb_P), .PAD(adc_convstb) );
	
	BU12SP io_adc_rdb 	 ( .A(adc_rdb_P), .PAD(adc_rdb) );
	
	BU12SP io_adc_csb 	 ( .A(adc_csb_P), .PAD(adc_csb) );
	
	BU12SP io_dac_wrb 	 ( .A(dac_wrb_P), .PAD(dac_wrb) );
	
	BU12SP io_dac_csb 	 ( .A(dac_csb_P), .PAD(dac_csb) );
	
	BU12SP io_dac_ldacb  ( .A(LDACb_P), .PAD(dac_ldacb) );

	BU12SP io_clrb 	 ( .A(CLRB_P), .PAD(CLRB) );
	
endmodule	
	
