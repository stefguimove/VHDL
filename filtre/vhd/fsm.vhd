------------------------------fsm.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  port(clk                     : in  std_logic;
       reset                   : in  std_logic;
       adc_data_ready          : in  std_logic;
       adc_data_request        : out std_logic;
       dac_conv_data        : out std_logic;
       rom_address             : out std_logic_vector(4 downto 0);
       delay_line_address      : out std_logic_vector(4 downto 0);
       delay_line_sample_shift : out std_logic;
       accu_ctrl               : out std_logic;
       buff_oe                 : out std_logic) ;
end fsm;

-- machine à états contrôlant le filtre numérique.

architecture behav of fsm is

   type   STATE is (S0, S1);
    signal Current_State, Next_State   : STATE;
    signal Counter, Next_Counter : std_logic_vector(4 downto 0);

begin

    P_STATE : process(Clk)
    begin
        if RESET = '1' then
            Current_State <= S0;
        elsif CLK = '1' and CLK'event then
            Current_State <= Next_State;
        end if;
    end process P_STATE;

    P_FSM : process(Current_State)
    begin
        
        case Current_State is
            when S0 => 
             Next_State <= S1;
	     
            when S1 => 
             Next_State <= S0;
       	   end case;
end process;
	    


end behav;
