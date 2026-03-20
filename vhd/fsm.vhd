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

  type state_type is (IDLE, GET_SAMPLE, MAC_COMPUTE, UPDATE_OUTPUT);
  signal curr_state, next_state : state_type;
  signal count, next_count : unsigned(4 downto 0);

begin

  process(clk, reset)
  begin
    if reset = '1' then
      curr_state <= IDLE;
      count      <= (others => '0');
    elsif rising_edge(clk) then
      curr_state <= next_state;
      count      <= next_count;
    end if;
  end process;

  process(curr_state, count, adc_data_ready)
  begin 
    next_state <= curr_state;
    next_count <= count;

    case curr_state is
      
      when IDLE =>
        if adc_data_ready = '1' then
          next_state <= GET_SAMPLE;
        end if;

      when GET_SAMPLE =>
        next_count <= (others => '0');
        next_state <= MAC_COMPUTE;

      when MAC_COMPUTE =>
        if count = 31 then
          next_state <= UPDATE_OUTPUT;
        else
          next_count <= count + 1;   
        end if;

      when UPDATE_OUTPUT =>
        next_state <= IDLE;         

    end case;
  end process;

  process(curr_state, count)
  begin 
    adc_data_request        <= '0';
    dac_conv_data           <= '0';
    delay_line_sample_shift <= '0';
    accu_ctrl               <= '1';
    buff_oe                 <= '0';
    rom_address             <= (others => '0');
    delay_line_address      <= (others => '0');

    case curr_state is
      
      when IDLE => 
        null;

      when GET_SAMPLE => 
        adc_data_request        <= '1';
        delay_line_sample_shift <= '1';
        accu_ctrl               <= '0'; 
        
      when MAC_COMPUTE =>
        rom_address        <= std_logic_vector(count); 
        delay_line_address <= std_logic_vector(not count);
        
        if count = 0 then
          accu_ctrl <= '0'; 
        else
          accu_ctrl <= '1'; 
        end if;

      when UPDATE_OUTPUT =>
        buff_oe       <= '1';
        dac_conv_data <= '1';

    end case;
  end process;

end behav;
