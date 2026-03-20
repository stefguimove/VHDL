if [ ! -e ${TP_PATH}/libs/lib_RTL ]
then
  vlib ${TP_PATH}/libs/lib_RTL
fi

  vmap lib_RTL ${TP_PATH}/libs/lib_RTL 

sources=( accu.vhd buff.vhd delayline.vhd fsm.vhd mult.vhd dac_interface.vhd adc_interface.vhd register.vhd rom.vhd filtre.vhd )

for i in "${sources[@]}"
 do
   vcom +acc -work lib_RTL  $i
   if [ $? -ne 0 ]; then
     break
   fi  
 done


