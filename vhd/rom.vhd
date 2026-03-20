------------------------------rom.vhd-------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port(rom_address : in  std_logic_vector(4 downto 0);
       rom_out     : out std_logic_vector(7 downto 0)) ;
end rom;

architecture a of rom is
  type tab_rom is array (0 to 31) of std_logic_vector(7 downto 0);
  constant filter_rom : tab_rom :=
    (0  => "00000010", 1 => "00001011", 2 => "00010110", 3 => "00100101",
     4  => "00110110", 5 => "01001010", 6 => "01011111", 7 => "01110110",
     8  => "10001101", 9 => "10100011", 10 => "10111000", 11 => "11001011",
     12 => "11011011", 13 => "11101000", 14 => "11110000", 15 => "11110101",
     16 => "11110101", 17 => "11110000", 18 => "11101000", 19 => "11011011",
     20 => "11001011", 21 => "10111000", 22 => "10100011", 23 => "10001101",
     24 => "01110110", 25 => "01011111", 26 => "01001010", 27 => "00110110",
     28 => "00100101", 29 => "00010110", 30 => "00001011", 31 => "00000010");

begin

  rom_out <= filter_rom(to_integer(unsigned(rom_address)));

end a;

