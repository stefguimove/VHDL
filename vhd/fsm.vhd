------------------------------fsm.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  port(clk                     : in  std_logic;
       reset                   : in  std_logic;
       adc_data_ready          : in  std_logic;
       adc_data_request        : out std_logic;
       dac_conv_data           : out std_logic;
       rom_address             : out std_logic_vector(4 downto 0);
       delay_line_address      : out std_logic_vector(4 downto 0);
       delay_line_sample_shift : out std_logic;
       accu_ctrl               : out std_logic;
       buff_oe                 : out std_logic) ;
end fsm;

architecture behav of fsm is

end behav;
