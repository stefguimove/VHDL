if [ ! -e ${TP_PATH}/libs/lib_SYNTH ]
then
  vlib ${TP_PATH}/libs/lib_SYNTH
fi

vmap lib_SYNTH ${TP_PATH}/libs/lib_SYNTH

vcom  -work lib_SYNTH filtre.vhdl
