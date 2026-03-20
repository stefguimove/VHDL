------------------------------adc_interface.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity adc_interface is
  port(clk                 : in  std_logic;
       reset               : in  std_logic;
       adc_data_request    : in  std_logic;
       adc_eocb            : in  std_logic;
       adc_data_ready      : out std_logic;
       adc_convstb         : out std_logic;
       adc_rdb             : out std_logic;
       adc_csb             : out std_logic;
       adc_write_conv_data : out std_logic

       );
end adc_interface;
architecture a of adc_interface is

-- States definition

begin
  -- FSM implementation
end a;


