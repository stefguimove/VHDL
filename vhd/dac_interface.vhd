------------------------------dac_interface.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dac_interface is
	port(
		clk           : in  std_logic;
		reset         : in  std_logic;
		dac_conv_data : in  std_logic;
		dac_wrb       : out std_logic;
		dac_csb       : out std_logic;
		dac_ldacb     : out std_logic;
		dac_clrb      : out std_logic
	);
end dac_interface;

architecture arch of dac_interface is
	type state is (init, send);
	signal current_state : state;
	signal next_state    : state;
begin

	p_seq: process(clk, reset)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				current_state <= init;
			else
				current_state <= next_state;
			end if;
		end if;
	end process p_seq;


	p_comb_ns: process (dac_conv_data, current_state)
	begin
		case current_state is
			when init =>
				if dac_conv_data = '0' then
					next_state <= init;
				else
					--  le front montant de la requête lance la conversion 
					next_state <= send;
				end if;

			when send =>
				-- y rester le temps nécessaire (dépend de la fréquence du circuit) au moins 20 ns
				next_state <= init;  
		end case;
	end process p_comb_ns;

	p_comb_out: process (current_state)
	begin
		dac_ldacb <= '0';
		dac_clrb  <= '1';

		case current_state is
			when init =>
				dac_wrb <= '1';
				dac_csb <= '1';
			when send =>
				dac_wrb <= '0';
				dac_csb <= '0';
		end case;
	end process p_comb_out;
end;
