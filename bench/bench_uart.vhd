library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

library lib_RTL;
--library lib_SYNTH;

entity bench_uart is
end entity;

architecture arch of bench_uart is
    component filter port(
        filter_in   : in  std_logic_vector(7 downto 0);
        clk         : in  std_logic;
        reset       : in  std_logic;
        adc_eocb    : in  std_logic;
        adc_convstb : out std_logic;
        adc_rdb     : out std_logic;
        adc_csb     : out std_logic;
        dac_wrb     : out std_logic;
        dac_csb     : out std_logic;
        dac_ldacb   : out std_logic;
        dac_clrb    : out std_logic;
        filter_out  : out std_logic_vector(7 downto 0)
    );
    end component;

    -- Signal declarations
    signal CLK         : std_logic := '0';
    signal RESET       : std_logic;
    signal Filter_In   : std_logic_vector(7 downto 0):="00000000";
    signal Filter_Out  : std_logic_vector(7 downto 0);
    signal Filter_Out_Thresholded : std_logic;
    signal ADC_eocb     : std_logic;
    signal ADC_convstb  : std_logic;
    signal ADC_rdb      : std_logic;
    signal ADC_csb      : std_logic;
    signal DAC_wrb      : std_logic;
    signal DAC_csb      : std_logic;
    signal DAC_ldacb    : std_logic;
    signal DAC_clrb     : std_logic;
    signal ADC_convstb_delayed : std_logic;
    signal ADC_eocb_delayed     : std_logic;
    signal CLK_UART            : std_logic := '0';

    constant C_UART_BAUD_RATE  : real := 9600.0;
    constant C_UART_CLK_HALF_PERIOD : time := (1.0 / C_UART_BAUD_RATE) * 1 sec / 2.0;
    constant C_INPUT_FILENAME : string := "bench/uart_noisy.csv";

    function to_hstring (value : std_logic_vector) return string is
        constant hex_chars : string := "0123456789ABCDEF";
        variable result    : string(1 to value'length / 4);
        variable current_nibble : std_logic_vector(3 downto 0);
        variable char_idx  : integer;
    begin
        if value'length mod 4 /= 0 then
            report "Error: to_hstring: Input std_logic_vector length must be a multiple of 4 for hexadecimal conversion." severity error;
            return "";
        end if;

        for i in 0 to (value'length / 4) - 1 loop
            current_nibble := value((value'length - 1) - (i * 4) downto (value'length - 4) - (i * 4));
            char_idx := to_integer(unsigned(current_nibble));
            result((i + 1)) := hex_chars(char_idx + 1);
        end loop;

        return result;
    end function to_hstring;
    
    -- Converts a single hexadecimal character to its integer value
    function hex_char_to_integer (c : character) return integer is
    begin
        case c is
            when '0' to '9' => return character'pos(c) - character'pos('0');
            when 'A' to 'F' => return character'pos(c) - character'pos('A') + 10;
            when 'a' to 'f' => return character'pos(c) - character'pos('a') + 10;
            when others =>
                report "Error: Invalid hexadecimal character '" & character'image(c) & "'" severity error;
                return 0;
        end case;
    end function hex_char_to_integer;

    -- Converts a 2-character hexa to an 8-bit std_logic_vector
    function hex_string_to_std_logic_vector (hex_str : string) return std_logic_vector is
        variable val_int : integer;
    begin
        if hex_str'length /= 2 then
            report "Error: Hex string must be 2 characters for 8-bit std_logic_vector" severity error;
            return std_logic_vector(to_unsigned(0, 8));
        end if;

        val_int := hex_char_to_integer(hex_str(hex_str'left)) * 16;
        val_int := val_int + hex_char_to_integer(hex_str(hex_str'right));
        return std_logic_vector(to_unsigned(val_int, 8));
    end function hex_string_to_std_logic_vector;

    -- Converts a string of digits to an integer
    function string_to_integer (s : string) return integer is
        variable result : integer := 0;
        variable digit  : integer;
    begin
        for i in s'range loop
            if s(i) >= '0' and s(i) <= '9' then
                digit := character'pos(s(i)) - character'pos('0');
                result := result * 10 + digit;
            else
                report "Error: Invalid character in integer string: '" & character'image(s(i)) & "'" severity error;
                return 0; -- Error code
            end if;
        end loop;
        return result;
    end function string_to_integer;

begin
    DUT : filter port map (
        clk          => CLK,
        reset         => RESET,
        adc_eocb    => ADC_eocb,
        adc_convstb  => ADC_convstb,
        adc_rdb     => ADC_rdb,
        adc_csb      => ADC_csb,
        dac_wrb        => DAC_wrb,
        dac_csb      => DAC_csb,
        dac_ldacb   => DAC_ldacb,
        dac_clrb    => DAC_clrb,
        filter_out  => Filter_Out,
        filter_in  => Filter_In
    );

    CLK_UART <= not(CLK_UART) after C_UART_CLK_HALF_PERIOD;
    CLK   <= not(CLK) after 10 ns;
    RESET <= '1', '0' after 45 ns;

    verif_time: process
        variable t : time;
    begin
        wait on ADC_convstb;
        if ADC_convstb'event and ADC_convstb='0' then
            t:= ADC_rdb'last_event;
            assert t>= (30 ns)  report "new conversion starts 30 ns after a read" severity warning;
            wait on ADC_convstb;
            wait on ADC_eocb;
            wait on ADC_eocb;
        end if;
    end process verif_time;

    process_ADC : process(ADC_Convstb)
    begin
        ADC_eocb <= '0';
        if ADC_Convstb'event and ADC_Convstb = '0' then
            ADC_eocb <= '1', '0' after 300 ns, '1' after 400 ns;
        end if;
    end process;

    Filter_in_driver: process
        file     F_INPUT_FILE     : TEXT open READ_MODE is C_INPUT_FILENAME;
        variable V_LINE           : LINE;
        variable V_TIME_STR       : string(1 to 10);
        variable V_VALUE_STR      : string(1 to 2);
        variable V_COMMA_CHAR     : character;
        variable V_TIME_NS        : integer;
        variable V_FILTER_VALUE   : std_logic_vector(7 downto 0);
        variable V_CURRENT_SIM_TIME : time := 0 ns;
        variable V_WAIT_TIME      : time;
        variable V_LINE_COUNT     : integer := 0;
        variable V_FULL_LINE_TEXT : string(1 to 10);

        variable V_TIME_SUBSTRING : string(1 to 7);
        variable V_VALUE_SUBSTRING : string(1 to 2);
        variable V_COMMA_POS      : integer;
    begin
        if not endfile(F_INPUT_FILE) then
            readline(F_INPUT_FILE, V_LINE);
            V_LINE_COUNT := V_LINE_COUNT + 1;
        end if;

        while not endfile(F_INPUT_FILE) loop
            readline(F_INPUT_FILE, V_LINE);
            V_LINE_COUNT := V_LINE_COUNT + 1;

            read(V_LINE, V_FULL_LINE_TEXT);

            V_COMMA_POS := 0;
            for i in V_FULL_LINE_TEXT'range loop
                if V_FULL_LINE_TEXT(i) = ',' then
                    V_COMMA_POS := i;
                    exit;
                end if;
            end loop;

            if V_COMMA_POS = 0 then
                report "Error: Missing comma in line " & integer'image(V_LINE_COUNT) & ": " & V_FULL_LINE_TEXT severity error;
                next;
            end if;
            
            V_TIME_SUBSTRING := V_FULL_LINE_TEXT(V_FULL_LINE_TEXT'left to V_COMMA_POS - 1);
            V_VALUE_SUBSTRING := V_FULL_LINE_TEXT(V_COMMA_POS + 1 to V_FULL_LINE_TEXT'right);
        
            V_TIME_NS := string_to_integer(V_TIME_SUBSTRING);
            V_FILTER_VALUE := hex_string_to_std_logic_vector(V_VALUE_SUBSTRING);

            if V_TIME_NS * 1 ns >= V_CURRENT_SIM_TIME then
                V_WAIT_TIME := (V_TIME_NS * 1 ns) - V_CURRENT_SIM_TIME;
                if V_WAIT_TIME > 0 ns then
                    wait for V_WAIT_TIME;
                end if;
                V_CURRENT_SIM_TIME := V_TIME_NS * 1 ns;
            end if;

            Filter_In <= V_FILTER_VALUE;
        end loop;

        file_close(F_INPUT_FILE);
        report "Finished reading " & C_INPUT_FILENAME & ". Stopping." severity failure;
        wait;
    end process Filter_in_driver;

    -- Simulate reading the filter output: set the line value as seen after thresholding
    thresholding : process (Filter_Out)
    begin
        if Filter_Out > "01110000" then -- "01110000" is the threshold value
            Filter_Out_Thresholded <= '1';
        else
            Filter_Out_Thresholded <= '0';
        end if;
    end process thresholding;
end architecture;