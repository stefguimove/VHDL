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

    -- Définition des états de la machine
    type state_type is (INIT_ST, DATA_WAIT_ST, DELAY_LINE_SHIFT_ST, DATA_REQUEST_ST, MULT_ST, LOAD_BUFFER_ST, DATA_OUT_ST);
    signal current_state, next_state : state_type;

    -- Compteur interne (de 0 à 32)
    signal count, next_count : integer range 0 to 32;

begin

    -- Processus synchrone : Mise à jour de l'état et du compteur à chaque front d'horloge
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= INIT_ST;
            count         <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;
            count         <= next_count;
        end if;
    end process;

    -- Processus combinatoire : Logique du prochain état et affectation des sorties
    process(current_state, count, adc_data_ready)
    begin
        -- Valeurs par défaut pour éviter de créer des latches
        next_state              <= current_state;
        next_count              <= count;

        -- Sorties à 0 par défaut (sauf si écrasées dans un état spécifique)
        adc_data_request        <= '0';
        dac_conv_data           <= '0';
        rom_address             <= (others => '0');
        delay_line_address      <= (others => '0');
        delay_line_sample_shift <= '0';
        accu_ctrl               <= '0';
        buff_oe                 <= '0';

        case current_state is

            when INIT_ST =>
                next_count <= 0;
                next_state <= DATA_WAIT_ST;

            when DATA_WAIT_ST =>
                if adc_data_ready = '1' then
                    next_state <= DELAY_LINE_SHIFT_ST;
                end if;

            when DELAY_LINE_SHIFT_ST =>
                delay_line_sample_shift <= '1';
                next_state <= DATA_REQUEST_ST;

            when DATA_REQUEST_ST =>
                adc_data_request <= '1';
                next_count <= count + 1;

                -- On vérifie la valeur future du compteur pour déclencher la transition
                if (count + 1) = 32 then
                    next_state <= MULT_ST;
                else
                    next_state <= DATA_WAIT_ST;
                end if;

            when MULT_ST =>
                accu_ctrl <= '1';
                
                -- Utilisation de la valeur actuelle du compteur pour les adresses
                -- Cela évite les dépassements (overflow) sur 5 bits puisque count va de 32 à 1
                rom_address        <= std_logic_vector(to_unsigned(32 - count, 5));
                delay_line_address <= std_logic_vector(to_unsigned(count - 1, 5));

                next_count <= count - 1;

                -- Transition si on arrive à 0 au prochain cycle
                if (count - 1) = 0 then
                    next_state <= LOAD_BUFFER_ST;
                end if;

            when LOAD_BUFFER_ST =>
                -- accu_ctrl repasse à '0' grâce aux valeurs par défaut
                next_state <= DATA_OUT_ST;

            when DATA_OUT_ST =>
                buff_oe       <= '1';
                dac_conv_data <= '1';
                next_state    <= INIT_ST;

            when others =>
                next_state <= INIT_ST;

        end case;
    end process;

end behav;
