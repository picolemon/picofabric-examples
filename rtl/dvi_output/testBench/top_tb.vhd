library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity top_tb is
end;

architecture a of top_tb is
    constant f_clock_c               : natural := 48000000; 
    constant t_clock_c        : time := (1 sec) / f_clock_c;
    -- external board clock
    signal clk_i : std_logic := '0';       

    signal clk0 : std_logic;
    signal clk1 : std_logic;
    signal clk2 : std_logic;
    signal clk3 : std_logic;
begin

    clk_i <= not clk_i after (t_clock_c/2);
 
    top_inst: entity work.top
    port map (    
        clk_48mhz  => clk_i
    );

	test_runner : process
	begin
		wait for 10 ns;
	end process;
	
end;
