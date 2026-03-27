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

  -- Les 4 états de ton nouveau diagramme
  type state_type is (INIT, DATA_REQUEST, MULT, DATA_OUT);
  signal curr_state, next_state : state_type;
  
  -- Toujours 6 bits car la condition est count == 32
  signal count, next_count : unsigned(5 downto 0);

begin

  -- Processus synchrone : gestion de l'horloge et du reset
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

  -- Processus combinatoire : logique des états et des sorties
  process(curr_state, count, adc_data_ready)
  begin
    -- Maintien des valeurs par défaut
    next_state <= curr_state;
    next_count <= count;

    -- Sorties par défaut basées sur l'état "Init" de ton diagramme
    adc_data_request        <= '0';
    accu_ctrl               <= '1';  -- Passe à 1 selon ta nouvelle bulle Init
    delay_line_sample_shift <= '0';
    buff_oe                 <= '0';
    dac_conv_data           <= '0';
    rom_address             <= (others => '0');
    delay_line_address      <= (others => '0');

    case curr_state is
      when INIT =>
        next_count <= (others => '0');
        if adc_data_ready = '1' then
          next_state <= DATA_REQUEST;
        end if;

      when DATA_REQUEST =>
        accu_ctrl               <= '0';
        adc_data_request        <= '1';
        delay_line_sample_shift <= '1';
        
        -- /!\ Attention : dans un process combinatoire de FSM classique, 
        -- si adc_data_ready met du temps à passer à 0, count s'incrémentera à chaque coup d'horloge.
        -- Si c'est ce qui est voulu, c'est parfait.
        next_count <= count + 1;
        
        if adc_data_ready = '0' then
          next_state <= MULT;
        end if;

      when MULT =>
        -- Sorties spécifiques à MULT (le reste garde les valeurs par défaut)
        -- Calcul des adresses (31 - count + 1 équivaut à 32 - count)
        -- J'ajoute une protection "if count > 0" pour éviter un bug VHDL si count = 0 (32 ne tient pas sur 5 bits)
        if count > 0 then
            rom_address        <= std_logic_vector(to_unsigned(32 - to_integer(count), 5));
            delay_line_address <= std_logic_vector(to_unsigned(to_integer(count) - 1, 5));
        end if;

        -- Transitions depuis MULT
        if count = 32 then
          next_state <= DATA_OUT;
        elsif adc_data_ready = '1' then
          next_state <= DATA_REQUEST;
        end if;

      when DATA_OUT =>
        -- accu_ctrl est déjà à '1' par défaut, on met les autres à 1
        buff_oe       <= '1';
        dac_conv_data <= '1';
        
        -- Retour automatique à Init (pas de condition spécifiée sur la flèche)
        next_state <= INIT;

      when others =>
        next_state <= INIT;

    end case;
  end process;

end behav;
