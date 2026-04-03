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
    type state_type is (INIT, DATA_WAIT, DELAY_LINE_SHIFT, DATA_REQUEST, MULT, LOAD_BUFFER, DATA_OUT);
    signal current_state, next_state : state_type;

    -- Compteur interne (de 0 à 32)
    signal count, next_count : integer range 0 to 32;

begin

    clock:process(clk, reset)
    begin
        if reset = '1' then
            current_state <= INIT; 
            count <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;
            count <= next_count;
        end if;
    end process;

    main:process(current_state, count, adc_data_ready)
    begin

        adc_data_request        <= '0';
        dac_conv_data           <= '0';
        rom_address             <= (others => '0');
        delay_line_address      <= (others => '0');
        delay_line_sample_shift <= '0';
        accu_ctrl               <= '0';
        buff_oe                 <= '0';
        next_state              <= current_state;
        next_count              <= count;

        case current_state is
            when INIT =>
                next_count <= 0;
                next_state <= DATA_WAIT;
                
            when DATA_WAIT =>
                adc_data_request <= '1';
                if adc_data_ready = '1' then
                    next_state <= DELAY_LINE_SHIFT;
                else
                    next_state <= DATA_WAIT;
                end if;
                
            when DELAY_LINE_SHIFT =>
                delay_line_sample_shift <= '1';
                next_state <= DATA_REQUEST;
                
            when DATA_REQUEST =>
                adc_data_request <= '1';
                next_count <= count + 1;
                delay_line_sample_shift <= '0';
                if count = 31 then
                    next_state <= MULT;
                else
                    next_state <= DATA_WAIT;
                end if;
                
            when MULT =>
                if count < 32 then
                    rom_address <= std_logic_vector(to_unsigned(31 - count, 5));
                end if;
                
                if count > 0 then
                    delay_line_address <= std_logic_vector(to_unsigned(count - 1, 5));
                end if;
                
                accu_ctrl <= '1';
                
                if count = 0 then
                    next_state <= LOAD_BUFFER;
                else
                    next_count <= count - 1; 
                    next_state <= MULT;
                end if;
                
            when LOAD_BUFFER =>
                accu_ctrl <= '1';
                next_state <= DATA_OUT;
                buff_oe <= '1';
                
            when DATA_OUT =>
                dac_conv_data <= '1';
                next_state <= INIT;
                
        end case;
    end process;

end behav;