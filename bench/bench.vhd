library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library lib_RTL;
--library lib_SYNTH;
--library lib_ASIC;

entity bench_filter is
end entity;

architecture arch of bench_filter is

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

    signal CLK        			: std_logic := '0';
    signal RESET      			: std_logic;
    signal Filter_In  			: std_logic_vector(7 downto 0):="00000000";
    signal Filter_Out 			: std_logic_vector(7 downto 0);
    signal ADC_eocb    			: std_logic;
    signal ADC_convstb 			: std_logic;
    signal ADC_rdb     			: std_logic;
    signal ADC_csb    			: std_logic;
    signal DAC_wrb     			: std_logic;
    signal DAC_csb     			: std_logic;
    signal DAC_ldacb   			: std_logic;
    signal DAC_clrb    			: std_logic;
    signal ADC_convstb_delayed 	: std_logic;
    signal ADC_eocb_delayed    	: std_logic;

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

    CLK   <= not(CLK) after 10 ns;
    RESET <= '1', '0' after 45 ns;

-- Check ADV behavior
verif_time: process 
	variable t : time;
begin
	wait on ADC_convstb;

	if ADC_convstb'event and ADC_convstb='0' then
		t:= ADC_rdb'last_event;
		assert t>= (30 ns)  report "new conversion starts 30 ns after a read" severity warning;
		wait on ADC_convstb;

		t:= ADC_convstb_delayed'last_event;
		assert t>= (20 ns)  report "a conversion pulse is at least 20 ns" severity warning;
		wait on ADC_eocb;

		t:= ADC_convstb_delayed'last_event;
		assert (t<= (420 ns) and t>= (120 ns))  report "eoc is enabled between 120 ns and 420 ns after a start conversion" severity warning;
		wait on ADC_eocb;

		t:= ADC_eocb_delayed'last_event;
		assert (t<= (110 ns) and t>= (70 ns))  report "eoc pulse is at least 70 ns and at most 110 ns" severity warning;
	end if;
end process verif_time;

-- Simulate Filter input
Filter_in_rep_impuls: process 
	variable j :natural range 0 to 31 ; 
begin
	Filter_in<=(others=>'0');
	wait for 50 ns;

	Filter_in<=(others=>'1');
	wait for 20 us;

	assert False report "End of test" severity failure;
end process Filter_in_rep_impuls;

-- Simulate ADC Behavior
process_ADC : process(ADC_Convstb)
begin
	ADC_eocb <= '0';

	if ADC_Convstb'event and ADC_Convstb = '0' then
		ADC_eocb <= '1', '0' after 300 ns, '1' after 400 ns;
	end if;

end process;
end architecture;  -- arch
