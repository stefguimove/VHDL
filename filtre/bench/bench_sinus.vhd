----------------------------------- bench filter-------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.math_real.all;



library modelsim_lib;
use modelsim_lib.util.all;

library lib_VHDL;
--library lib_SYNTH;

entity bench_sinus is
end entity;  -- bench_filter

architecture arch of bench_sinus is

  component filter
    port(
      	    Filter_In    : in  std_logic_vector(7 downto 0);
        CLK         : in  std_logic;
        RESET       : in  std_logic;
        ADC_Eocb     : in  std_logic;
        ADC_Convstb : out std_logic;
        ADC_Rdb      : out std_logic;
        ADC_csb     : out std_logic;
        DAC_WRb      : out std_logic;
        DAC_csb      : out std_logic;
        LDACb        : out std_logic;
        CLRB         : out std_logic;
        Filter_Out  : out std_logic_vector(7 downto 0)) ;  
  end component;

  signal CLK        : std_logic := '0';
    signal RESET      : std_logic;
    signal Filter_In  : std_logic_vector(7 downto 0):="00000000";
    signal Filter_Out : std_logic_vector(7 downto 0);
    signal ADC_eocb    : std_logic;
    signal ADC_convstb : std_logic;
    signal ADC_rdb     : std_logic;
    signal ADC_csb     : std_logic;
    signal DAC_wrb     : std_logic;
    signal DAC_csb     : std_logic;
    signal DAC_ldacb   : std_logic;
    signal DAC_clrb    : std_logic;
    signal Buff_OE    : std_logic;
  

 ------Sinus utility functions begin
function quantization_sgn(nbit : integer; max_abs : real; dval : real) return std_logic_vector is
variable temp    : std_logic_vector(nbit-1 downto 0):=(others=>'0');
constant scale   : real :=(2.0**(real(nbit-1)))/max_abs;
constant minq    : integer := -(2**(nbit-1));
constant maxq    : integer := +(2**(nbit-1))-1;
variable itemp   : integer := 0;

begin
  if(nbit>0) then
    if (dval>=0.0) then 
      itemp := +(integer(+dval*scale+0.49));
    else 
      itemp := -(integer(-dval*scale+0.49));
    end if;
    if(itemp<minq) then itemp := minq; end if;
    if(itemp>maxq) then itemp := maxq; end if;
  end if;
  temp := std_logic_vector(to_signed(itemp,nbit));
  return temp;
end quantization_sgn;

function quantization_uns(nbit : integer; max_abs : real; dval : real) return std_logic_vector is
variable temp        : std_logic_vector(nbit-1 downto 0):=(others=>'0');
constant bit_sign    : std_logic_vector(nbit-1 downto 0):=('1',others=>'0');

begin
  temp := quantization_sgn(nbit, max_abs, dval);
  temp := temp xor bit_sign;
  return temp;
end quantization_uns;

constant init_freq     : real:=1.0;
constant freq_increment: real:=0.02;
constant nsamples  : integer:=5;  -- LOG2 OF THE VALUE
constant nbit      : integer:=8;
constant increment_interval : integer := 20;
signal sine        : real:=0.0;
signal qsine_sgn   : std_logic_vector(nbit-1 downto 0):=(others=>'0');
signal qsine_uns   : std_logic_vector(nbit-1 downto 0):=(others=>'0');
 ------Sinus utility functions end

begin

      DUT : filter
        port map (
            CLK        => CLK,
            RESET      => RESET,
            Filter_In  => qsine_uns,
            Filter_Out => Filter_Out,
            ADC_Eocb    => ADC_eocb,
            ADC_Convstb => ADC_convstb,
            ADC_Rdb     => ADC_rdb,
            ADC_csb     => ADC_csb,
            DAC_Wrb     => DAC_wrb,
            DAC_csb     => DAC_csb,
            LDACb   => DAC_ldacb,
            CLRB    => DAC_clrb
            ) ;

    CLK   <= not(CLK) after 10 ns;
    RESET <= '1', '0' after 45 ns;

  

  ---- Test le bon fonctionnement du CNA;
      process_ADC : process(ADC_Convstb)
      begin
        if ADC_Convstb'event and ADC_Convstb = '0' then
          ADC_eocb <= '1', '0' after 300 ns, '1' after 400 ns;
        end if;
      end process process_ADC;

   

p_sine_table : process(clk)

variable v_sine        : real:=0.0;
variable v_tstep       : real:=0.0;
variable step          : real:=0.0;
variable frequency          : real:=init_freq;
variable increment : integer:=0;
variable v_qsine_uns   : std_logic_vector(nbit-1 downto 0):=(others=>'0');
variable v_qsine_sgn   : std_logic_vector(nbit-1 downto 0):=(others=>'0');

begin
  if(rising_edge(clk)) then
   if (ADC_rdb = '0' and ADC_csb='0') then
    -- compute new sample
      step   := frequency/real(2**nsamples);

      v_sine  := sin(MATH_2_PI*v_tstep);
      v_qsine_uns := quantization_uns(nbit, 1.0,v_sine);
      v_qsine_sgn := quantization_sgn(nbit, 1.0,v_sine);
      v_tstep := v_tstep + step;

      sine  <= v_sine ;
      qsine_uns <= v_qsine_uns;
      qsine_sgn <= v_qsine_sgn;
      increment := increment +1;
      if (increment = increment_interval) then
        frequency := frequency+freq_increment;
	increment := 0;
      end if;
   end if;    
  end if;
end process p_sine_table;

    end architecture;  -- arch
