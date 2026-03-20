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

  -- States definition based on Figure 10 and the note
  type state_type is (init, wait_data_req, convst, eoc_wait, rd, rd_wr);
  signal curr_state, next_state : state_type;

begin

  -- FSM implementation: Registre d'état (Processus synchrone)
  process(clk, reset)
  begin
    if reset = '1' then
      curr_state <= init;
    elsif rising_edge(clk) then
      curr_state <= next_state;
    end if;
  end process;

  -- FSM implementation: Logique combinatoire
  process(curr_state, adc_data_request, adc_eocb)
  begin
    adc_data_ready      <= '0';
    adc_convstb         <= '1';
    adc_rdb             <= '1';
    adc_csb             <= '1';
    adc_write_conv_data <= '0';

    case curr_state is
    
      -- État caché mentionné dans la note : aucune donnée n'est prête au démarrage
      when init =>
        next_state <= convst;

      -- État d'attente d'une requête de la FSM principale
      when wait_data_req =>
        adc_data_ready <= '1';
        adc_write_conv_data <= '0';
        adc_rdb <= '1';
        adc_csb <= '1';
        if adc_data_request = '1' then
          next_state <= convst;
        else
          next_state <= wait_data_req;
        end if;

      -- Lancement de la conversion
      when convst =>
        adc_convstb <= '0';
        adc_data_ready <= '0';
        next_state <= eoc_wait;

      -- Attente de la fin de conversion de l'ADC
      when eoc_wait =>
        adc_convstb <= '1';
        if adc_eocb = '0' then
          next_state <= rd;
        else
          next_state <= eoc_wait;
        end if;

      -- Début de la lecture (on active les signaux Chip Select et Read)
      when rd =>
        adc_rdb <= '0';
        adc_csb <= '0';
        next_state <= rd_wr;

      -- Maintien de la lecture et ordre d'écriture dans le registre du FPGA
      when rd_wr =>
        adc_write_conv_data <= '1';
        next_state <= wait_data_req;

    end case;
  end process;

end a;


