vdel -lib ${TP_PATH}/libs/lib_ASIC -all
vlib ${TP_PATH}/libs/lib_ASIC
vmap lib_ASIC ${TP_PATH}/libs/lib_ASIC

vlog  -work lib_ASIC filter.v
