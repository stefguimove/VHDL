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

  type state_type is (INIT, DATA_WAIT, DELAY_LINE_SHIFT, DATA_REQUEST, MULT, DATA_OUT);
  signal curr_state, next_state : state_type;
  signal count, next_count : unsigned(5 downto 0);

begin

  -- Processus synchrone : Mise à jour de l'état et du compteur à chaque front d'horloge
  process(clk, reset)
  begin
    if reset = '1' then
      curr_state <= INIT;
      count <= (others => '0');
    elsif rising_edge(clk) then
      curr_state <= next_state;
      count <= next_count;
    end if;
  end process;

  -- Processus combinatoire : Logique du prochain état et des sorties
  process(curr_state, count, adc_data_ready)
  begin 
    next_state <= curr_state;
    next_count <= count;
 
    adc_data_request        <= '0';
    accu_ctrl               <= '0';
    delay_line_sample_shift <= '0';
    buff_oe                 <= '0';
    dac_conv_data           <= '0';
    rom_address             <= (others => '0');
    delay_line_address      <= (others => '0');

    case curr_state is
      when INIT =>
        next_count <= (others => '0');
        next_state <= DATA_WAIT;

      when DATA_WAIT =>
        if adc_data_ready = '1' then
          next_state <= DELAY_LINE_SHIFT;
        end if;

      when DELAY_LINE_SHIFT =>
        delay_line_sample_shift <= '1';
        next_state <= DATA_REQUEST;

      when DATA_REQUEST =>
        adc_data_request <= '1';
        next_count <= count + 1; 
    
        if count = 31 then
          next_state <= MULT;
        else
          next_state <= DATA_WAIT;
        end if;

      when MULT =>
        accu_ctrl <= '1';
        next_count <= count - 1;    
        rom_address        <= std_logic_vector(to_unsigned(32 - to_integer(count), 5));
        delay_line_address <= std_logic_vector(to_unsigned(to_integer(count) - 1, 5));
 
        if count = 1 then
          next_state <= DATA_OUT;
        end if;

      when DATA_OUT =>
        buff_oe       <= '1';
        dac_conv_data <= '1';
        next_state    <= INIT;

      when others =>
        next_state <= INIT;

    end case;
  end process;

end behav;
