## Clock Signals
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_15 Sch=uclk
create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { clk }];
##set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK100MHZ }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
##create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { CLK100MHZ }];
#
# BTN0
set_property PACKAGE_PIN G15 [get_ports reset]  
set_property IOSTANDARD LVCMOS33 [get_ports reset]
#
set_property PACKAGE_PIN N14 [get_ports filter_in[0]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[0]]
set_property PACKAGE_PIN M14 [get_ports filter_in[1]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[1]]
set_property PACKAGE_PIN L18 [get_ports filter_in[2]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[2]]
set_property PACKAGE_PIN M17 [get_ports filter_in[3]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[3]]
set_property PACKAGE_PIN M18 [get_ports filter_in[4]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[4]]
set_property PACKAGE_PIN N18 [get_ports filter_in[5]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[5]]
set_property PACKAGE_PIN P14 [get_ports filter_in[6]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[6]]
set_property PACKAGE_PIN P15 [get_ports filter_in[7]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_in[7]]
#
set_property PACKAGE_PIN V14 [get_ports filter_out[0]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[0]]
set_property PACKAGE_PIN U17 [get_ports filter_out[1]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[1]]
set_property PACKAGE_PIN R13 [get_ports filter_out[2]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[2]]
set_property PACKAGE_PIN V16 [get_ports filter_out[3]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[3]]
set_property PACKAGE_PIN P13 [get_ports filter_out[4]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[4]]
set_property PACKAGE_PIN T18 [get_ports filter_out[5]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[5]]
set_property PACKAGE_PIN P16 [get_ports filter_out[6]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[6]]
set_property PACKAGE_PIN R18 [get_ports filter_out[7]]
set_property IOSTANDARD LVCMOS33 [get_ports filter_out[7]]
#
set_property IOSTANDARD LVCMOS33 [get_ports adc_eocb]
set_property PACKAGE_PIN N15 [get_ports adc_eocb]
set_property IOSTANDARD LVCMOS33 [get_ports adc_convstb]
set_property PACKAGE_PIN P17 [get_ports adc_convstb]
set_property IOSTANDARD LVCMOS33 [get_ports adc_rdb]
set_property PACKAGE_PIN P18 [get_ports adc_rdb]
set_property IOSTANDARD LVCMOS33 [get_ports adc_csb]
#### renvoi  sur unused PIN JD0
set_property PACKAGE_PIN V15 [get_ports adc_csb]
#
set_property IOSTANDARD LVCMOS33 [get_ports dac_csb]
#### renvoi  sur unused PIN JD0
set_property PACKAGE_PIN U12 [get_ports dac_csb]

set_property IOSTANDARD LVCMOS33 [get_ports dac_wrb]
set_property PACKAGE_PIN U18 [get_ports dac_wrb]

set_property IOSTANDARD LVCMOS33 [get_ports dac_ldacb]
#### renvoi  sur unused PIN JD0
set_property PACKAGE_PIN V13 [get_ports dac_ldacb]
set_property IOSTANDARD LVCMOS33 [get_ports dac_clrb]
#### renvoi  sur unused PIN JD0
set_property PACKAGE_PIN T12 [get_ports dac_clrb]
