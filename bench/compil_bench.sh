vdel -lib ${TP_PATH}/libs/lib_BENCH -all
vlib ${TP_PATH}/libs/lib_BENCH
vmap lib_BENCH ${TP_PATH}/libs/lib_BENCH 

#Compile VHDL testbench files into the lib_BENCH library
vcom +acc -work lib_BENCH bench.vhd
#vcom +acc -work lib_BENCH bench_sinus.vhd
#vcom +acc -work lib_BENCH bench_uart.vhd
