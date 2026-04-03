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

    type state_type is (INIT_ST, DATA_WAIT_ST, DELAY_LINE_SHIFT_ST, DATA_REQUEST_ST, MULT_ST, LOAD_BUFFER_ST, DATA_OUT_ST);
    signal current_state, next_state : state_type;

    -- Compteur interne (de 0 à 31 est suffisant)
    signal count, next_count : integer range 0 to 31;

begin

    -- Processus synchrone
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

    -- Processus combinatoire
    process(current_state, count, adc_data_ready)
    begin
        -- Valeurs par défaut
        next_state              <= current_state;
        next_count              <= count;
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
                next_count <= 0; -- On prépare le compteur pour le calcul
                next_state <= MULT_ST; -- On va DIRECTEMENT calculer, pas d'attente !

            when MULT_ST =>
                -- Adressage direct de 0 à 31
                rom_address        <= std_logic_vector(to_unsigned(count, 5));
                delay_line_address <= std_logic_vector(to_unsigned(count, 5));

                -- Écrasement de l'ancien résultat au premier cycle, accumulation ensuite
                if count = 0 then
                    accu_ctrl <= '0';
                else
                    accu_ctrl <= '1';
                end if;

                -- Gestion de la boucle de 32 multiplications
                if count = 31 then
                    next_state <= LOAD_BUFFER_ST;
                else
                    next_count <= count + 1;
                    next_state <= MULT_ST;
                end if;

            when LOAD_BUFFER_ST =>
                -- On maintient l'accumulation si le datapath a 1 cycle de latence (pipeline)
                accu_ctrl <= '1';
                next_state <= DATA_OUT_ST;

            when DATA_OUT_ST =>
                buff_oe       <= '1';
                dac_conv_data <= '1';
                -- On a fini un échantillon, on retourne attendre le prochain de l'ADC
                next_state    <= DATA_WAIT_ST; 

            when others =>
                next_state <= INIT_ST;

        end case;
    end process;

end behav;